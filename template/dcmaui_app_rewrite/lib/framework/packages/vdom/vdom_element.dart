import 'package:collection/collection.dart';
import 'vdom_node.dart';
import '../native_bridge/native_bridge.dart';

/// Represents an element in the Virtual DOM tree
class VDomElement extends VDomNode {
  /// Type of the element (e.g., 'View', 'Text', 'Button')
  final String type;

  /// Properties of the element
  final Map<String, dynamic> props;

  /// Child nodes
  final List<VDomNode> children;

  // Add a new field for event handlers
  final Map<String, dynamic>? events;

  VDomElement({
    required this.type,
    super.key,
    Map<String, dynamic>? props,
    List<VDomNode>? children,
    this.events,
  })  : props = props ?? {},
        children = children ?? [] {
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
      events: events,
    );
  }

  @override
  bool equals(VDomNode other) {
    if (other is! VDomElement) return false;
    if (type != other.type) return false;
    if (key != other.key) return false;

    // Deep props comparison
    if (!DeepCollectionEquality().equals(props, other.props)) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'VDomElement(type: $type, key: $key, props: ${props.length}, children: ${children.length})';
  }

  /// Get all descendant nodes flattened into a list
  List<VDomNode> getDescendants() {
    final result = <VDomNode>[];

    for (var child in children) {
      result.add(child);
      if (child is VDomElement) {
        result.addAll(child.getDescendants());
      }
    }

    return result;
  }

  /// Get child at index, returns EmptyVDomNode if out of bounds
  VDomNode childAt(int index) {
    if (index < 0 || index >= children.length) {
      return EmptyVDomNode();
    }
    return children[index];
  }

  @override
  void mount(VDomNode? parent) {
    // Call mount on children
    for (final child in children) {
      child.mount(this);
    }
  }

  @override
  void unmount() {
    // Call unmount on children
    for (final child in children) {
      child.unmount();
    }
  }

  // Add a new method to register events
  void registerEvents() {
    if (events != null && events!.isNotEmpty) {
      // Gather event types from the events map
      final eventTypes = events!.keys.toList();

      // Register events with the native bridge
      NativeBridge.instance.addEventListeners(key!, eventTypes);
    }
  }
}
