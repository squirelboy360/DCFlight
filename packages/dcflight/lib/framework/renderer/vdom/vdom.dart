import 'dart:async';
import 'dart:developer' as developer;

import 'package:dcflight/framework/renderer/native_bridge/dispatcher.dart' show NativeBridgeFactory, PlatformDispatcher;
import 'package:dcflight/framework/renderer/vdom/component/component.dart';
import 'package:dcflight/framework/renderer/vdom/component/component_node.dart';
import 'package:dcflight/framework/renderer/vdom/component/context.dart';
import 'package:dcflight/framework/renderer/vdom/component/error_boundary.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'vdom_node.dart';
import 'reconciler.dart';
import 'fragment.dart';

/// Performance monitoring for VDOM operations
class PerformanceMonitor {
  /// Map of timers by name
  final Map<String, _Timer> _timers = {};

  /// Map of metrics by name
  final Map<String, _Metric> _metrics = {};

  /// Start a timer with the given name
  void startTimer(String name) {
    _timers[name] = _Timer(DateTime.now());
  }

  /// End a timer with the given name
  void endTimer(String name) {
    final timer = _timers[name];
    if (timer == null) return;

    final duration = DateTime.now().difference(timer.startTime);

    // Update or create the metric
    final metric = _metrics[name] ?? _Metric(name);
    metric.count++;
    metric.totalDuration += duration.inMicroseconds;
    metric.maxDuration = duration.inMicroseconds > metric.maxDuration
        ? duration.inMicroseconds
        : metric.maxDuration;
    metric.minDuration =
        metric.minDuration == 0 || duration.inMicroseconds < metric.minDuration
            ? duration.inMicroseconds
            : metric.minDuration;

    _metrics[name] = metric;

    // Remove the timer
    _timers.remove(name);
  }

  /// Get a metrics report as a map
  Map<String, dynamic> getMetricsReport() {
    final report = <String, dynamic>{};

    for (final metric in _metrics.values) {
      report[metric.name] = {
        'count': metric.count,
        'totalMs': metric.totalDuration / 1000.0,
        'avgMs': metric.count > 0
            ? (metric.totalDuration / metric.count) / 1000.0
            : 0,
        'maxMs': metric.maxDuration / 1000.0,
        'minMs': metric.minDuration / 1000.0,
      };
    }

    return report;
  }

  /// Reset all metrics
  void reset() {
    _timers.clear();
    _metrics.clear();
  }
}

/// Internal timer class
class _Timer {
  final DateTime startTime;
  _Timer(this.startTime);
}

/// Internal metric class
class _Metric {
  final String name;
  int count = 0;
  int totalDuration = 0;
  int maxDuration = 0;
  int minDuration = 0;

  _Metric(this.name);
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

  ComponentInstance({
    required this.component,
    required this.vdomRef,
  });
}

/// Virtual DOM implementation
class VDom {
  /// Native bridge for UI operations
  late final PlatformDispatcher _nativeBridge;

  /// Whether the VDom is ready for use
  final Completer<void> _readyCompleter = Completer<void>();

  /// Counter for generating view IDs
  int _viewIdCounter = 1;

  /// Map of component instances by ID
  final Map<String, Component> _components = {};

  /// Enriched component instances with additional tracking
  final Map<String, ComponentInstance> _componentInstances = {};

  /// Map of component nodes by component instance ID
  final Map<String, ComponentNode> _componentNodes = {};

  /// Map of view IDs to VDomNodes
  final Map<String, VDomNode> _nodesByViewId = {};

  /// Map to track detached views for potential reuse
  final Map<String, VDomNode> _detachedNodes = {};
  
  /// Performance monitoring
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  /// Current batch update
  final Set<String> _pendingUpdates = {};

  /// Whether an update is scheduled
  bool _isUpdateScheduled = false;

  /// Context registry
  final ContextRegistry _contextRegistry = ContextRegistry();

  /// Error boundaries
  final Map<String, ErrorBoundary> _errorBoundaries = {};

  /// Root component node (for main application)
  ComponentNode? rootComponentNode;

  /// Reconciliation engine
  late final Reconciler _reconciler;

  /// Create a new VDom instance
  VDom() {
    _initialize();
  }

