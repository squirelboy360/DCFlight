import 'package:dc_test/templating/framework/core/vdom/node/low_levels/state_controller.dart';
import 'package:dc_test/templating/framework/core/main/abstractions/hooks/low_levels/state_abstraction.dart';
import 'package:dc_test/templating/framework/core/main/interface/main_view_coordinator.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/component.dart';
import 'package:flutter/foundation.dart';

/// React's exact Virtual DOM implementation - true 1:1 port of React's reconciler
class VDOM {
  // Previous render tree for diffing
  VNode? _previousTree;

  // Map of node keys to view IDs
  final Map<String, String> nodeToViewId = {};

  // Track existing views to avoid recreation
  final Set<String> _createdViews = {};

  // View ID counter for generating unique IDs
  int _viewIdCounter = 0;

  // Component tracking
  final Map<String, Component> _components = {};
  final Map<String, VNode> _renderedNodes = {};
  final Map<String, VNode> _viewIdToComponentNode = {};

  // Store component states
  final Map<String, Map<String, dynamic>> _componentStates = {};

  // Flags for update batching
  bool _isBatchingUpdates = false;
  final Set<String> _pendingUpdates = Set<String>();
  bool _isPerformingWork = false;

  /// React's stable ID mechanism
  String getViewId(VNode node) {
    // CRITICAL FIX: React prioritizes key for identity - add type as a fallback
    final uniqueKey = node.key.isNotEmpty
        ? node.key
        : "${node.type}_${identityHashCode(node.props)}";

    final nodeKey = "${node.type}_$uniqueKey";

    if (!nodeToViewId.containsKey(nodeKey)) {
      nodeToViewId[nodeKey] = 'view_${_viewIdCounter++}';
      debugPrint(
          'VDOM: Created new view ID ${nodeToViewId[nodeKey]} for node key $nodeKey');
    } else {
      debugPrint(
          'VDOM: Reusing view ID ${nodeToViewId[nodeKey]} for node key $nodeKey');
    }

    return nodeToViewId[nodeKey]!;
  }

  /// React's entry point reconciler
  void render(VNode newTree) {
    debugPrint('VDOM: Beginning render');
    _isPerformingWork = true;

    try {
      if (_previousTree == null) {
        debugPrint('VDOM: First render - mounting tree');
        _mountAtRoot(newTree);
      } else {
        debugPrint('VDOM: Updating previous tree with diff');
        // CRITICAL FIX: React's full tree reconciliation never recreates the root
        _reconcileRoot(_previousTree!, newTree);
      }

      // CRITICAL: Fix duplicated keys issue with detailed logging
      _validateChildKeys(newTree);

      _previousTree = _deepCopyVNode(newTree);
      debugPrint('VDOM: Render completed');
      _logTree(newTree);
    } finally {
      _isPerformingWork = false;
      _processQueuedUpdates();
    }
  }

  /// Process any pending updates
  void _processQueuedUpdates() {
    if (_pendingUpdates.isEmpty) return;

    final updates = List<String>.from(_pendingUpdates);
    _pendingUpdates.clear();

    for (final componentId in updates) {
      _updateComponent(componentId);
    }
  }

  /// Mount tree at root - React's initial mount
  void _mountAtRoot(VNode node) {
    final rootId = getViewId(node);
    _mount(node, rootId, true);
  }

  /// React's exact reconcileRoot algorithm - critical for preventing unnecessary deletion
  void _reconcileRoot(VNode oldTree, VNode newTree) {
    // CRITICAL FIX: Root element should NEVER be deleted/recreated
    final viewId = getViewId(oldTree);

    // Transfer the view ID to ensure the new tree uses the same root element
    nodeToViewId["${newTree.type}_${newTree.key}"] = viewId;

    // If same type, just update props and reconcile children
    if (oldTree.type == newTree.type) {
      if (!_arePropsEqual(oldTree.props, newTree.props)) {
        updateViewProps(viewId, newTree.props);
      }

      _reconcileChildrenExactly(oldTree, newTree, viewId);
    } else {
      // If root type changed, still preserve the container but change its type
      // This is how React handles root type changes - preserves DOM node
      debugPrint(
          'VDOM: Root type changed from ${oldTree.type} to ${newTree.type} - preserving view ID');
      updateViewProps(viewId, newTree.props);
      _reconcileChildrenExactly(oldTree, newTree, viewId);
    }
  }

