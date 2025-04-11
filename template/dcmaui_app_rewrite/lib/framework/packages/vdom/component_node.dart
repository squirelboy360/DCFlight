import 'vdom_node.dart';
import 'component.dart';

/// Node representing a component in the Virtual DOM
class ComponentNode extends VDomNode {
  /// The component this node represents
  final Component component;

  /// The rendered node from the component
  VDomNode? renderedNode;

  /// The native view ID of the rendered content
  String? contentViewId;

  ComponentNode({
    required this.component,
    String? key,
  }) : super(key: key ?? component.key);

  @override
  VDomNode clone() {
    final clone = ComponentNode(
      component: component,
      key: key,
    );

    if (renderedNode != null) {
      clone.renderedNode = renderedNode!.clone();
      clone.renderedNode!.parent = clone;
    }

    return clone;
  }

  /// Get effective native view ID (may be from rendered content)
  @override
  String? get nativeViewId {
    // For component nodes, the native view ID is the ID of their rendered content
    // This ensures the component appears as one cohesive node in the tree
    return contentViewId ?? super.nativeViewId;
  }

  /// Set native view ID and update tracking
  @override
  set nativeViewId(String? id) {
    super.nativeViewId = id;
    contentViewId = id;
  }

  @override
  bool equals(VDomNode other) {
    if (other is! ComponentNode) return false;
    return component.runtimeType == other.component.runtimeType &&
        key == other.key;
  }

  @override
  String toString() {
    return 'ComponentNode(component: ${component.runtimeType}, id: ${component.instanceId}, key: $key)';
  }

  @override
  void mount(VDomNode? parent) {
    this.parent = parent;

    // If there's a rendered node, propagate the mount
    if (renderedNode != null) {
      renderedNode!.mount(this);
    }
  }

  @override
  void unmount() {
    // Clean up the rendered node if any
    if (renderedNode != null) {
      renderedNode!.unmount();
    }

    // Additional cleanup if needed
    component.componentWillUnmount();
  }
}