  /// Initialize the VDom
  Future<void> _initialize() async {
    try {
      _performanceMonitor.startTimer('vdom_initialize');

      // Create native bridge
      _nativeBridge = NativeBridgeFactory.create();

      // Initialize bridge
      final success = await _nativeBridge.initialize();

      if (!success) {
        throw Exception('Failed to initialize native bridge');
      }

      // Register event handler
      _nativeBridge.setEventHandler(_handleNativeEvent);

      // Create reconciler
      _reconciler = Reconciler(this);

      // Mark as ready
      _readyCompleter.complete();

      developer.log('VDom initialized', name: 'VDom');
      _performanceMonitor.endTimer('vdom_initialize');
    } catch (e) {
      _readyCompleter.completeError(e);
      developer.log('Failed to initialize VDom: $e', name: 'VDom', error: e);
    }
  }

  /// Future that completes when VDom is ready
  Future<void> get isReady => _readyCompleter.future;

  /// Generate a unique view ID
  String _generateViewId() {
    return 'view_${_viewIdCounter++}';
  }

  /// Create a component node
  ComponentNode createComponent(Component component) {
    final node = ComponentNode(component: component);

    // Store component and node by component ID
    _components[component.instanceId] = component;
    _componentNodes[component.instanceId] = node;

    // Create and register a component instance
    _componentInstances[component.instanceId] = ComponentInstance(
      component: component,
      vdomRef: this,
    );

    // Set up update scheduling for stateful components
    if (component is StatefulComponent) {
      component.scheduleUpdate = () => _scheduleComponentUpdate(component);
    }

    return node;
  }

  /// Handle a native event
  void _handleNativeEvent(
      String viewId, String eventType, Map<String, dynamic> eventData) {
    _performanceMonitor.startTimer('handle_native_event');

    final node = _nodesByViewId[viewId];
    if (node == null) {
      developer.log('⚠️ No node found for viewId: $viewId', name: 'VDom');
      _performanceMonitor.endTimer('handle_native_event');
      return;
    }

    if (node is VDomElement) {
      // First try direct event matching (used by many native components)
      if (node.props.containsKey(eventType) && node.props[eventType] is Function) {
        _performanceMonitor.startTimer('event_handler');
        final handler = node.props[eventType] as Function;
        
        try {
          if (handler is Function(Map<String, dynamic>)) {
            handler(eventData);
          } else if (handler is Function()) {
            handler();
          } else {
            Function.apply(handler, [], {});
          }
        } catch (e, stack) {
          developer.log('❌ Error executing event handler: $e', 
              name: 'VDom', error: e, stackTrace: stack);
        }
        
        _performanceMonitor.endTimer('event_handler');
        _performanceMonitor.endTimer('handle_native_event');
        return;
      }

      // Then try canonical "onEventName" format
      final propName =
          'on${eventType[0].toUpperCase()}${eventType.substring(1)}';

      // Call the handler if it exists
      if (node.props.containsKey(propName) &&
          node.props[propName] is Function) {
        _performanceMonitor.startTimer('event_handler');
        final handler = node.props[propName] as Function;
        
        try {
          if (handler is Function(Map<String, dynamic>)) {
            handler(eventData);
          } else if (handler is Function()) {
            handler();
          } else {
            Function.apply(handler, [], {});
          }
        } catch (e, stack) {
          developer.log('❌ Error executing event handler: $e', 
              name: 'VDom', error: e, stackTrace: stack);
        }
        
        _performanceMonitor.endTimer('event_handler');
      }
    }
    
    _performanceMonitor.endTimer('handle_native_event');
  }

  /// Create a new element
  VDomElement createElement(
    String type, {
    Map<String, dynamic>? props,
    List<VDomNode>? children,
    String? key,
  }) {
    return VDomElement(
      type: type,
      props: props ?? {},
      children: children ?? [],
      key: key,
    );
  }

