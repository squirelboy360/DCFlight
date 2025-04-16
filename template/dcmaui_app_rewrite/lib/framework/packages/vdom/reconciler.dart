import 'dart:developer' as developer;
import 'dart:math' as math;
import '../../constants/layout_properties.dart';

import 'vdom_node.dart';
import 'vdom_element.dart';
import 'component/component_node.dart';
import 'vdom.dart';
import '../native_bridge/native_bridge.dart';

/// Class responsible for reconciling differences between VDOM trees
class Reconciler {
  /// Reference to the VDOM
  final VDom vdom;

  /// Constructor
  Reconciler(this.vdom);

  /// Reconcile two nodes and apply minimal changes
  Future<void> reconcile(VDomNode oldNode, VDomNode newNode) async {
    // developer.log('Reconciling: $oldNode -> $newNode', name: 'Reconciler');

    // Handle different types of nodes
    if (oldNode.runtimeType != newNode.runtimeType) {
      // Complete replacement needed
      await _replaceNode(oldNode, newNode);
      return;
    }

    // Handle same node types
    if (oldNode is VDomElement && newNode is VDomElement) {
      // Same element type?
      if (oldNode.type == newNode.type) {
        // Same key or both null?
        if (oldNode.key == newNode.key) {
          // Update the element
          await _updateElement(oldElement: oldNode, newElement: newNode);
          return;
        }
      }

      // Different type or key - replacement needed
      await _replaceNode(oldNode, newNode);
    } else if (oldNode is ComponentNode && newNode is ComponentNode) {
      // Component comparison - check type
      if (oldNode.component.runtimeType == newNode.component.runtimeType) {
        // Copy over native view IDs and rendered nodes for proper tracking
        newNode.nativeViewId = oldNode.nativeViewId;
        newNode.contentViewId = oldNode.contentViewId;

        // Just update rendered content if available
        if (oldNode.renderedNode != null && newNode.renderedNode != null) {
          // Pass parent's native view ID for proper hierarchical updates
          if (oldNode.contentViewId != null) {
            newNode.renderedNode!.nativeViewId = oldNode.contentViewId;
          }

          await reconcile(oldNode.renderedNode!, newNode.renderedNode!);
        }
      } else {
        await _replaceNode(oldNode, newNode);
      }
    } else if (oldNode is EmptyVDomNode && newNode is EmptyVDomNode) {
      // Nothing to do for empty nodes
      return;
    } else {
      // Other node types - replace
      await _replaceNode(oldNode, newNode);
    }

    // Calculate and apply layout after reconciliation if this is a root element
    if (newNode == vdom.rootComponentNode?.renderedNode) {
      await vdom.calculateAndApplyLayout();
    }
  }

  /// Update an element with new props and children
  Future<void> _updateElement(
      {required VDomElement oldElement,
      required VDomElement newElement}) async {
    // Update props if node already has a native view
    if (oldElement.nativeViewId != null) {
      newElement.nativeViewId = oldElement.nativeViewId;

      // Find changed props with generic diffing - excluding layout props
      final changedProps = <String, dynamic>{};

      // Check for props that have changed or been added
      for (final entry in newElement.props.entries) {
        final key = entry.key;
        final value = entry.value;

        // If prop has changed or is new
        if (!oldElement.props.containsKey(key) ||
            oldElement.props[key] != value) {
          changedProps[key] = value;
        }
      }

      // Check for removed props
      for (final key in oldElement.props.keys) {
        if (!newElement.props.containsKey(key)) {
          // Set to null to indicate removal (handled by native bridge)
          changedProps[key] = null;
        }
      }

      // Update props directly if there are changes
      if (changedProps.isNotEmpty) {
        // Preserve event handlers
        oldElement.props.forEach((key, value) {
          if (key.startsWith('on') &&
              value is Function &&
              !changedProps.containsKey(key)) {
            changedProps[key] = value;
          }
        });

        await vdom.updateView(oldElement.nativeViewId!, changedProps);

        if (changedProps.keys.any((key) => _isLayoutProp(key))) {
          vdom.calculateAndApplyLayout();
        }
      }

      // Now reconcile children
      await _reconcileChildren(oldElement, newElement);
    }
  }

  /// Check if a property is a layout-related property
  bool _isLayoutProp(String propName) {
    return LayoutProps.isLayoutProperty(propName);
  }

