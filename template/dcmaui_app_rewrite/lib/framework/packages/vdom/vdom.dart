// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:developer' as developer;

import '../../utilities/screen_utilities.dart';
import '../../packages/native_bridge/native_bridge.dart';
import '../../packages/native_bridge/ffi_bridge.dart';
import '../../constants/yoga_enums.dart';
import '../../constants/layout_properties.dart';
import 'vdom_node.dart';
import 'vdom_element.dart';
import 'component.dart';
import 'component_node.dart';

/// Virtual DOM implementation
class VDom {
  /// Native bridge for UI operations
  late final NativeBridge _nativeBridge;

  /// Whether the VDom is ready for use
  final Completer<void> _readyCompleter = Completer<void>();

  /// Counter for generating view IDs
  int _viewIdCounter = 1;

  /// Map of component instances by ID
  final Map<String, Component> _components = {};

  /// Map of component nodes by component instance ID
  final Map<String, ComponentNode> _componentNodes = {};

  /// Map of view IDs to VDomNodes
  final Map<String, VDomNode> _nodesByViewId = {};

  /// Map of node IDs from creation to view IDs after creation
  final Map<String, String> _nodeIdToViewId = {};

  /// Root component node (for main application)
  ComponentNode? rootComponentNode;

  /// Flag to track if layout recalculation is needed
  bool _layoutDirty = false;

  /// Create a new VDom instance
  VDom() {
    _initialize();
  }

  /// Initialize the VDom
  Future<void> _initialize() async {
    try {
      // Create native bridge
      _nativeBridge = NativeBridgeFactory.create();

      // Initialize bridge
      final success = await _nativeBridge.initialize();

      if (!success) {
        throw Exception('Failed to initialize native bridge');
      }

      // Register event handler
      _nativeBridge.setEventHandler(_handleNativeEvent);

      // Mark as ready
      _readyCompleter.complete();

      developer.log('VDom initialized', name: 'VDom');
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

    return node;
  }

  /// Handle a native event
  void _handleNativeEvent(
      String viewId, String eventType, Map<String, dynamic> eventData) {
    // TODO: Implement event handling
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

    if (node is ComponentNode) {
      return _renderComponentToNative(node, parentId: parentId, index: index);
    } else if (node is VDomElement) {
      return _renderElementToNative(node, parentId: parentId, index: index);
    }

    return null;
  }

  /// Render a component to native UI
  Future<String?> _renderComponentToNative(ComponentNode componentNode,
      {String? parentId, int? index}) async {
    final component = componentNode.component;

    // Set the update function
    if (component is StatefulComponent) {
      component.scheduleUpdate = () => _updateComponent(component.instanceId);
    }

    // Reset hook state before render for stateful components
    if (component is StatefulComponent) {
      component.prepareForRender();
    }

    // Render the component
    final renderedNode = component.render();
    componentNode.renderedNode = renderedNode;
    renderedNode.parent = componentNode;

    // Render the rendered node
    final viewId =
        await renderToNative(renderedNode, parentId: parentId, index: index);

    // Store the view ID
    componentNode.contentViewId = viewId;

    // Call lifecycle method
    component.componentDidMount();

    return viewId;
  }

  /// Render an element to native UI
  Future<String?> _renderElementToNative(VDomElement element,
      {String? parentId, int? index}) async {
    // Generate view ID
    final viewId = _generateViewId();

    // Store map from node to view ID
    _nodesByViewId[viewId] = element;

    // Extract layout props
    final layoutProps = _extractLayoutProps(element.props);

    // Create the view
    final success =
        await _nativeBridge.createView(viewId, element.type, element.props);

    if (!success) {
      developer.log('Failed to create view: $viewId of type ${element.type}',
          name: 'VDom');
      return null;
    }

    // If parent is specified, attach to parent
    if (parentId != null) {
      await attachView(viewId, parentId, index ?? 0);
    }

    // Render children
    for (var i = 0; i < element.children.length; i++) {
      await renderToNative(element.children[i], parentId: viewId, index: i);
    }

    // Register event listeners
    final eventTypes = _extractEventTypes(element.props);
    if (eventTypes.isNotEmpty) {
      await _nativeBridge.addEventListeners(viewId, eventTypes);
    }

    return viewId;
  }

  /// Calculate and apply layout
  Future<void> calculateAndApplyLayout({double? width, double? height}) async {
    developer.log(
        '🔥 Starting layout calculation with dimensions: ${width ?? '100%'} x ${height ?? '100%'}',
        name: 'VDom');

    // Layout is handled automatically by the native side when props change
    // This method exists for API compatibility but does not need to do anything

    developer.log(
        '✅ Layout calculation triggered - native side will handle layout',
        name: 'VDom');

    // Reset layout dirty flag
    _layoutDirty = false;
  }

  /// Update a component
  void _updateComponent(String componentId) {
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
      // Clean up old effects
      component.componentWillUnmount();

      // Reset hook state before render
      component.prepareForRender();
    }

    // Re-render the component
    final newRenderedNode = component.render();
    final oldRenderedNode = componentNode.renderedNode;

    // Update the rendered node
    componentNode.renderedNode = newRenderedNode;
    newRenderedNode.parent = componentNode;

    // Reconcile (for now just replace)
    if (oldRenderedNode != null &&
        oldRenderedNode is VDomElement &&
        newRenderedNode is VDomElement) {
      _updateElement(oldRenderedNode, newRenderedNode);
    }

    // Calculate layout again
    calculateLayout();
  }

  /// Update an element
  Future<void> _updateElement(
      VDomElement oldElement, VDomElement newElement) async {
    // For now, just update props
    final viewId = _findViewIdForNode(oldElement);

    if (viewId != null) {
      developer.log('Found component node, updating UI for ${oldElement.type}',
          name: 'VDom');

      // Update the view props - no need to separate layout props, the native side handles it
      await updateView(viewId, newElement.props);
    }
  }

  /// Find view ID for a node
  String? _findViewIdForNode(VDomNode node) {
    // Direct lookup for elements
    for (final entry in _nodesByViewId.entries) {
      if (entry.value == node) {
        return entry.key;
      }
    }

    // For component nodes, look up by content view ID
    if (node is ComponentNode && node.contentViewId != null) {
      return node.contentViewId;
    }

    return null;
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

  /// Extract event types from props
  List<String> _extractEventTypes(Map<String, dynamic> props) {
    final eventTypes = <String>[];

    for (final key in props.keys) {
      if (key.startsWith('on') && props[key] is Function) {
        final eventType = key.substring(2).toLowerCase();
        eventTypes.add(eventType);
      }
    }

    return eventTypes;
  }

  /// Mark layout as dirty
  void markLayoutDirty() {
    _layoutDirty = true;
  }

  /// Update a view's properties
  Future<bool> updateView(String viewId, Map<String, dynamic> props) async {
    return await _nativeBridge.updateView(viewId, props);
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

  /// Calculate layout (helper method for ease of use)
  Future<void> calculateLayout() async {
    await calculateAndApplyLayout();
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
}
