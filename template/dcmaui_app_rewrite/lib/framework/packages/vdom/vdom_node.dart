/// Base class for all Virtual DOM nodes
abstract class VDomNode {
  /// Unique identifier for this node
  final String? key;

  /// Parent node in the virtual tree
  VDomNode? parent;

  /// Native view ID once rendered
  String? nativeViewId;

  VDomNode({this.key});

  /// Clone this node
  VDomNode clone();

  /// Whether this node is equal to another
  bool equals(VDomNode other);

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
}
