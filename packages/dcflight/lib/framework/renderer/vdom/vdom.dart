import 'dart:async';
import 'dart:developer' as developer;

import '../../protocol/context_registry.dart';
import '../native_bridge/dispatcher.dart';
import '../monitor/performance_monitor.dart';

import 'vdom_node.dart';
import 'vdom_element.dart';
import 'reconciler.dart';

/// Virtual DOM implementation that directly supports hook-based elements
class VDom {
  /// Native bridge for UI operations
  late final PlatformDispatcher _nativeBridge;

  /// Whether the VDom is ready for use
  final Completer<void> _readyCompleter = Completer<void>();

  /// Counter for generating view IDs
  int _viewIdCounter = 1;

  /// Map of view IDs to VDomNodes
  final Map<String, VDomNode> _nodesByViewId = {};

  /// Map to track detached views for potential reuse
  final Map<String, VDomNode> _detachedNodes = {};

  /// Performance monitoring
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  /// Current batch update for elements
  final Set<String> _pendingElementUpdates = {};

  /// Whether an update is scheduled
  bool _isUpdateScheduled = false;

  /// Context registry
  final ContextRegistry _contextRegistry = ContextRegistry();

  /// Root element node (for main application)
  VDomElement? rootElement;

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

      developer.log('EnhancedVDom initialized', name: 'VDom');
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

  /// Generate a unique element instance ID
  String _generateElementId() {
    return 'element_${_viewIdCounter++}';
  }

  /// Create an element
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

  /// Create an element with hooks enabled
  VDomElement createHookElement(
    String type, {
    Map<String, dynamic>? props,
    List<VDomNode>? children,
    String? key,
  }) {
    final element = createElement(type, props: props, children: children, key: key);
    
    // Assign a unique instance ID for hook tracking
    (element as dynamic).instanceId = _generateElementId();
    
    // Set up update scheduling
    element.scheduleUpdate = () => _scheduleElementUpdate(element);
    
    return element;
  }

  /// Schedule an element update for batching
  void _scheduleElementUpdate(VDomElement element) {
    _pendingElementUpdates.add(element.instanceId);

    if (_isUpdateScheduled) return;
    _isUpdateScheduled = true;

    // Schedule updates to run after current execution using microtask for animations
    Future.microtask(() {
      _processAllPendingUpdates();
    });
  }

  /// Process all pending updates
  Future<void> _processAllPendingUpdates() async {
    if (_pendingElementUpdates.isEmpty) {
      _isUpdateScheduled = false;
      return;
    }

    _performanceMonitor.startTimer('batch_update');

    // Process Element updates
    if (_pendingElementUpdates.isNotEmpty) {
      // Copy the pending updates to allow for new ones during processing
      final updates = Set<String>.from(_pendingElementUpdates);
      _pendingElementUpdates.clear();

      // Process each pending element update
      for (final instanceId in updates) {
        await _updateElement(instanceId);
      }
    }

    _performanceMonitor.endTimer('batch_update');

    // Check if new updates were added during processing
    if (_pendingElementUpdates.isNotEmpty) {
      // Process new updates in next microtask to avoid deep recursion
      Future.microtask(() {
        _processAllPendingUpdates();
      });
    } else {
      _isUpdateScheduled = false;
    }
  }

  /// Update an element directly (for hook-based updates)
  Future<void> _updateElement(String elementId) async {
    final node = _nodesByViewId.entries
        .firstWhere((entry) => entry.value is VDomElement && 
                              (entry.value as VDomElement).instanceId == elementId,
            orElse: () => MapEntry('', EmptyVDomNode()))
        .value;

    if (node is! VDomElement) {
      return;
    }

    final element = node;
    developer.log('Updating element: ${element.type}',
        name: 'VDom');

    // Reset hook state before render but preserve values
    element.prepareForRender();

    // We need to re-render the element, which means getting a fresh copy
    // and then reconciling with the current version
    final newElement = element.clone() as VDomElement;
    
    // Ensure the new element has the same instanceId
    (newElement as dynamic).instanceId = element.instanceId;
    
    // Set up the schedule update function
    newElement.scheduleUpdate = () => _scheduleElementUpdate(newElement);

    // Reconcile with the current version
    _performanceMonitor.startTimer('reconcile');
    await _reconciler.reconcile(element, newElement);
    _performanceMonitor.endTimer('reconcile');

    // Run effects after update
    element.runEffectsAfterRender();

    // If this was a root element, trigger layout calculation
    if (element.parent == null || element == rootElement) {
      await calculateAndApplyLayout();
    }
  }

