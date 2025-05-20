/// Base class for all Virtual DOM nodes
abstract class VDomNode {
  /// Unique identifier for this node
  final String? key;

  /// Parent node in the virtual tree
  VDomNode? parent;

  /// Native view ID once rendered
  String? nativeViewId;
  
  /// The native view ID of the rendered content
  String? contentViewId;
  
  /// The rendered node from the component (for component nodes)
  VDomNode? _renderedNode;
  
  /// Common instance ID for tracking (used by reconciler)
  final String instanceId;

  VDomNode({this.key})
      : instanceId = DateTime.now().millisecondsSinceEpoch.toString() +
            (key ?? '').hashCode.toString();

  /// Whether this node is a component that renders other nodes
  bool get isComponent => false;
  
  /// Get children nodes for container-like nodes
  List<VDomNode> get children => const [];
  
  /// Get event handler for a specific event type
  Function? getEventHandler(String eventType) => null;
  
  /// Get the underlying implementation node (for reconciler use)
  /// This is the key method that simplifies reconciliation
  VDomNode getImplementationNode() {
    if (isComponent) {
      return renderedNode?.getImplementationNode() ?? this;
    } else {
      return this;
    }
  }

  /// Clone this node
  VDomNode clone();

  /// Whether this node is equal to another
  bool equals(VDomNode other);

  /// Mount to the tree
  void mount(VDomNode? parent);
  
  /// Unmount from the tree
  void unmount();
  
  /// Called when the node is mounted (lifecycle method)
  void componentDidMount() {
    // Base implementation does nothing
  }

  /// Called when the node will unmount (lifecycle method)
  void componentWillUnmount() {
    // Base implementation does nothing
  }
  
  /// Get the rendered node (for component-like nodes)
  VDomNode? get renderedNode => _renderedNode;
  
  /// Set the rendered node (for component-like nodes)
  set renderedNode(VDomNode? node) {
    _renderedNode = node;
    if (_renderedNode != null) {
      _renderedNode!.parent = this;
    }
  }
  
  /// Get effective native view ID (may be from rendered content)
  String? get effectiveNativeViewId {
    // For component nodes, the native view ID is the ID of their rendered content
    return contentViewId ?? nativeViewId;
  }

  @override
  String toString() {
    return 'VDomNode(key: $key)';
  }
}

/// Represents absence of a node - useful for conditional rendering
class EmptyVDomNode extends VDomNode {
  EmptyVDomNode() : super(key: null);

  @override
  VDomNode clone() => EmptyVDomNode();

  @override
  bool equals(VDomNode other) => other is EmptyVDomNode;

  @override
  String toString() => 'EmptyVDomNode()';

  @override
  void mount(VDomNode? parent) {
    this.parent = parent;
    // Empty node has no additional mounting logic
  }

  @override
  void unmount() {
    // Empty node has no cleanup logic
  }
}


