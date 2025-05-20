// filepath: /Users/tahiruagbanwa/Desktop/Dotcorr/DCFlight/packages/dcflight/lib/framework/renderer/vdom/vdom_element.dart
import 'package:dcflight/dcflight.dart';


/// Represents an element in the Virtual DOM tree
/// These are the primitive building blocks of the UI
class VDomElement extends VDomNode {
  /// Type of the element (e.g., 'View', 'Text', 'Button')
  final String type;

  /// Properties of the element
  Map<String, dynamic> props;
  
  /// Child nodes
  final List<VDomNode> _children;

  VDomElement({
    required this.type,
    super.key,
    required this.props,
    List<VDomNode> children = const [],
  }) : _children = children {
    // Set parent reference for children
    for (var child in _children) {
      child.parent = this;
    }
  }
  
  @override
  List<VDomNode> get children => _children;
  
  @override
  bool get isComponent => false;
  
  @override
  Function? getEventHandler(String eventType) {
    // First try direct match
    if (props.containsKey(eventType) && props[eventType] is Function) {
      return props[eventType] as Function;
    }
    
    // Then try canonical format (onPress -> press)
    final propName = 'on${eventType[0].toUpperCase()}${eventType.substring(1)}';
    if (props.containsKey(propName) && props[propName] is Function) {
      return props[propName] as Function;
    }
    
    return null;
  }

  @override
  VDomNode clone() {
    return VDomElement(
      type: type,
      key: key,
      props: Map<String, dynamic>.from(props),
      children: children.map((child) => child.clone()).toList(),
    );
  }

  @override
  bool equals(VDomNode other) {
    if (other is! VDomElement) return false;
    if (type != other.type) return false;
    if (key != other.key) return false;

    return true;
  }

  @override
  String toString() {
    return 'VDomElement(type: $type, key: $key, props: ${props.length}, children: ${children.length})';
  }

  /// Get all descendant nodes flattened into a list
  List<VDomNode> get allDescendants {
    final result = <VDomNode>[];
    for (final child in children) {
      result.add(child);
      if (child is VDomElement) {
        result.addAll(child.allDescendants);
      }
    }
    return result;
  }

  /// Get list of event types from props
  List<String> get eventTypes {
    final List<String> types = [];

    // Extract event types from props with direct event names (e.g., 'onPress')
    for (final key in props.keys) {
      if (props[key] is Function) {
        // First check for direct event format (e.g., 'onPress')
        if (key.startsWith('on') && key.length > 2) {
          // Use the event name directly without normalization (onPress -> onPress)
          types.add(key);
        }

        // Also check for canonical format that will be sent from native (onPress -> press)
        if (key.startsWith('on') && key.length > 2) {
          // Convert onEventName to eventName format
          final eventName =
              key.substring(2, 3).toLowerCase() + key.substring(3);
          if (!types.contains(eventName)) {
            types.add(eventName);
          }
        }
      }
    }

    return types;
  }

  @override
  void mount(VDomNode? parent) {
    this.parent = parent;

    // Call mount on children
    for (final child in children) {
      child.mount(this);
    }
  }

  @override
  void unmount() {
    // Unmount all children first
    for (final child in children) {
      child.unmount();
    }
  }
}
