import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:dcflight/framework/utilities/flutter.dart';

import '../../constants/layout_properties.dart';

import 'vdom_node.dart';
import 'vdom_element.dart';
import 'component/component_node.dart';
import 'vdom.dart';
import '../native_bridge/dispatcher.dart';

/// Class responsible for reconciling differences between VDOM trees
class Reconciler {
  /// Reference to the VDOM
  final VDom vdom;

  /// Constructor
  Reconciler(this.vdom);
  /// Check if a property is a layout-related property
  bool _isLayoutProp(String propName) {
    return LayoutProps.isLayoutProperty(propName);
  }
  /// Reconcile two nodes and apply minimal changes
  Future<void> reconcile(VDomNode oldNode, VDomNode newNode) async {
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
        // Copy over native view IDs for proper tracking
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
  Future<void> _updateElement({
    required VDomElement oldElement,
    required VDomElement newElement
  }) async {
    // Update props if node already has a native view
    if (oldElement.nativeViewId != null) {
      // Transfer ID from old to new element
      newElement.nativeViewId = oldElement.nativeViewId;
      
      // Step 1: Prepare the prop changes
      final Map<String, dynamic> changedProps = {};
      
      // Step 2: Check for special props like content and text that need special handling
      bool hasContentProps = false;
      bool hasStyleProps = false;
      
      // Step 3: Find actually changed props
      for (final key in newElement.props.keys) {
        final newValue = newElement.props[key];
        
        // Check if this is a content prop
        if (key == 'content' || key == 'text') {
          hasContentProps = true;
          // Always include content props regardless if changed
          changedProps[key] = newValue;
          debugPrint("📄 Content prop $key: $newValue");
        } 
        // Check if this is a style prop
        else if (!_isLayoutProp(key)) {
          hasStyleProps = true;
          // Check if the value changed
          if (!oldElement.props.containsKey(key) || oldElement.props[key] != newValue) {
            changedProps[key] = newValue;
            debugPrint("🎨 Style prop $key changed: $newValue");
          }
        }
        // Check layout props
        else if (_isLayoutProp(key)) {
          // Only include if value changed
          if (!oldElement.props.containsKey(key) || oldElement.props[key] != newValue) {
            changedProps[key] = newValue;
            debugPrint("📏 Layout prop $key changed: $newValue");
          }
        }
      }
      
      // Step 4: When updating content, ensure all style props are sent too
      if (hasContentProps && hasStyleProps) {
        for (final key in oldElement.props.keys) {
          // If it's a style prop and not already added to changes
          if (!_isLayoutProp(key) && 
              key != 'content' && 
              key != 'text' &&
              !changedProps.containsKey(key)) {
            // Include this style prop to ensure it's preserved
            changedProps[key] = oldElement.props[key];
            debugPrint("🔒 Preserving style prop $key: ${oldElement.props[key]}");
          }
        }
      }
      
      // Step 5: Preserve event handlers
      oldElement.events?.forEach((key, value) {
        if (value is Function) {
          newElement.events ??= {};
          newElement.events![key] = value;
        }
      });

      // Step 6: Update merged props for future reconciliations
      final mergedProps = Map<String, dynamic>.from(oldElement.props);
      for (final entry in newElement.props.entries) {
        mergedProps[entry.key] = entry.value;
      }
      newElement.props = mergedProps;
      
      // Step 7: Only update if there are changes to apply
      if (changedProps.isNotEmpty) {
        debugPrint("🔄 Updating view ${oldElement.nativeViewId} with ${changedProps.keys.length} props: ${changedProps.keys.join(', ')}");
        
        bool updateSuccess = await vdom.updateView(oldElement.nativeViewId!, changedProps);
        
        if (!updateSuccess) {
          debugPrint("❌ Failed to update view ${oldElement.nativeViewId}");
        } else {
          debugPrint("✅ Successfully updated view ${oldElement.nativeViewId}");
        }
        
        // Calculate layout if any layout props changed
        if (changedProps.keys.any(_isLayoutProp)) {
          await vdom.calculateAndApplyLayout();
        }
      }
    }

    // Now reconcile children
    await _reconcileChildren(oldElement, newElement);
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
      await PlatformDispatcher.instance.createView(
        elementId,
        element.type,
        element.props,
      );

      // If parent is not null, attach this view to the parent
      if (parentId != null) {
        await PlatformDispatcher.instance.attachView(
          elementId,
          parentId,
          0, // Default index, can be updated later
        );
      }

      // Register any events for this element
      if (element.events != null && element.events!.isNotEmpty) {
        // Register event listeners with native side
        List<String> eventTypes = element.events!.keys.toList();
        await PlatformDispatcher.instance
            .addEventListeners(elementId, eventTypes);

        // Register callbacks for each event type
        element.events!.forEach((eventType, callback) {
          PlatformDispatcher.instance
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
        await PlatformDispatcher.instance.setChildren(elementId, childIds);
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
