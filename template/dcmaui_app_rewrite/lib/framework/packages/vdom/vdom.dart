// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:developer' as developer;

import '../native_bridge/native_bridge.dart';
import '../native_bridge/ffi_bridge.dart';
import '../performance/performance_monitor.dart';
import 'vdom_node.dart';
import 'vdom_element.dart';
import 'component.dart';
import 'component_node.dart';
import 'reconciler.dart';
import 'context.dart';
import 'fragment.dart';
import 'error_boundary.dart';

/// Virtual DOM implementation that bridges to native UI
class VDom {
  /// The native bridge for UI operations
  final NativeBridge _nativeBridge;

  /// Ready completer
  final Completer<void> _readyCompleter = Completer<void>();

  /// Map of component instances by ID
  final Map<String, ComponentInstance> _componentInstances = {};

  /// Reconciliation engine
  late final Reconciler _reconciler;

  /// Tree of rendered nodes
  final Map<String, VDomNode> _nodeTree = {};

  /// Reverse mapping from component ID to view ID
  final Map<String, String> _componentToViewId = {};

  /// Next available view ID counter
  int _nextViewIdCounter = 1;

  /// Whether the VDOM is initialized
  bool _isInitialized = false;

  /// Performance monitor
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  /// Current batch update
  final Set<String> _pendingUpdates = {};

  /// Whether an update is scheduled
  bool _isUpdateScheduled = false;

  /// Context registry
  final ContextRegistry _contextRegistry = ContextRegistry();

  /// Error boundaries
  final Map<String, ErrorBoundary> _errorBoundaries = {};

  /// Map of component nodes by component instance ID for quick lookup
  final Map<String, ComponentNode> _componentNodes = {};

  /// Constructor
  VDom({NativeBridge? nativeBridge})
      : _nativeBridge = nativeBridge ?? FFINativeBridge() {
    _initialize();
  }

  /// Initialize the VDOM
  void _initialize() async {
    if (_isInitialized) return;

    // Initialize native bridge
    _performanceMonitor.startTimer('vdom_initialize');
    final success = await _nativeBridge.initialize();
    _performanceMonitor.endTimer('vdom_initialize');

    if (!success) {
      developer.log('Failed to initialize native bridge', name: 'VDom');
      _readyCompleter.completeError('Failed to initialize native bridge');
      return;
    }

    // Set up event handler
    _nativeBridge.setEventHandler(_handleNativeEvent);

    // Create reconciler
    _reconciler = Reconciler(this);

    // Mark as initialized
    _isInitialized = true;
    _readyCompleter.complete();

    developer.log('VDom initialized', name: 'VDom');
  }

  /// Future that completes when VDom is ready
  Future<void> get isReady => _readyCompleter.future;

  /// Expose methods for reconciler to use
  Future<bool> updateView(String viewId, Map<String, dynamic> props) {
    return _nativeBridge.updateView(viewId, props);
  }

  Future<bool> attachView(String viewId, String parentId, int index) {
    return _nativeBridge.attachView(viewId, parentId, index);
  }

  Future<bool> deleteView(String viewId) {
    return _nativeBridge.deleteView(viewId);
  }

  Future<bool> setChildren(String viewId, List<String> childIds) {
    return _nativeBridge.setChildren(viewId, childIds);
  }

  void removeNodeFromTree(String viewId) {
    _nodeTree.remove(viewId);
  }

  void addNodeToTree(String viewId, VDomNode node) {
    _nodeTree[viewId] = node;
  }

  /// Create a component node
  ComponentNode createComponent(Component component) {
    final node = ComponentNode(component: component);

    // Create and register a component instance
    _componentInstances[component.instanceId] = ComponentInstance(
      component: component,
      vdomRef: this,
    );

    // Store component node for quick lookup
    _componentNodes[component.instanceId] = node;

    // Create component instance and set up update scheduling
    if (component is StatefulComponent) {
      // Add method to schedule component updates
      component.scheduleUpdate = () {
        _scheduleComponentUpdate(component);
      };
    }

    return node;
  }