  /// Mount a node - React's core mount algorithm
  void _mount(VNode node, String containerId, [bool isRoot = false]) {
    final viewId = getViewId(node);
    debugPrint(
        'VDOM: Mounting node ${node.type} with ID $viewId in container $containerId');

    // Handle components vs. host elements differently
    if (_isComponent(node)) {
      _mountComponent(node, viewId);

      if (isRoot && containerId != viewId) {
        setChildren(containerId, [viewId]);
      }
      return;
    }

    // Create or update host element view
    if (!_createdViews.contains(viewId)) {
      _createHostView(node, viewId);
      _createdViews.add(viewId);
    } else {
      updateViewProps(viewId, node.props);
    }

    // Mount children
    if (node.children.isNotEmpty) {
      final childViewIds = <String>[];

      for (var child in node.children) {
        _mount(child, viewId);
        childViewIds.add(getViewId(child));
      }

      if (childViewIds.isNotEmpty) {
        setChildren(viewId, childViewIds);
      }
    }

    // For root elements, establish parent-child relationship
    if (isRoot && containerId != viewId) {
      setChildren(containerId, [viewId]);
    }
  }

  /// Create host view - React's DOM element creation
  void _createHostView(VNode node, String viewId) {
    debugPrint(
        'VDOM: Creating host view for ${node.type} with ID $viewId (key: ${node.key})');

    // Extract props and events like React does
    final cleanProps = Map<String, dynamic>.from(node.props);
    final eventHandlers = <String, Function>{};

    cleanProps.keys.toList().forEach((key) {
      if (cleanProps[key] is Function) {
        if (key.startsWith('on') && key.length > 2) {
          eventHandlers[key] = cleanProps[key] as Function;
          cleanProps.remove(key);
        }
      }
    });

    // Create view
    MainViewCoordinatorInterface.createView(viewId, node.type, cleanProps);

    // Register events
    if (eventHandlers.isNotEmpty) {
      for (final entry in eventHandlers.entries) {
        GlobalStateManager.instance
            .registerEventHandler(viewId, entry.key, entry.value);
      }

      MainViewCoordinatorInterface.addEventListeners(
          viewId, eventHandlers.keys.toList());
    }
  }

  /// React's component mounting algorithm
  void _mountComponent(VNode node, String viewId) {
    final componentConstructor =
        node.props['_componentConstructor'] as Function;
    final componentInstance = componentConstructor();
    final componentId = node.props['_componentId'] as String;

    _components[componentId] = componentInstance;
    _viewIdToComponentNode[viewId] = node;

    // Filter internal props like React does
    final userProps = Map<String, dynamic>.from(node.props)
      ..remove('_isComponent')
      ..remove('_componentId')
      ..remove('_componentConstructor');

    if (componentInstance is Component) {
      componentInstance.props = userProps;
      componentInstance.updateCallback = () {
        _enqueueUpdate(componentId);
      };

      _componentStates[componentId] = {};
      componentInstance.mounted = true;

      // Render component
      final renderedNode = componentInstance.render();
      _renderedNodes[componentId] = _deepCopyVNode(renderedNode);

      // Mount output
      if (_isComponent(renderedNode)) {
        final childViewId = getViewId(renderedNode);
        _mountComponent(renderedNode, childViewId);
        setChildren(viewId, [childViewId]);
      } else {
        // CRITICAL FIX: When a component renders a host element, map its view ID to the component's
        // This is how React reuses the same DOM node for a component's output
        nodeToViewId["${renderedNode.type}_${renderedNode.key}"] = viewId;
        _createHostView(renderedNode, viewId);

        // Mount children
        if (renderedNode.children.isNotEmpty) {
          final childViewIds = <String>[];
          for (final child in renderedNode.children) {
            _mount(child, viewId);
            childViewIds.add(getViewId(child));
          }

          if (childViewIds.isNotEmpty) {
            setChildren(viewId, childViewIds);
          }
        }
      }

      // Call didMount after children are mounted
      componentInstance.componentDidMount();
    }
  }

  /// React's setState update scheduling
  void _enqueueUpdate(String componentId) {
    if (_isPerformingWork || _isBatchingUpdates) {
      _pendingUpdates.add(componentId);
    } else {
      _updateComponent(componentId);
    }
  }

