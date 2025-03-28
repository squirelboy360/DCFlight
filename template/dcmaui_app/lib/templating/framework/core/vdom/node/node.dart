/// A virtual DOM node
class VNode {
  /// The node type (e.g., 'view', 'text', 'component')
  final String type;

  /// Props (properties) for this node
  Map<String, dynamic> props;

  /// Unique key for reconciliation
  final String key;

  /// Child nodes
  final List<VNode> children;

  /// Component ID - For tracking component ownership
  final String? componentId;

  /// Hash code for faster identity checks
  final int _hashValue;

  /// Constructor with improved key generation
  VNode(
    this.type, {
    required this.props,
    this.children = const [],
    String? key,
    this.componentId,
  })  : key = key ?? props['key'] as String? ?? _generateStableKey(type, props),
        _hashValue = Object.hash(
            key ?? props['key'] as String? ?? _generateStableKey(type, props),
            type,
            identityHashCode(props));

  /// Generate a stable key based on type and props
  static String _generateStableKey(String type, Map<String, dynamic>? props) {
    // Use ID if available as it's most stable
    final id = props?['id'] ?? props?['testID'];
    if (id != null) return '${type}_$id';

    // Use type with unique hash
    return '${type}_${identityHashCode(props)}';
  }

  /// Check if this node has same identity as another node
  bool hasSameIdentity(VNode other) {
    return key == other.key && type == other.type;
  }

  /// Deep comparison of props
  bool hasSameProps(VNode other) {
    if (props.length != other.props.length) return false;

    for (final key in props.keys) {
      // Skip function comparisons as they're not reliably comparable
      if (props[key] is Function && other.props[key] is Function) continue;

      // Skip internal props that don't affect rendering
      if (key.startsWith('_')) continue;

      if (!other.props.containsKey(key) || props[key] != other.props[key]) {
        return false;
      }
    }

    return true;
  }

  /// Check if this node can be reused (same identity) but needs update
  bool canReuseNode(VNode other) {
    return hasSameIdentity(other) && !hasSameProps(other);
  }

  /// Create a copy of this node with new props
  VNode copyWith({Map<String, dynamic>? props}) {
    return VNode(
      type,
      key: key,
      props: props ?? Map<String, dynamic>.from(this.props),
      children: List<VNode>.from(children),
      componentId: componentId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! VNode) return false;

    return key == other.key &&
        type == other.type &&
        _arePropsEqual(props, other.props) &&
        _areChildrenEqual(children, other.children);
  }

  bool _arePropsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;

    for (final key in a.keys) {
      // Skip function comparisons
      if (a[key] is Function && b[key] is Function) continue;

      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }

    return true;
  }

  bool _areChildrenEqual(List<VNode> a, List<VNode> b) {
    if (a.length != b.length) return false;

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }

    return true;
  }

  @override
  int get hashCode => _hashValue;

  @override
  String toString() {
    final childCount = children.isEmpty ? '' : ', children: ${children.length}';
    return 'VNode($type, key=$key$childCount)';
  }

  /// Debug helper to print the node tree
  String toTreeString([int depth = 0]) {
    final indent = '  ' * depth;
    final childrenStr = children.isEmpty
        ? ''
        : '\n${children.map((c) => c.toTreeString(depth + 1)).join('\n')}';

    return '$indent$toString()$childrenStr';
  }

  // Add method to ensure all children are properly processed
  List<Map<String, dynamic>> processChildrenForNative() {
    return children.map((child) {
      final nodeProps = child.props ?? {};
      // Ensure children have unique keys for proper rendering
      if (!nodeProps.containsKey('key')) {
        nodeProps['key'] = 'child_${child.hashCode}';
      }

      // Recursively process children of this child
      if (child.children.isNotEmpty) {
        nodeProps['children'] = child.processChildrenForNative();
      }

      return {
        'type': child.type,
        'props': nodeProps,
      };
    }).toList();
  }
}