  /// Render a node to native UI
  Future<String> renderToNative(VDomNode node,
      {required String parentId, int index = 0}) async {
    // Wait for initialization
    await isReady;

    _performanceMonitor.startTimer('render_to_native');
    try {
      // Handle Fragment nodes
      if (node is Fragment) {
        // Just render children directly to parent
        final childIds = <String>[];
        int childIndex = index;

        for (final child in node.children) {
          final childId = await renderToNative(
            child,
            parentId: parentId,
            index: childIndex++,
          );

          if (childId.isNotEmpty) {
            childIds.add(childId);
          }
        }

        return ""; // Fragments don't have their own ID
      }

      if (node is ComponentNode) {
        // Render the component
        final instance = _componentInstances[node.component.instanceId];
        if (instance == null) {
          throw Exception('Component instance not found');
        }

        // Prepare component for render
        if (node.component is StatefulComponent) {
          (node.component as StatefulComponent).prepareForRender();
        }

        try {
          // Render to get actual node
          _performanceMonitor.startTimer('component_render');
          final renderedNode = node.component.render();
          _performanceMonitor.endTimer('component_render');

          // Store rendered node
          node.renderedNode = renderedNode;

          // Set parent reference
          renderedNode.parent = node;

          // Add listener for updates
          if (node.component is StatefulComponent) {
            final stateful = node.component as StatefulComponent;
            // Only add listener if not already listening
            if (!instance.hasUpdateListener) {
              instance.hasUpdateListener = true;
            }
          }

          // Register error boundary if applicable
          if (node.component is ErrorBoundary) {
            _errorBoundaries[node.component.instanceId] =
                node.component as ErrorBoundary;
          }

          // Continue with rendering the actual node
          final viewId = await renderToNative(renderedNode,
              parentId: parentId, index: index);

          // Store component -> viewId mapping for quick lookups
          if (viewId.isNotEmpty) {
            _componentToViewId[node.component.instanceId] = viewId;
          }

          // Run effects after render for stateful components
          if (node.component is StatefulComponent && instance.isMounted) {
            (node.component as StatefulComponent).runEffectsAfterRender();
          }

          return viewId;
        } catch (error, stackTrace) {
          // Try to find nearest error boundary
          final errorBoundary = _findNearestErrorBoundary(node);
          if (errorBoundary != null) {
            errorBoundary.handleError(error, stackTrace);
            return ""; // Error handled by boundary
          }

          // No error boundary, propagate error
          rethrow;
        }
      }

      if (node is VDomElement) {
        // Special handling for context provider
        if (node.type == 'ContextProvider') {
          final contextId = node.props['contextId'] as String;
          final value = node.props['value'];
          final providerId = 'provider_${_nextViewIdCounter++}';

          // Register context value
          _contextRegistry.setContextValue(contextId, providerId, value);

          // Render children
          if (node.children.isNotEmpty) {
            return await renderToNative(node.children[0],
                parentId: parentId, index: index);
          }
          return "";
        }

        // Special handling for context consumer
        if (node.type == 'ContextConsumer') {
          final contextId = node.props['contextId'] as String;
          final consumer = node.props['consumer'] as Function;
          final providerChain = _getProviderChain(node);

          // Get context value
          final value =
              _contextRegistry.getContextValue(contextId, providerChain);

          // Build child using consumer function
          final child = consumer(value);

          // Render the child
          return await renderToNative(child, parentId: parentId, index: index);
        }

        // Regular element
        // Generate a view ID if needed
        final viewId = node.nativeViewId ?? _generateViewId();

        // Store the node
        node.nativeViewId = viewId;
        _nodeTree[viewId] = node;

        // Create the native view
        _performanceMonitor.startTimer('create_native_view');
        final created =
            await _nativeBridge.createView(viewId, node.type, node.props);
        _performanceMonitor.endTimer('create_native_view');

        if (!created) {
          developer.log('Failed to create native view', name: 'VDom');
          return "";
        }

        // Attach to parent
        _performanceMonitor.startTimer('attach_view');
        await _nativeBridge.attachView(viewId, parentId, index);
        _performanceMonitor.endTimer('attach_view');

        // Register event listeners
        final eventProps = node.props.entries
            .where((entry) =>
                entry.key.startsWith('on') && entry.value is Function)
            .map((entry) => entry.key.substring(2).toLowerCase())
            .toList();

        if (eventProps.isNotEmpty) {
          _performanceMonitor.startTimer('add_event_listeners');
          await _nativeBridge.addEventListeners(viewId, eventProps);
          _performanceMonitor.endTimer('add_event_listeners');
        }

        // Render children
        final childIds = <String>[];

        _performanceMonitor.startTimer('render_children');
        for (int i = 0; i < node.children.length; i++) {
          final childNode = node.children[i];
          final childId = await renderToNative(
            childNode,
            parentId: viewId,
            index: i,
          );

          if (childId.isNotEmpty) {
            childIds.add(childId);
          }
        }
        _performanceMonitor.endTimer('render_children');

        // Set children order
        if (childIds.isNotEmpty) {
          _performanceMonitor.startTimer('set_children');
          await _nativeBridge.setChildren(viewId, childIds);
          _performanceMonitor.endTimer('set_children');
        }

        // Call lifecycle methods after full rendering
        _callLifecycleMethodsIfNeeded(node);

        return viewId;
      }

      // Empty nodes don't render
      return "";
    } finally {
      _performanceMonitor.endTimer('render_to_native');
    }
  }