  /// React's component update algorithm
  void _updateComponent(String componentId) {
    final component = _components[componentId];
    if (component == null || !component.mounted) return;

    // Find view ID for this component
    String? viewId;
    for (final entry in _viewIdToComponentNode.entries) {
      if (entry.value.props['_componentId'] == componentId) {
        viewId = entry.key;
        break;
      }
    }

    if (viewId == null) return;

    final prevRenderedNode = _renderedNodes[componentId];
    if (prevRenderedNode == null) return;

    // Get current state
    final currentState = _componentStates[componentId] ?? {};

    // Check if update can be skipped
    if (!component.shouldComponentUpdate(component.props, currentState)) {
      return;
    }

    // Render new output
    final newRenderedNode = component.render();

    // CRITICAL FIX: Copy for safety
    _renderedNodes[componentId] = _deepCopyVNode(newRenderedNode);

    // CRITICAL FIX: React will preserve the same DOM node for a component across renders
    // This is the key to preventing unnecessary deletions/recreations
    _reconcileComponentOutput(prevRenderedNode, newRenderedNode, viewId);

    // Call lifecycle
    if (component.mounted) {
      component.componentDidUpdate(component.props, currentState);
    }
  }

  /// React's component output reconciliation
  void _reconcileComponentOutput(
      VNode oldOutput, VNode newOutput, String viewId) {
    debugPrint('VDOM: Reconciling component output for view $viewId');

    // CRITICAL FIX: If both old and new output are same type, just update in place
    if (oldOutput.type == newOutput.type) {
      if (!_arePropsEqual(oldOutput.props, newOutput.props)) {
        updateViewProps(viewId, newOutput.props);
      }

      // Reconcile children
      _reconcileChildrenExactly(oldOutput, newOutput, viewId);
    }
    // If types differ, we need to handle carefully
    else {
      // Special container types get preserved
      if (_isSpecialContainerType(oldOutput.type) &&
          _isSpecialContainerType(newOutput.type)) {
        debugPrint('VDOM: Container type changed but preserving view');
        updateViewProps(viewId, newOutput.props);
        _reconcileChildrenExactly(oldOutput, newOutput, viewId);
      }
      // For normal elements with different types, we follow React's exact replacement algorithm
      else {
        // Remove all existing children
        final oldChildViewIds = _getChildViewIds(oldOutput);
        for (final childId in oldChildViewIds) {
          _unmountRecursive(childId);
        }

        // Update the type and props of the container element
        MainViewCoordinatorInterface.updateView(
            viewId, {'elementType': newOutput.type, ...newOutput.props});

        // Mount new children
        final newChildViewIds = <String>[];
        for (final child in newOutput.children) {
          _mount(child, viewId);
          newChildViewIds.add(getViewId(child));
        }

        // Set children relationship
        if (newChildViewIds.isNotEmpty) {
          setChildren(viewId, newChildViewIds);
        }
      }
    }
  }

