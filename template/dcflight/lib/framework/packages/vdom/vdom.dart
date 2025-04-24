// ignore_for_file: unused_local_variable, unused_field

import 'dart:async';
import 'dart:developer' as developer;


import 'package:dcflight/framework/packages/native_bridge/dispatcher.dart' show NativeBridgeFactory, PlatformDispatcher;
import 'package:dcflight/framework/packages/vdom/component/component.dart';
import 'package:dcflight/framework/packages/vdom/component/component_node.dart';
import 'package:dcflight/framework/packages/vdom/component/context.dart';
import 'package:dcflight/framework/packages/vdom/component/error_boundary.dart';
import 'package:dcflight/framework/packages/vdom/vdom_element.dart';
import 'package:dcflight/framework/utilities/screen_utilities.dart';

import '../../constants/yoga_enums.dart';
import '../../constants/layout_properties.dart';
import 'vdom_node.dart';

import 'reconciler.dart';

import 'fragment.dart';

import 'vdom_node_sync.dart';

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

  /// Whether we've attached an update listener
  bool hasUpdateListener = false;

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

  /// Map of node IDs from creation to view IDs after creation
  final Map<String, String> _nodeIdToViewId = {};

  /// Root component node (for main application)
  ComponentNode? rootComponentNode;

  /// Reconciliation engine
  late final Reconciler _reconciler;

  /// Node synchronization manager
  late final VDomNodeSync _nodeSync;


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

      // Initialize node sync
      _nodeSync = VDomNodeSync(this, _nativeBridge);

  

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
      // Try explicit events map first
      if (node.events != null &&
          node.events!.containsKey(eventType) &&
          node.events![eventType] is Function) {
        _performanceMonitor.startTimer('event_handler');
        final handler = node.events![eventType] as Function;
        
        // FIXED: Handle different function signatures
        try {
          if (handler is Function(Map<String, dynamic>)) {
            // Function expects event data
            handler(eventData);
            developer.log('✅ Executed handler with event data for $eventType on $viewId', name: 'VDom');
          } else if (handler is Function()) {
            // Function takes no parameters
            handler();
            developer.log('✅ Executed handler with no parameters for $eventType on $viewId', name: 'VDom');
          } else {
            // Try a more general approach
            Function.apply(handler, [], {});
            developer.log('✅ Executed handler using Function.apply for $eventType on $viewId', name: 'VDom');
          }
        } catch (e, stack) {
          developer.log('❌ Error executing event handler: $e', 
              name: 'VDom', error: e, stackTrace: stack);
        }
        
        _performanceMonitor.endTimer('event_handler');
        _performanceMonitor.endTimer('handle_native_event');
        return;
      }

      // If not found in events map, try props with "onX" format
      // Convert event name to prop name (e.g., 'press' -> 'onPress')
      final propName =
          'on${eventType[0].toUpperCase()}${eventType.substring(1)}';

      // Call the handler if it exists
      if (node.props.containsKey(propName) &&
          node.props[propName] is Function) {
        _performanceMonitor.startTimer('event_handler');
        final handler = node.props[propName] as Function;
        
        // FIXED: Handle different function signatures
        try {
          developer.log('🔔 Executing handler for $propName on $viewId with data: $eventData', name: 'VDom');
          
          if (handler is Function(Map<String, dynamic>)) {
            // Function expects event data
            handler(eventData);
            developer.log('✅ Executed handler with event data', name: 'VDom');
          } else if (handler is Function()) {
            // Function takes no parameters
            handler();
            developer.log('✅ Executed handler with no parameters', name: 'VDom');
          } else {
            // Try a more general approach
            Function.apply(handler, [], {});
            developer.log('✅ Executed handler using Function.apply', name: 'VDom');
          }
        } catch (e, stack) {
          developer.log('❌ Error executing event handler: $e', 
              name: 'VDom', error: e, stackTrace: stack);
        }
        
        _performanceMonitor.endTimer('event_handler');
      } else {
        developer.log('⚠️ No handler found for event $eventType or $propName on $viewId',
            name: 'VDom');
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
    String? tempId,
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

      // After rendering, schedule a sync if this is a significant node
      if (node is ComponentNode && node.component.typeName == 'App') {
        // This is the root app component, schedule a sync
        Future.delayed(Duration(milliseconds: 500), () {
          _nodeSync.synchronizeHierarchy(rootId: node.nativeViewId ?? 'root');
        });
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

    // Store component -> viewId mapping for quick lookups
    if (viewId != null && viewId.isNotEmpty) {
      //  _componentToViewId[component.instanceId] = viewId;
    }

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

    // Generate view ID
    final viewId = element.nativeViewId ?? _generateViewId();

    // Store map from node to view ID
    _nodesByViewId[viewId] = element;
    element.nativeViewId = viewId;

    // Extract layout props
    final layoutProps = _extractLayoutProps(element.props);

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

    // Register event listeners - modified to use eventTypes getter
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

  /// Calculate and apply layout
  Future<void> calculateAndApplyLayout({double? width, double? height}) async {
    developer.log(
        '🔥 Starting layout calculation with dimensions: ${width ?? '100%'} x ${height ?? '100%'}',
        name: 'VDom');

    // Get screen dimensions if not provided
    final screenWidth = width ?? ScreenUtilities.instance.screenWidth;
    final screenHeight = height ?? ScreenUtilities.instance.screenHeight;

    _performanceMonitor.startTimer('native_layout_calculation');

    final success = await _nativeBridge.calculateLayout();

    if (!success) {
      developer.log('⚠️ Native layout calculation failed', name: 'VDom');
      // No fallback - native side is now the only source of truth for layout
    }

    _performanceMonitor.endTimer('native_layout_calculation');

    developer.log('✅ Layout calculation delegated to native side',
        name: 'VDom');
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

    developer.log('Updating component: ${_components[componentId]!.typeName}',
        name: 'VDom');

    final component = _components[componentId]!;
    final componentNode = _componentNodes[componentId]!;

    // Handle stateful components
    if (component is StatefulComponent) {
      // FIXED: Don't call componentWillUnmount during state updates
      // This was previously causing all effects to be cleaned up prematurely
      
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

      // Schedule a hierarchy sync after significant changes
      if (component.typeName == 'App' ||
          component.typeName.contains('Screen')) {
        Future.delayed(Duration(milliseconds: 300), () {
          _nodeSync.synchronizeHierarchy(
              rootId: componentNode.nativeViewId ?? 'root');
        });
      }
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
      
      // FIXED: Run effects after update to ensure state changes take effect
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

  /// Extract layout props from all props
  LayoutProps? _extractLayoutProps(Map<String, dynamic> props) {
    // Check if any layout properties exist
    final hasLayoutProps =
        props.keys.any((key) => LayoutProps.all.contains(key));

    if (!hasLayoutProps) return null;

    // Handle string enum values that need conversion
    YogaFlexDirection? convertFlexDirection(dynamic value) {
      if (value is YogaFlexDirection) return value;
      if (value is String) {
        switch (value) {
          case 'row':
            return YogaFlexDirection.row;
          case 'column':
            return YogaFlexDirection.column;
          case 'row-reverse':
            return YogaFlexDirection.rowReverse;
          case 'column-reverse':
            return YogaFlexDirection.columnReverse;
          default:
            return null;
        }
      }
      return null;
    }

    YogaJustifyContent? convertJustifyContent(dynamic value) {
      if (value is YogaJustifyContent) return value;
      if (value is String) {
        switch (value) {
          case 'flex-start':
            return YogaJustifyContent.flexStart;
          case 'center':
            return YogaJustifyContent.center;
          case 'flex-end':
            return YogaJustifyContent.flexEnd;
          case 'space-between':
            return YogaJustifyContent.spaceBetween;
          case 'space-around':
            return YogaJustifyContent.spaceAround;
          case 'space-evenly':
            return YogaJustifyContent.spaceEvenly;
          default:
            return null;
        }
      }
      return null;
    }

    YogaAlign? convertAlign(dynamic value) {
      if (value is YogaAlign) return value;
      if (value is String) {
        switch (value) {
          case 'auto':
            return YogaAlign.auto;
          case 'flex-start':
            return YogaAlign.flexStart;
          case 'center':
            return YogaAlign.center;
          case 'flex-end':
            return YogaAlign.flexEnd;
          case 'stretch':
            return YogaAlign.stretch;
          case 'baseline':
            return YogaAlign.baseline;
          case 'space-between':
            return YogaAlign.spaceBetween;
          case 'space-around':
            return YogaAlign.spaceAround;
          default:
            return null;
        }
      }
      return null;
    }

    YogaWrap? convertFlexWrap(dynamic value) {
      if (value is YogaWrap) return value;
      if (value is String) {
        switch (value) {
          case 'nowrap':
            return YogaWrap.nowrap;
          case 'wrap':
            return YogaWrap.wrap;
          case 'wrap-reverse':
            return YogaWrap.wrapReverse;
          default:
            return null;
        }
      }
      return null;
    }

    YogaDisplay? convertDisplay(dynamic value) {
      if (value is YogaDisplay) return value;
      if (value is String) {
        switch (value) {
          case 'flex':
            return YogaDisplay.flex;
          case 'none':
            return YogaDisplay.none;
          default:
            return null;
        }
      }
      return null;
    }

    YogaPositionType? convertPositionType(dynamic value) {
      if (value is YogaPositionType) return value;
      if (value is String) {
        switch (value) {
          case 'relative':
            return YogaPositionType.relative;
          case 'absolute':
            return YogaPositionType.absolute;
          default:
            return null;
        }
      }
      return null;
    }

    YogaOverflow? convertOverflow(dynamic value) {
      if (value is YogaOverflow) return value;
      if (value is String) {
        switch (value) {
          case 'visible':
            return YogaOverflow.visible;
          case 'hidden':
            return YogaOverflow.hidden;
          case 'scroll':
            return YogaOverflow.scroll;
          default:
            return null;
        }
      }
      return null;
    }

    YogaDirection? convertDirection(dynamic value) {
      if (value is YogaDirection) return value;
      if (value is String) {
        switch (value) {
          case 'inherit':
            return YogaDirection.inherit;
          case 'ltr':
            return YogaDirection.ltr;
          case 'rtl':
            return YogaDirection.rtl;
          default:
            return null;
        }
      }
      return null;
    }

    return LayoutProps(
      width: props['width'],
      height: props['height'],
      minWidth: props['minWidth'],
      maxWidth: props['maxWidth'],
      minHeight: props['minHeight'],
      maxHeight: props['maxHeight'],
      margin: props['margin'],
      marginTop: props['marginTop'],
      marginRight: props['marginRight'],
      marginBottom: props['marginBottom'],
      marginLeft: props['marginLeft'],
      marginHorizontal: props['marginHorizontal'],
      marginVertical: props['marginVertical'],
      padding: props['padding'],
      paddingTop: props['paddingTop'],
      paddingRight: props['paddingRight'],
      paddingBottom: props['paddingBottom'],
      paddingLeft: props['paddingLeft'],
      paddingHorizontal: props['paddingHorizontal'],
      paddingVertical: props['paddingVertical'],
      left: props['left'],
      top: props['top'],
      right: props['right'],
      bottom: props['bottom'],
      position: convertPositionType(props['position']),
      flexDirection: convertFlexDirection(props['flexDirection']),
      justifyContent: convertJustifyContent(props['justifyContent']),
      alignItems: convertAlign(props['alignItems']),
      alignSelf: convertAlign(props['alignSelf']),
      alignContent: convertAlign(props['alignContent']),
      flexWrap: convertFlexWrap(props['flexWrap']),
      flex: props['flex'] is num ? props['flex'].toDouble() : props['flex'],
      flexGrow: props['flexGrow'] is num
          ? props['flexGrow'].toDouble()
          : props['flexGrow'],
      flexShrink: props['flexShrink'] is num
          ? props['flexShrink'].toDouble()
          : props['flexShrink'],
      flexBasis: props['flexBasis'],
      display: convertDisplay(props['display']),
      overflow: convertOverflow(props['overflow']),
      direction: convertDirection(props['direction']),
      borderWidth: props['borderWidth'],
    );
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

  /// Update a view's properties with resilience to app restarts
  Future<bool> updateView(String viewId, Map<String, dynamic> props) async {
    try {
      // First check if this view actually exists - critical for app restarts
      final exists = await _nativeBridge.viewExists(viewId);
      
      if (!exists) {
        developer.log("⚠️ View $viewId doesn't exist anymore - likely due to app restart", name: 'VDom');
        
        // Find the node associated with this viewId
        final node = _nodesByViewId[viewId];
        if (node == null) {
          developer.log("❌ No VDOM node found for viewId: $viewId", name: 'VDom');
          return false;
        }
        
        // Get the parent info for recreation
        VDomNode? parentNode = node.parent;
        String? parentId;
        int index = 0;
        
        // Find first parent with a native view ID
        while (parentNode != null) {
          if (parentNode.nativeViewId != null) {
            parentId = parentNode.nativeViewId;
            
            // Find index of node in parent's children
            if (parentNode is VDomElement) {
              index = parentNode.children.indexOf(node);
              if (index < 0) index = 0;
            }
            break;
          }
          parentNode = parentNode.parent;
        }
        
        // If we have parent info, try to recreate the view
        if (parentId != null && node is VDomElement) {
          developer.log("🔄 Recreating view $viewId of type ${node.type}", name: 'VDom');
          
          // Create the view with complete props
          bool success = await _nativeBridge.createView(viewId, node.type, node.props);
          
          if (success) {
            // Attach to parent
            success = await _nativeBridge.attachView(viewId, parentId, index);
            
            if (success) {
              // If the node has children, we need to recreate them too
              if (node.children.isNotEmpty) {
                developer.log("🔄 Recreating children for view $viewId", name: 'VDom');
                
                // Schedule a full subtree recreation by clearing native view IDs
                for (final child in node.getDescendants()) {
                  child.nativeViewId = null;
                }
                
                // Render all children
                final childIds = <String>[];
                int childIndex = 0;
                
                for (final child in node.children) {
                  final childId = await renderToNative(child, parentId: viewId, index: childIndex++);
                  if (childId != null && childId.isNotEmpty) {
                    childIds.add(childId);
                  }
                }
                
                // Update children order
                if (childIds.isNotEmpty) {
                  await _nativeBridge.setChildren(viewId, childIds);
                }
              }
              
              // Now apply the props update
              success = await _nativeBridge.updateView(viewId, props);
              return success;
            }
          }
          
          return false;
        } else {
          developer.log("❌ Cannot recreate view $viewId: No parent found", name: 'VDom');
          return false;
        }
      }
      
      // Normal flow - view exists, just update it
      return await _nativeBridge.updateView(viewId, props);
    } catch (e, stack) {
      developer.log("❌ Error updating view: $e", 
                  name: 'VDom', error: e, stackTrace: stack);
      return false;
    }
  }

  /// Delete a view
  Future<bool> deleteView(String viewId) async {
    final result = await _nativeBridge.deleteView(viewId);
    if (result) {
      _nodesByViewId.remove(viewId);
    }
    return result;
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

  /// Detach/delete a view from its parent
  Future<bool> detachView(String viewId) async {
    await _nativeBridge.deleteView(viewId);
    return true;
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
    final node = _nodesByViewId[id];
    if (node != null) return node;

    // If not found directly, do a tree search starting from root
    if (rootComponentNode != null) {
      return _findNodeInSubtree(rootComponentNode!, id);
    }

    return null;
  }

  /// Helper to find node in a subtree
  VDomNode? _findNodeInSubtree(VDomNode node, String id) {
    if (node.nativeViewId == id) return node;

    // Use type-specific access to children
    List<VDomNode> children = [];
    if (node is VDomElement) {
      children = node.children;
    } else if (node is ComponentNode && node.renderedNode != null) {
      // For ComponentNode, add its rendered node as a "child"
      children = [node.renderedNode!];
    } else if (node is Fragment) {
      children = node.children;
    }

    for (final child in children) {
      final result = _findNodeInSubtree(child, id);
      if (result != null) return result;
    }

    return null;
  }

  /// Synchronize node hierarchy
  Future<bool> synchronizeNodeHierarchy({String? rootId}) async {
    final rootNodeId = rootId ?? (rootComponentNode?.nativeViewId ?? 'root');
    return await _nodeSync.synchronizeHierarchy(rootId: rootNodeId);
  }

  /// Get native node hierarchy
  Future<Map<String, dynamic>> getNativeNodeHierarchy(
      {required String nodeId}) async {
    return await _nodeSync.getNativeHierarchy(nodeId);
  }
}
