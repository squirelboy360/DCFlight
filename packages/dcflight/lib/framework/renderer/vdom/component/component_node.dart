import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';

/// Base class for all component nodes
/// Provides common functionality for both stateful and stateless components
abstract class ComponentNode extends VDomNode {
  /// Fully qualified type name for component
  final String typeName;

  /// The rendered node from the component
  VDomNode? _renderedNode;

  /// Whether the component is mounted
  bool _isMounted = false;

  /// Create a component node
  ComponentNode({super.key})
      : typeName = StackTrace.current.toString().split('\n')[1].split(' ')[0];

  /// All components must implement a render method
  VDomNode render();
  
  @override
  bool get isComponent => true;
  
  /// Get the rendered node (lazily render if necessary)
  @override
  VDomNode get renderedNode {
    _renderedNode ??= render();
    return _renderedNode!;
  }
  
  /// Set the rendered node
  @override
  set renderedNode(VDomNode? node) {
    _renderedNode = node;
    if (_renderedNode != null) {
      _renderedNode!.parent = this;
    }
  }

  /// Get whether the component is mounted
  bool get isMounted => _isMounted;

  /// Called when the component is mounted
  @override
  void componentDidMount() {
    _isMounted = true;
  }

  /// Called when the component will unmount
  @override
  void componentWillUnmount() {
    _isMounted = false;
  }
  
  /// Called after the component updates
  void componentDidUpdate() {}
  
  @override
  VDomNode clone() {
    // Components can't be cloned easily due to state, hooks, etc.
    throw UnsupportedError("Component nodes cannot be cloned directly.");
  }
  
  @override
  bool equals(VDomNode other) {
    if (!other.isComponent) return false;
    return runtimeType == other.runtimeType && key == other.key;
  }
  
  @override
  void mount(VDomNode? parent) {
    this.parent = parent;
    
    // Ensure the component has rendered
    final node = renderedNode;
    
    // Mount the rendered content
    node.mount(this);
    
    // Component lifecycle method
    componentDidMount();
  }
  
  @override
  void unmount() {
    // Unmount the rendered content if any
    if (_renderedNode != null) {
      _renderedNode!.unmount();
    }
    
    // Component lifecycle method
    componentWillUnmount();
  }

  @override
  String toString() {
    return '$typeName($instanceId)';
  }
  
  /// Whether this component supports state and lifecycle updates
  bool get isStateful => false;
}
