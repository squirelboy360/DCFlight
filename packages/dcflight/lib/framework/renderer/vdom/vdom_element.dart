// filepath: /Users/tahiruagbanwa/Desktop/Dotcorr/DCFlight/packages/dcflight/lib/framework/renderer/vdom/vdom_element.dart
import 'vdom_node.dart';

/// Represents an element in the Virtual DOM tree
class VDomElement extends VDomNode {
  /// Type of the element (e.g., 'View', 'Text', 'Button')
  final String type;

  /// Properties of the element
  Map<String, dynamic> props;

  /// Child nodes
  final List<VDomNode> children;

  VDomElement({
    required this.type,
    super.key,
    required this.props,
    this.children = const [],
  }) {
    // Set parent reference for children
    for (var child in this.children) {
      child.parent = this;
    }
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
    
    // Extract event types from props with 'on' prefix
    for (final key in props.keys) {
      if (key.startsWith('on') && key.length > 2 && props[key] is Function) {
        // Convert onEventName to eventName format
        final eventName = key.substring(2, 3).toLowerCase() + key.substring(3);
        types.add(eventName);
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
