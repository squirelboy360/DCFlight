import 'package:collection/collection.dart';
import 'vdom_node.dart';
import '../native_bridge/dispatcher.dart';

/// Represents an element in the Virtual DOM tree
class VDomElement extends VDomNode {
  /// Type of the element (e.g., 'View', 'Text', 'Button')
  final String type;

  /// Properties of the element
  final Map<String, dynamic> props;

  /// Child nodes
  final List<VDomNode> children;

  // FIXED: Changed from final to private Map that can be modified
  // Event handlers map
  Map<String, dynamic>? _events;

  // Add getter for events
  Map<String, dynamic>? get events => _events;

  VDomElement({
    required this.type,
    super.key,
    Map<String, dynamic>? props,
    List<VDomNode>? children,
    Map<String, dynamic>? events,
  })  : props = props ?? {},
        children = children ?? [],
        _events = events {
    // Set parent reference for children
    for (var child in this.children) {
      child.parent = this;
    }

    // Automatically extract onX props into events
    if (this.props.isNotEmpty) {
      _extractEventHandlersFromProps();
    }
  }

  /// Extract event handlers from props - any prop starting with "on" is an event
  void _extractEventHandlersFromProps() {
    final extractedEvents = <String, dynamic>{};

    // Get all keys starting with "on"
    final eventKeys =
        props.keys.where((key) => key.startsWith('on') && key.length > 2);

    for (final key in eventKeys) {
      final handler = props[key];
      if (handler is Function) {
        // Convert onEvent to 'event' format for native bridge
        final eventName = key.substring(2, 3).toLowerCase() + key.substring(3);
        extractedEvents[eventName] = handler;
      }
    }

    // Set the extracted events if any were found
    if (extractedEvents.isNotEmpty) {
      if (_events == null) {
        _events = extractedEvents;
      } else {
        _events!.addAll(extractedEvents);
      }
    }
  }

  @override
  VDomNode clone() {
    return VDomElement(
      type: type,
      key: key,
      props: Map<String, dynamic>.from(props),
      children: children.map((child) => child.clone()).toList(),
      events: events != null ? Map<String, dynamic>.from(events!) : null,
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

  /// Get list of event types from events map
  List<String> get eventTypes {
    List<String> types = [];

    // Add explicit events from events map
    if (events != null) {
      types.addAll(events!.keys);
    }

    // Also check props for event handlers (onX pattern)
    props.forEach((key, value) {
      if (key.startsWith('on') && value is Function) {
        // Convert camelCase to lowercase (e.g. onPress -> press)
        final eventName = key[2].toLowerCase() + key.substring(3);
        if (!types.contains(eventName)) {
          types.add(eventName);
        }
      }
    });

    return types;
  }

  // Register events with the native bridge
  void registerEvents() {
    final types = eventTypes;
    if (types.isNotEmpty && nativeViewId != null) {
      // Register events with the native bridge
      PlatformDispatcher.instance.addEventListeners(nativeViewId!, types);
    }
  }
}