  /// Schedule a component update for batching
  void _scheduleComponentUpdate(StatefulComponent component) {
    _pendingUpdates.add(component.instanceId);

    if (_isUpdateScheduled) return;
    _isUpdateScheduled = true;

    // Schedule updates to run after current execution using microtask for animations
    // This is important for smooth animations (runs at end of current frame)
    Future.microtask(() {
      _processPendingUpdates();
    });
  }

  /// Process all pending component updates
  Future<void> _processPendingUpdates() async {
    if (_pendingUpdates.isEmpty) {
      _isUpdateScheduled = false;
      return;
    }

    _performanceMonitor.startTimer('batch_update');

    // Copy the pending updates to allow for new ones during processing
    final updates = Set<String>.from(_pendingUpdates);
    _pendingUpdates.clear();

    // Process each pending component update
    for (final instanceId in updates) {
      final component = _findComponentById(instanceId);
      if (component != null) {
        await _updateComponent(component);
      } else {
        developer.log('Component not found for update: $instanceId',
            name: 'VDom');
        // Try to clean up stale update reference
        _pendingUpdates.remove(instanceId);
      }
    }

    _performanceMonitor.endTimer('batch_update');

    // Check if new updates were added during processing
    if (_pendingUpdates.isNotEmpty) {
      // Process new updates in next microtask to avoid deep recursion
      Future.microtask(() {
        _processPendingUpdates();
      });
    } else {
      _isUpdateScheduled = false;
    }
  }

  /// Find a component by its ID
  StatefulComponent? _findComponentById(String instanceId) {
    for (final entry in _componentInstances.entries) {
      if (entry.key == instanceId &&
          entry.value.component is StatefulComponent) {
        return entry.value.component as StatefulComponent;
      }
    }
    return null;
  }

  /// Update a component when state changes
  Future<void> _updateComponent(StatefulComponent component) async {
    developer.log('Updating component: ${component.runtimeType}', name: 'VDom');

    _performanceMonitor.startTimer('update_component');

    try {
      // Reset hook state for the next render
      component.prepareForRender();

      // Render the component
      _performanceMonitor.startTimer('component_render');
      final newNode = component.render();
      _performanceMonitor.endTimer('component_render');

      // Find the component node in the tree
      final componentNode = _findComponentNode(component);
      if (componentNode == null) {
        developer.log(
            'Component node not found for ${component.runtimeType}, unable to update UI',
            name: 'VDom');
        return;
      }

      developer.log(
          'Found component node, updating UI for ${component.runtimeType}',
          name: 'VDom');

      // Store the previous rendered node
      final previousNode = componentNode.renderedNode;

      // Set the new rendered node
      componentNode.renderedNode = newNode;

      // If we have a previous node, reconcile it with the new one
      if (previousNode != null) {
        _performanceMonitor.startTimer('reconcile');
        await _reconciler.reconcile(previousNode, newNode);
        _performanceMonitor.endTimer('reconcile');
      } else {
        // If no previous node, this might be the first render or a node that was removed
        // Attempt to render or re-render it to native
        if (componentNode.nativeViewId != null) {
          final parentId = _findParentViewId(componentNode);
          if (parentId != null) {
            await renderToNative(newNode, parentId: parentId, index: 0);
          }
        }
      }

      // Mark as mounted if not already
      if (!component.isMounted) {
        component.componentDidMount();
      } else {
        component.componentDidUpdate({});
      }
    } catch (e, stack) {
      developer.log('Error updating component: $e',
          name: 'VDom', error: e, stackTrace: stack);
    } finally {
      _performanceMonitor.endTimer('update_component');
    }
  }