  /// Reconcile children between old and new elements
  Future<void> _reconcileChildren(
      VDomElement oldElement, VDomElement newElement) async {
    final oldChildren = oldElement.children;
    final newChildren = newElement.children;

    // Fast-path: no children in either old or new
    if (oldChildren.isEmpty && newChildren.isEmpty) return;

    // Extract keys and detect keyed mode
    final hasKeys = _childrenHaveKeys(newChildren);

    if (hasKeys) {
      // Keyed reconciliation (more efficient for reordering)
      await _reconcileKeyedChildren(
          oldElement.nativeViewId!, oldChildren, newChildren);
    } else {
      // Non-keyed reconciliation (simpler)
      await _reconcileNonKeyedChildren(
          oldElement.nativeViewId!, oldChildren, newChildren);
    }
  }

  /// Check if children have explicit keys
  bool _childrenHaveKeys(List<VDomNode> children) {
    if (children.isEmpty) return false;

    // Check if any child has a key
    for (var child in children) {
      if (child.key != null) return true;
    }

    return false;
  }

  /// Reconcile keyed children with maximum reuse
  Future<void> _reconcileKeyedChildren(String parentViewId,
      List<VDomNode> oldChildren, List<VDomNode> newChildren) async {
    // Map old children by key for O(1) lookup
    final oldChildrenMap = <String?, VDomNode>{};
    final oldChildIndices = <String?, int>{};

    for (int i = 0; i < oldChildren.length; i++) {
      final oldChild = oldChildren[i];
      final key = oldChild.key ?? i.toString(); // Use index for null keys
      oldChildrenMap[key] = oldChild;
      oldChildIndices[key] = i;
    }

    // Track inserted and moved children views
    final updatedChildren = <String>[];
    var lastIndex = 0;

    // Process each new child
    for (int i = 0; i < newChildren.length; i++) {
      final newChild = newChildren[i];
      final key = newChild.key ?? i.toString();

      VDomNode? oldChild = oldChildrenMap[key];

      if (oldChild != null) {
        // Reusable child - update it
        await reconcile(oldChild, newChild);

        // Add to updated children
        if (oldChild.nativeViewId != null) {
          updatedChildren.add(oldChild.nativeViewId!);

          // Check if we need to move this node
          final oldIndex = oldChildIndices[key] ?? 0;
          if (oldIndex < lastIndex) {
            // Node needs to move
            if (oldChild.nativeViewId != null) {
              await _moveViewInParent(oldChild.nativeViewId!, parentViewId, i);
            }
          } else {
            // Node stays in place
            lastIndex = oldIndex;
          }
        }
      } else {
        // New or incompatible child - create it
        final childId = await vdom.renderToNative(newChild,
            parentId: parentViewId, index: i);

        if (childId != null && childId.isNotEmpty) {
          updatedChildren.add(childId);
          newChild.nativeViewId = childId;
        }
      }
    }

    // Remove any old children that aren't in the new list
    for (var oldChild in oldChildren) {
      final key = oldChild.key ?? oldChildren.indexOf(oldChild).toString();
      if (!newChildren.any((newChild) =>
          (newChild.key ?? newChildren.indexOf(newChild).toString()) == key)) {
        if (oldChild.nativeViewId != null) {
          await _deleteView(oldChild.nativeViewId!);
        }
      }
    }

    // Update children order
    if (updatedChildren.isNotEmpty) {
      await vdom.setChildren(parentViewId, updatedChildren);
    }
  }

  /// Reconcile non-keyed children (simpler but less efficient for reordering)
  Future<void> _reconcileNonKeyedChildren(String parentViewId,
      List<VDomNode> oldChildren, List<VDomNode> newChildren) async {
    final updatedChildren = <String>[];
    final commonLength = oldChildren.length < newChildren.length
        ? oldChildren.length
        : newChildren.length;

    // Update common children
    for (var i = 0; i < commonLength; i++) {
      final oldChild = oldChildren[i];
      final newChild = newChildren[i];

      // Transfer native view ID to new child for reconciliation
      if (oldChild.nativeViewId != null) {
        await reconcile(oldChild, newChild);
        newChild.nativeViewId = oldChild.nativeViewId;
        updatedChildren.add(oldChild.nativeViewId!);
      } else {
        // Render a new child
        final childId = await vdom.renderToNative(newChild,
            parentId: parentViewId, index: i);
        if (childId != null && childId.isNotEmpty) {
          updatedChildren.add(childId);
          newChild.nativeViewId = childId;
        }
      }
    }

    // Remove extra old children
    if (oldChildren.length > newChildren.length) {
      for (var i = commonLength; i < oldChildren.length; i++) {
        final oldChild = oldChildren[i];
        if (oldChild.nativeViewId != null) {
          await _deleteView(oldChild.nativeViewId!);
        }
      }
    }

    // Add new children
    if (newChildren.length > oldChildren.length) {
      for (var i = commonLength; i < newChildren.length; i++) {
        final newChild = newChildren[i];
        final childId = await vdom.renderToNative(newChild,
            parentId: parentViewId, index: i);
        if (childId != null && childId.isNotEmpty) {
          updatedChildren.add(childId);
          newChild.nativeViewId = childId;
        }
      }
    }

    // Update children order
    if (updatedChildren.isNotEmpty) {
      await vdom.setChildren(parentViewId, updatedChildren);
    }
  }