  /// Handle events from native
  void _handleNativeEvent(String viewId, String type, Map<String, dynamic> eventData) {
    // Get the node associated with this view
    final node = _nodesByViewId[viewId];
    if (node == null) {
      developer.log('No node found for viewId: $viewId', name: 'VDom');
      return;
    }

    if (node is VDomElement) {
      // Process the event for the element
      _handleElementEvent(node, type, eventData);
    }
  }

  /// Handle element events
  void _handleElementEvent(VDomElement element, String type, Map<String, dynamic> eventData) {
    // Check if the element has a handler for this event type
    final handlerName = 'on${type[0].toUpperCase()}${type.substring(1)}';
    
    if (element.props.containsKey(handlerName)) {
      final handler = element.props[handlerName];
      
      if (handler is Function) {
        // Call the handler with the event data
        handler(eventData);
      }
    }
  }

  /// Add tracking of node to our internal maps
  void addNodeToTree(String viewId, VDomNode node) {
    _nodesByViewId[viewId] = node;
  }

  /// Remove tracking of node from our internal maps
  void removeNodeFromTree(String viewId) {
    _nodesByViewId.remove(viewId);
  }

  /// Finds a node with the specified ID
  VDomNode? findNodeById(String viewId) {
    return _nodesByViewId[viewId];
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

  /// Render to native UI
  Future<String?> renderToNative(VDomNode node, {String? parentId, int? index}) async {
    if (node is VDomElement) {
      return await _renderElementToNative(node, parentId: parentId, index: index);
    } else if (node is EmptyVDomNode) {
      return null;
    } else {
      developer.log('Unsupported node type: ${node.runtimeType}', name: 'VDom');
      return null;
    }
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
    
    // Set up update scheduling for element hooks
    element.scheduleUpdate = () => _scheduleElementUpdate(element);

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
    
    // Set the updated children order
    if (childIds.isNotEmpty) {
      await _nativeBridge.setChildren(viewId, childIds);
    }
    
    // Remove any extra old children that aren't in the new list
    for (var i = newElement.children.length; i < oldElement.children.length; i++) {
      final oldChild = oldElement.children[i];
      
      if (oldChild.nativeViewId != null) {
        await _nativeBridge.deleteView(oldChild.nativeViewId!);
      }
    }
  }

  /// Call lifecycle methods for elements
  void _callLifecycleMethodsIfNeeded(VDomNode node) {
    // Check if this is a VDomElement with hooks
    if (node is VDomElement) {
      // Call didMount directly on the element
      if (!node.isMounted) {
        node.didMount();
        // Run any effects after mounting
        node.runEffectsAfterRender();
      }
    }
  }

  /// Attach a view to a parent
  Future<bool> attachView(String viewId, String parentId, int index) async {
    return await _nativeBridge.attachView(viewId, parentId, index);
  }

  /// Detach a view from its parent
  Future<bool> detachView(String viewId) async {
    return await _nativeBridge.detachView(viewId);
  }

  /// Set children for a view
  Future<bool> setChildren(String parentId, List<String> childIds) async {
    return await _nativeBridge.setChildren(parentId, childIds);
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
          final cacheKey = '${node.type}-${node.key}';
          _detachedNodes[cacheKey] = node;
        }
      }
      return result;
    } catch (e) {
      developer.log('Failed to delete view: $e', name: 'VDom');
      return false;
    }
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

  /// Purge all detached nodes from cache
  void purgeDetachedNodesCache() {
    final count = _detachedNodes.length;
    _detachedNodes.clear();
    developer.log('🧹 Purged $count detached nodes from cache', name: 'VDom');
  }
}