  /// Render a node to native UI
  Future<String?> renderToNative(VDomNode node,
      {String? parentId, int? index}) async {
    await isReady;

    _performanceMonitor.startTimer('render_to_native');
    try {
      // Handle Fragment nodes
      if (node is Fragment) {
        // Just render children directly to parent
        final childIds = <String>[];
        int childIndex = index ?? 0;

        for (final child in node.children) {
          final childId = await renderToNative(
            child,
            parentId: parentId,
            index: childIndex++,
          );

          if (childId != null && childId.isNotEmpty) {
            childIds.add(childId);
          }
        }

        return ""; // Fragments don't have their own ID
      }

      if (node is ComponentNode) {
        try {
          return await _renderComponentToNative(node,
              parentId: parentId, index: index);
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
      } else if (node is VDomElement) {
        return await _renderElementToNative(node,
            parentId: parentId, index: index);
      }

      return null;
    } finally {
      _performanceMonitor.endTimer('render_to_native');
    }
  }

  /// Render a component to native UI
  Future<String?> _renderComponentToNative(ComponentNode componentNode,
      {String? parentId, int? index}) async {
    final component = componentNode.component;
    final componentInstance = _componentInstances[component.instanceId];

    // Set the update function
    if (component is StatefulComponent) {
      component.scheduleUpdate = () => _scheduleComponentUpdate(component);
    }

    // Reset hook state before render for stateful components
    if (component is StatefulComponent) {
      component.prepareForRender();
    }

    // Render the component
    _performanceMonitor.startTimer('component_render');
    final renderedNode = component.render();
    _performanceMonitor.endTimer('component_render');

    componentNode.renderedNode = renderedNode;
    renderedNode.parent = componentNode;

    // Render the rendered node
    final viewId =
        await renderToNative(renderedNode, parentId: parentId, index: index);

    // Store the view ID
    componentNode.contentViewId = viewId;

    // Mark as mounted if not already
    if (componentInstance != null && !componentInstance.isMounted) {
      // Call lifecycle method
      component.componentDidMount();
      componentInstance.isMounted = true;
    }

    // Register error boundary if applicable
    if (component is ErrorBoundary) {
      _errorBoundaries[component.instanceId] = component;
    }

    // Run effects after render for stateful components
    if (component is StatefulComponent &&
        componentInstance?.isMounted == true) {
      component.runEffectsAfterRender();
    }

    return viewId;
  }

  /// Render an element to native UI
  Future<String?> _renderElementToNative(VDomElement element,
      {String? parentId, int? index}) async {
    // Special handling for context provider
    if (element.type == 'ContextProvider') {
      final contextId = element.props['contextId'] as String;
      final value = element.props['value'];
      final providerId = 'provider_${_viewIdCounter++}';

      // Register context value
      _contextRegistry.setContextValue(contextId, providerId, value);

      // Render children
      if (element.children.isNotEmpty) {
        return await renderToNative(element.children[0],
            parentId: parentId, index: index);
      }
      return "";
    }

    // Special handling for context consumer
    if (element.type == 'ContextConsumer') {
      final contextId = element.props['contextId'] as String;
      final consumer = element.props['consumer'] as Function;
      final providerChain = _getProviderChain(element);

      // Get context value
      final value = _contextRegistry.getContextValue(contextId, providerChain);

      // Build child using consumer function
      final child = consumer(value);

      // Render the child
      return await renderToNative(child, parentId: parentId, index: index);
    }

    // Check if this is a detached node we can reuse
    String? viewId = element.nativeViewId;
    
    // Get a cached/detached node if same type
    if (viewId == null && element.key != null) {
      String cacheKey = '${element.type}-${element.key}';
      VDomNode? detachedNode = _detachedNodes[cacheKey];
      
      if (detachedNode is VDomElement && detachedNode.type == element.type) {
        // Reuse the detached node's ID
        viewId = detachedNode.nativeViewId;
        
        // Clean up the detached node entry
        _detachedNodes.remove(cacheKey);
        
        // Update node tracking (replace old node with new one)
        if (viewId != null) {
          _nodesByViewId.remove(viewId);
          element.nativeViewId = viewId;
          _nodesByViewId[viewId] = element;
          
          // Update props on the reused view
          _performanceMonitor.startTimer('update_reused_view');
          await _nativeBridge.updateView(viewId, element.props);
          _performanceMonitor.endTimer('update_reused_view');
          
          // If parent is specified, reattach to parent
          if (parentId != null) {
            await attachView(viewId, parentId, index ?? 0);
          }
          
          // Now reconcile children
          await _reconcileChildrenForReusedView(detachedNode, element, viewId);
          
          // Register event listeners if needed
          if (element.eventTypes.isNotEmpty) {
            await _nativeBridge.addEventListeners(viewId, element.eventTypes);
          }
          
          return viewId;
        }
      }
    }

    // Generate a new view ID if we couldn't reuse
    viewId = element.nativeViewId ?? _generateViewId();

    // Store map from node to view ID
    _nodesByViewId[viewId] = element;
    element.nativeViewId = viewId;

    // Create the view
    _performanceMonitor.startTimer('create_native_view');
    final success =
        await _nativeBridge.createView(viewId, element.type, element.props);
    _performanceMonitor.endTimer('create_native_view');

    if (!success) {
      developer.log('Failed to create view: $viewId of type ${element.type}',
          name: 'VDom');
      return null;
    }

    // If parent is specified, attach to parent
    if (parentId != null) {
      _performanceMonitor.startTimer('attach_view');
      await attachView(viewId, parentId, index ?? 0);
      _performanceMonitor.endTimer('attach_view');
    }

    // Register event listeners
    final eventTypes = element.eventTypes;
    if (eventTypes.isNotEmpty) {
      _performanceMonitor.startTimer('add_event_listeners');
      await _nativeBridge.addEventListeners(viewId, eventTypes);
      _performanceMonitor.endTimer('add_event_listeners');
    }

    // Render children
    _performanceMonitor.startTimer('render_children');
    final childIds = <String>[];

    for (var i = 0; i < element.children.length; i++) {
      final childId =
          await renderToNative(element.children[i], parentId: viewId, index: i);

      if (childId != null && childId.isNotEmpty) {
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
    _callLifecycleMethodsIfNeeded(element);

    return viewId;
  }
  
  /// Reconcile children for a reused view
  Future<void> _reconcileChildrenForReusedView(
      VDomElement oldElement, VDomElement newElement, String viewId) async {
    // Process each child using the reconciler
    final childIds = <String>[];
    
    for (var i = 0; i < newElement.children.length; i++) {
      final newChild = newElement.children[i];
      
      // Find matching old child if possible
      VDomNode? oldChild;
      if (i < oldElement.children.length) {
        oldChild = oldElement.children[i];
      }
      
      if (oldChild != null) {
        // Reconcile existing child
        await _reconciler.reconcile(oldChild, newChild);
        
        // Add to child IDs if it has a native view
        if (newChild.nativeViewId != null) {
          childIds.add(newChild.nativeViewId!);
        }
      } else {
        // Render new child
        final childId = await renderToNative(newChild, parentId: viewId, index: i);
        if (childId != null && childId.isNotEmpty) {
          childIds.add(childId);
        }
      }
    }
    
    // Set children order
    if (childIds.isNotEmpty) {
      await _nativeBridge.setChildren(viewId, childIds);
    }
  }

  /// Calculate and apply layout
  Future<void> calculateAndApplyLayout({double? width, double? height}) async {
    _performanceMonitor.startTimer('native_layout_calculation');
    final success = await _nativeBridge.calculateLayout();
    _performanceMonitor.endTimer('native_layout_calculation');

    if (!success) {
      developer.log('⚠️ Native layout calculation failed', name: 'VDom');
    }
  }

  /// Schedule a component update for batching
  void _scheduleComponentUpdate(StatefulComponent component) {
    _pendingUpdates.add(component.instanceId);

    if (_isUpdateScheduled) return;
    _isUpdateScheduled = true;

    // Schedule updates to run after current execution using microtask for animations
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
        await _updateComponent(component.instanceId);
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
    for (final entry in _components.entries) {
      if (entry.key == instanceId && entry.value is StatefulComponent) {
        return entry.value as StatefulComponent;
      }
    }
    return null;
  }

  /// Update a component
  Future<void> _updateComponent(String componentId) async {
    if (!_components.containsKey(componentId) ||
        !_componentNodes.containsKey(componentId)) {
      return;
    }

    final component = _components[componentId]!;
    final componentNode = _componentNodes[componentId]!;

    // Handle stateful components
    if (component is StatefulComponent) {
      // Reset hook state before render but preserve values
      component.prepareForRender();
    }

    // Re-render the component
    final newRenderedNode = component.render();
    final oldRenderedNode = componentNode.renderedNode;

    // Update the rendered node
    componentNode.renderedNode = newRenderedNode;
    newRenderedNode.parent = componentNode;

    // Reconcile nodes
    if (oldRenderedNode != null) {
      _performanceMonitor.startTimer('reconcile');
      await _reconciler.reconcile(oldRenderedNode, newRenderedNode);
      _performanceMonitor.endTimer('reconcile');
    } else if (componentNode.contentViewId != null) {
      // If no previous node but we have a content view ID, this might be a special case
      // Handle by re-rendering to native
      final parentId = _findParentViewId(componentNode);
      if (parentId != null) {
        renderToNative(newRenderedNode, parentId: parentId, index: 0);
      }
    }

    // Update component lifecycle
    if (component is StatefulComponent) {
      component.componentDidUpdate({});
      component.runEffectsAfterRender();
    }
  }

  /// Find parent view ID for a component node
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
        component.componentDidMount();
        instance.isMounted = true;
      }
    }
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

  /// Update a view's properties
  Future<bool> updateView(String viewId, Map<String, dynamic> props) async {
    return await _nativeBridge.updateView(viewId, props);
  }

  /// Delete a view
  Future<bool> deleteView(String viewId) async {
    try {
      // Get the node before deletion for potential caching
      final node = _nodesByViewId[viewId];
      
      final result = await _nativeBridge.deleteView(viewId);
      if (result) {
        _nodesByViewId.remove(viewId);
        
        // Cache node for potential reuse if it has a key
        if (node is VDomElement && node.key != null) {
          String cacheKey = '${node.type}-${node.key}';
          _detachedNodes[cacheKey] = node;
          developer.log('Cached node $viewId with key ${node.key} for reuse', name: 'VDom');
        }
      }
      return result;
    } catch (e) {
      developer.log('Error deleting view $viewId: $e', name: 'VDom');
      return false;
    }
  }

  /// Set the children of a view
  Future<bool> setChildren(String viewId, List<String> childrenIds) async {
    return await _nativeBridge.setChildren(viewId, childrenIds);
  }

  /// Add a node to the node tree
  void addNodeToTree(String viewId, VDomNode node) {
    _nodesByViewId[viewId] = node;
    node.nativeViewId = viewId;
  }

  /// Remove a node from the node tree
  void removeNodeFromTree(String viewId) {
    final node = _nodesByViewId[viewId];
    if (node != null) {
      node.nativeViewId = null;
      _nodesByViewId.remove(viewId);
    }
  }

  /// Attach a child view to a parent view at specific index
  Future<bool> attachView(String childId, String parentId, int index) async {
    return await _nativeBridge.attachView(childId, parentId, index);
  }

  /// Detach a view from its parent (without deleting it)
  Future<bool> detachView(String viewId) async {
    try {
      // Get the node before detachment
      final node = _nodesByViewId[viewId];
      
      // Use the native bridge to detach the view
      final result = await _nativeBridge.detachView(viewId);
      
      // Cache the node for potential reuse if it has a key and detachment was successful
      if (result && node is VDomElement && node.key != null) {
        String cacheKey = '${node.type}-${node.key}';
        _detachedNodes[cacheKey] = node;
        developer.log('🔄 Detached and cached node $viewId with key ${node.key}', name: 'VDom');
      } else if (result) {
        developer.log('🔄 Detached node $viewId (no caching)', name: 'VDom');
      }
      
      return result;
    } catch (e) {
      developer.log('❌ Error detaching view $viewId: $e', name: 'VDom');
      return false;
    }
  }

  /// Get performance data
  Map<String, dynamic> getPerformanceData() {
    return _performanceMonitor.getMetricsReport();
  }

  /// Reset performance metrics
  void resetPerformanceMetrics() {
    _performanceMonitor.reset();
  }

  /// Find a node by ID
  VDomNode? findNodeById(String id) {
    // Check direct mapping
    return _nodesByViewId[id];
  }
  
  /// Purge all cached/detached nodes to force fresh rendering
  void purgeDetachedNodes() {
    int count = _detachedNodes.length;
    _detachedNodes.clear();
    developer.log('🧹 Purged $count detached nodes from cache', name: 'VDom');
  }
}