  /// Replace an old node with a new one
  Future<void> _replaceNode(VDomNode oldNode, VDomNode newNode) async {
    if (oldNode.nativeViewId == null) {
      developer.log('Cannot replace node without native view ID',
          name: 'Reconciler');
      return;
    }

    // Get parent info for later
    final parentInfo = _getParentInfo(oldNode);
    if (parentInfo == null) {
      developer.log('Failed to find parent info for node replacement',
          name: 'Reconciler');
      return;
    }

    final parentId = parentInfo.parentId;
    final index = parentInfo.index;

    // Delete the old node
    await _deleteView(oldNode.nativeViewId!);

    // Create the new node under the same parent
    final newNodeId =
        await vdom.renderToNative(newNode, parentId: parentId, index: index);

    // Update references
    newNode.nativeViewId = newNodeId;
    if (oldNode.nativeViewId != null) {
      vdom.removeNodeFromTree(oldNode.nativeViewId!);
    }
    if (newNodeId != null && newNodeId.isNotEmpty) {
      vdom.addNodeToTree(newNodeId, newNode);
    }
  }

  /// Helper method to move a view in its parent
  Future<void> _moveViewInParent(
      String childId, String parentId, int index) async {
    // Delegate to vdom's native bridge
    await vdom.detachView(childId);
    await vdom.attachView(childId, parentId, index);
  }

  /// Helper method to delete a view
  Future<void> _deleteView(String viewId) async {
    await vdom.deleteView(viewId);
  }

  /// Get parent information for a node
  _ParentInfo? _getParentInfo(VDomNode node) {
    // The node must have a parent to get parent info
    if (node.parent == null) {
      return null;
    }

    final parent = node.parent!;
    if (parent is! VDomElement || parent.nativeViewId == null) {
      return null;
    }

    // Find index of node in parent's children
    final index = parent.children.indexOf(node);
    if (index < 0) return null;

    return _ParentInfo(parent.nativeViewId!, index);
  }

  // Add support for registering events during reconciliation
  static void mountElement(VDomElement element, String? parentId) async {
    try {
      final elementId = element.key ?? generateId();

      // Create the view
      await NativeBridge.instance.createView(
        elementId,
        element.type,
        element.props,
      );

      // If parent is not null, attach this view to the parent
      if (parentId != null) {
        await NativeBridge.instance.attachView(
          elementId,
          parentId,
          0, // Default index, can be updated later
        );
      }

      // Register any events for this element
      if (element.events != null && element.events!.isNotEmpty) {
        // Register event listeners with native side
        List<String> eventTypes = element.events!.keys.toList();
        await NativeBridge.instance.addEventListeners(elementId, eventTypes);

        // Register callbacks for each event type
        element.events!.forEach((eventType, callback) {
          NativeBridge.instance
              .registerEventCallback(elementId, eventType, callback);
        });
      }

      // Now mount all children
      final childIds = <String>[];
      for (int i = 0; i < element.children.length; i++) {
        final child = element.children[i];
        if (child is VDomElement) {
          // Get or generate child ID
          final childId = child.key ?? generateId();
          childIds.add(childId);

          // Mount the child - don't use return value
          mountElement(child, elementId); // Don't await or use the result
        }
      }

      // Set children in order
      if (childIds.isNotEmpty) {
        await NativeBridge.instance.setChildren(elementId, childIds);
      }
    } catch (e, st) {
      developer.log('Error mounting element: $e\n$st');
    }
  }

  // Add the missing generateId method
  static String generateId() {
    final random = math.Random();
    final id =
        'node_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(10000)}';
    return id;
  }
}

/// Helper class to store parent information
class _ParentInfo {
  final String parentId;
  final int index;

  _ParentInfo(this.parentId, this.index);
}