  /// Find the component node for a component
  ComponentNode? _findComponentNode(Component component) {
    // First try the direct lookup from the component nodes map
    if (_componentNodes.containsKey(component.instanceId)) {
      return _componentNodes[component.instanceId];
    }

    return null;
  }

  /// Handle events from native UI
  void _handleNativeEvent(
      String viewId, String eventType, Map<String, dynamic> eventData) {
    _performanceMonitor.startTimer('handle_native_event');

    final node = _nodeTree[viewId];
    if (node == null) {
      _performanceMonitor.endTimer('handle_native_event');
      return;
    }

    if (node is VDomElement) {
      // Convert event name to prop name (e.g., 'press' -> 'onPress')
      final propName =
          'on${eventType[0].toUpperCase()}${eventType.substring(1)}';

      // Call the handler if it exists
      if (node.props.containsKey(propName) &&
          node.props[propName] is Function) {
        _performanceMonitor.startTimer('event_handler');
        final handler = node.props[propName] as Function;
        handler(eventData);
        _performanceMonitor.endTimer('event_handler');
      }
    }

    _performanceMonitor.endTimer('handle_native_event');
  }

  /// Generate a unique view ID
  String _generateViewId() {
    return 'view_${_nextViewIdCounter++}';
  }

  /// Call lifecycle methods for components
  void _callLifecycleMethodsIfNeeded(VDomNode node) {
    // Find component owning this node by traversing up the tree
    VDomNode? current = node;
    ComponentNode? componentNode;

    while (current != null) {
      if (current is ComponentNode) {
        componentNode = current;
        break;
      }
      current = current.parent;
    }

    if (componentNode != null) {
      final component = componentNode.component;
      final instance = _componentInstances[component.instanceId];

      if (instance != null && !instance.isMounted) {
        if (component is StatefulComponent) {
          // Call componentDidMount
          component.componentDidMount();
        } else {
          // For non-stateful components, just call the method
          component.componentDidMount();
        }

        instance.isMounted = true;
      }
    }
  }

  /// Get performance data
  Map<String, dynamic> getPerformanceData() {
    return _performanceMonitor.getMetricsReport();
  }

  /// Find the nearest error boundary for a node
  ErrorBoundary? _findNearestErrorBoundary(VDomNode node) {
    VDomNode? current = node;

    while (current != null) {
      if (current is ComponentNode && current.component is ErrorBoundary) {
        return current.component as ErrorBoundary;
      }
      current = current.parent;
    }

    return null;
  }

  /// Get provider chain for context lookup
  List<String> _getProviderChain(VDomNode node) {
    final result = <String>[];
    VDomNode? current = node;

    while (current != null) {
      if (current is VDomElement &&
          current.type == 'ContextProvider' &&
          current.nativeViewId != null) {
        result.add(current.nativeViewId!);
      }
      current = current.parent;
    }

    return result;
  }

  /// Helper method to find parent view ID for a component node
  String? _findParentViewId(ComponentNode node) {
    VDomNode? current = node.parent;
    while (current != null) {
      if (current.nativeViewId != null) {
        return current.nativeViewId;
      }
      current = current.parent;
    }
    return "root"; // Fallback to root if no parent found
  }
}

/// Represents an instance of a component
class ComponentInstance {
  /// The component
  final Component component;

  /// Reference to the VDOM
  final VDom vdomRef;

  /// Previous rendered tree
  VDomNode? previousNode;

  /// Whether component is mounted
  bool isMounted = false;

  /// Whether we've attached an update listener
  bool hasUpdateListener = false;

  ComponentInstance({
    required this.component,
    required this.vdomRef,
  });
}