  /// React's exact reconciliation algorithm (React's core diffing)
  void _reconcileChildrenExactly(
      VNode oldParent, VNode newParent, String containerViewId) {
    final oldChildren = oldParent.children;
    final newChildren = newParent.children;

    // CRITICAL: Fast path for empty children lists
    if (oldChildren.isEmpty && newChildren.isEmpty) {
      return;
    }

    // CRITICAL: Fast path for when old list is empty
    if (oldChildren.isEmpty) {
      final newChildViewIds = <String>[];
      for (final newChild in newChildren) {
        _mount(newChild, containerViewId);
        newChildViewIds.add(getViewId(newChild));
      }

      setChildren(containerViewId, newChildViewIds);
      return;
    }

    // CRITICAL: Fast path for when new list is empty
    if (newChildren.isEmpty) {
      for (final oldChild in oldChildren) {
        final oldChildViewId = getViewId(oldChild);
        _unmountRecursive(oldChildViewId);
      }

      setChildren(containerViewId, []);
      return;
    }

    // The real React reconciliation algorithm for non-empty lists

    // Step 1: Map all old children by key for O(1) lookup
    final oldChildrenMap = <String, VNode>{};
    final oldChildViewIds = <String, String>{};

    for (final oldChild in oldChildren) {
      oldChildrenMap[oldChild.key] = oldChild;
      oldChildViewIds[oldChild.key] = getViewId(oldChild);
    }

    // Step 2: Process new children and track which ones we need to keep
    final updatedChildViewIds = <String>[];
    final reusedKeys = <String>{};

    for (int i = 0; i < newChildren.length; i++) {
      final newChild = newChildren[i];
      final key = newChild.key;

      // Check if we can reuse an existing child
      if (oldChildrenMap.containsKey(key)) {
        final oldChild = oldChildrenMap[key]!;
        final oldChildViewId = oldChildViewIds[key]!;

        // Mark this key as reused

        reusedKeys.add(key);

        // If same type, update in place - this is key to React's efficiency
        if (oldChild.type == newChild.type) {
          // CRITICAL: Ensure the new tree uses the same view ID
          nodeToViewId["${newChild.type}_${newChild.key}"] = oldChildViewId;

          // Update props if needed
          if (!_arePropsEqual(oldChild.props, newChild.props)) {
            updateViewProps(oldChildViewId, newChild.props);
          }

          // Recursively reconcile this child's children
          _reconcileChildrenExactly(oldChild, newChild, oldChildViewId);
        }
        // Different type, same key - replace but preserve position
        else {
          _unmountRecursive(oldChildViewId);

          // Mount new node reusing the same position
          _mount(newChild, containerViewId);
        }

        updatedChildViewIds.add(getViewId(newChild));
      }
      // No existing child with this key - mount as new
      else {
        _mount(newChild, containerViewId);
        updatedChildViewIds.add(getViewId(newChild));
      }
    }

    // Step 3: Remove any old children that weren't reused
    for (final key in oldChildrenMap.keys) {
      if (!reusedKeys.contains(key)) {
        final oldChildViewId = oldChildViewIds[key]!;
        _unmountRecursive(oldChildViewId);
      }
    }

    // Step 4: Update the children order in the parent
    if (updatedChildViewIds.isNotEmpty) {
      setChildren(containerViewId, updatedChildViewIds);
    }
  }

  /// Helper to get child view IDs
  List<String> _getChildViewIds(VNode node) {
    final result = <String>[];
    for (final child in node.children) {
      final childViewId = getViewId(child);
      result.add(childViewId);
    }
    return result;
  }

  /// Unmount a view and all its children recursively
  void _unmountRecursive(String viewId) {
    // If this is a component, handle it specially
    if (_viewIdToComponentNode.containsKey(viewId)) {
      final node = _viewIdToComponentNode[viewId]!;
      final componentId = node.props['_componentId'] as String?;

      if (componentId != null) {
        final component = _components[componentId];
        if (component != null) {
          component.componentWillUnmount();
          component.mounted = false;

          _components.remove(componentId);
          _componentStates.remove(componentId);
          _renderedNodes.remove(componentId);
        }
      }

      _viewIdToComponentNode.remove(viewId);
    }

    // Delete the view
    MainViewCoordinatorInterface.deleteView(viewId);
    _createdViews.remove(viewId);

    // Cleanup view ID mappings
    nodeToViewId.removeWhere((key, value) => value == viewId);
  }

  /// Update view props
  void updateViewProps(String viewId, Map<String, dynamic> props) {
    final cleanProps = Map<String, dynamic>.from(props);
    final eventHandlers = <String, Function>{};

    // Extract event handlers
    cleanProps.keys.toList().forEach((key) {
      if (cleanProps[key] is Function) {
        if (key.startsWith('on') && key.length > 2) {
          eventHandlers[key] = cleanProps[key] as Function;
          cleanProps.remove(key);
        }
      }
    });

    // Update props
    MainViewCoordinatorInterface.updateView(viewId, cleanProps);

    // Update event handlers
    if (eventHandlers.isNotEmpty) {
      for (final entry in eventHandlers.entries) {
        GlobalStateManager.instance
            .registerEventHandler(viewId, entry.key, entry.value);
      }

      MainViewCoordinatorInterface.addEventListeners(
          viewId, eventHandlers.keys.toList());
    }
  }

  /// Compare props for equality (React's shallowEqual)
  bool _arePropsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      // Skip internal React props
      if (key.startsWith('_')) continue;

      // Skip function equality checks - React can't compare functions
      if (a[key] is Function && b[key] is Function) continue;

