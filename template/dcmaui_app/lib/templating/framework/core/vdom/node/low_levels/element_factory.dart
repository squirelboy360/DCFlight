import 'package:dc_test/templating/framework/core/vdom/node/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/foundation.dart';

/// Factory for creating VDOM elements (React-like)
class ElementFactory {
  // Counter for generating unique component IDs
  static int _componentCounter = 0;
  static String _generateComponentId() {
    return 'component_el_${_componentCounter++}';
  }

  // Counter for generating unique element keys by type
  static final Map<String, int> _elementCounters = {};

  // Create element with the right type - works exactly like React's createElement
  static VNode createElement(
      String type, Map<String, dynamic> props, List<VNode> children) {
    // CRITICAL FIX: Handle key generation correctly
    final String nodeKey;

    // If key is explicitly provided in props, use it (React behavior)
    if (props.containsKey('key') &&
        props['key'] != null &&
        props['key'] is String) {
      nodeKey = props['key'] as String;
    }
    // Otherwise generate a unique key for this element type
    else {
      // Initialize counter for this type if needed
      if (!_elementCounters.containsKey(type)) {
        _elementCounters[type] = 0;
      }

      // Create a stable key based on type and position
      nodeKey = '${type}_${_elementCounters[type]!}';

      // Add the key to props
      props = Map<String, dynamic>.from(props)..['key'] = nodeKey;
    }

    // Log element creation with proper key
    if (kDebugMode) {
      debugPrint('ElementFactory: Created $type element with key $nodeKey');
    }

    // Return a new VNode with correct key
    return VNode(
      type,
      props: Map<String, dynamic>.from(props),
      children: List<VNode>.from(children),
      key: nodeKey,
    );
  }

  // Generate a unique signature for an element based on type and key props

  // Create component with the right settings
  static VNode createComponent(
    Component Function() constructor,
    Map<String, dynamic> props,
  ) {
    final componentId = _generateComponentId();

    // CRITICAL FIX: Ensure key exists and is preserved
    final String nodeKey;
    if (props.containsKey('key') && props['key'] != null) {
      nodeKey = props['key'] as String;
    } else {
      nodeKey = componentId;
    }

    // Create a new props map with the key
    final enhancedProps = Map<String, dynamic>.from(props)
      ..['key'] = nodeKey
      ..['_isComponent'] = true
      ..['_componentId'] = componentId
      ..['_componentConstructor'] = constructor;

    // CRITICAL FIX: Make sure event handlers are properly set up
    final eventKeys = props.keys.where((key) => key.startsWith('on')).toList();
    if (eventKeys.isNotEmpty) {
      enhancedProps['_eventListeners'] = eventKeys;
    }

    // For debug tracing
    if (kDebugMode) {
      debugPrint(
          'ElementFactory: Created component with ID $componentId and key $nodeKey');
    }

    return VNode(
      'component',
      props: enhancedProps,
      children: [],
      key: nodeKey,
    );
  }

  // Reset all element counters - useful for complete re-renders
  static void resetElementCounters() {
    _elementCounters.clear();
    _componentCounter = 0;
  }
}

extension VNodeExtension on VNode {
  // Helper to access the VNode directly
  VNode get vnode => this;
}