      // Handle style objects specially - React does this too
      if (key == 'style' && a[key] is Map && b[key] is Map) {
        if (!_areStylePropsEqual(
            a[key] as Map<String, dynamic>, b[key] as Map<String, dynamic>)) {
          return false;
        }
        continue;
      }

      // Basic equality check - React uses Object.is
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }

    return true;
  }

  /// Compare style props
  bool _areStylePropsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }

    return true;
  }

  /// Set children (React's insertBefore and appendChild)
  void setChildren(String parentId, List<String> childIds) {
    // CRITICAL FIX: Log the complete children list for debugging
    debugPrint('VDOM: Set children for $parentId: $childIds');
    MainViewCoordinatorInterface.setChildren(parentId, childIds);
  }

  /// Check if a node is a component
  bool _isComponent(VNode node) {
    return node.props['_isComponent'] == true;
  }

  /// Check if a type is a special container that gets special handling
  bool _isSpecialContainerType(String type) {
    return type.contains('Modal') ||
        type.contains('SafeArea') ||
        type.contains('View') ||
        type.contains('Container') ||
        type.contains('KeyboardAvoiding');
  }

  /// Create a deep copy of a VNode
  VNode _deepCopyVNode(VNode node) {
    return VNode(node.type,
        props: Map<String, dynamic>.from(node.props),
        children: _deepCopyChildren(node.children),
        key: node.key);
  }

  /// Helper to deep copy children
  List<VNode> _deepCopyChildren(List<VNode> children) {
    return children
        .map((child) => VNode(child.type,
            props: Map<String, dynamic>.from(child.props),
            children: _deepCopyChildren(child.children),
            key: child.key))
        .toList();
  }

  /// Set component state
  void setComponentState(String componentId, Map<String, dynamic> newState) {
    if (!_componentStates.containsKey(componentId)) {
      _componentStates[componentId] = {};
    }

    // Update state values
    bool stateChanged = false;
    for (final key in newState.keys) {
      if (_componentStates[componentId]![key] != newState[key]) {
        _componentStates[componentId]![key] = newState[key];
        stateChanged = true;
      }
    }

    // If state changed, trigger update
    if (stateChanged) {
      // Update StateValue controllers
      final component = _components[componentId];
      if (component is Component) {
        for (final key in newState.keys) {
          final field = findComponentStateField(component, key);
          if (field != null && field is StateValue) {
            field.updateCurrentValue(newState[key]);
          }
        }
      }

      // Queue update
      _enqueueUpdate(componentId);
    }
  }

  /// Find a field in a component
  dynamic findComponentStateField(Component component, String fieldName) {
    // Ask the component for its state field
    return component.getStateField(fieldName);
  }

  /// Batched updates API
  void batchUpdates(Function fn) {
    final prevIsBatching = _isBatchingUpdates;
    _isBatchingUpdates = true;

    try {
      fn();
    } finally {
      _isBatchingUpdates = prevIsBatching;

      if (!_isBatchingUpdates && !_isPerformingWork) {
        _processQueuedUpdates();
      }
    }
  }

  /// Log view tree
  void _logTree(VNode node, [int depth = 0]) {
    final indent = ' ' * (depth * 2);
    final viewId = getViewId(node);
    debugPrint('$indent$viewId: ${node.type} (key: ${node.key})');
    for (final child in node.children) {
      _logTree(child, depth + 1);
    }
  }

  /// Validate that all children have unique keys (helps debug issues)
  void _validateChildKeys(VNode node) {
    if (node.children.isEmpty) return;

    // Check for duplicate keys within this level
    final keysAtThisLevel = <String>{};
    final duplicateKeys = <String>{};

    for (final child in node.children) {
      if (keysAtThisLevel.contains(child.key)) {
        duplicateKeys.add(child.key);
      } else {
        keysAtThisLevel.add(child.key);
      }

      // Recursively check children
      _validateChildKeys(child);
    }

    // Log any duplicate keys - this is a critical issue
    if (duplicateKeys.isNotEmpty) {
      debugPrint(
          'VDOM ERROR: Found duplicate keys in children of ${node.type}: $duplicateKeys');
      debugPrint(
          'This will cause serious rendering issues - each child needs a unique key!');
    }
  }
}
