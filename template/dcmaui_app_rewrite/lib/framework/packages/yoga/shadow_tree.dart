import 'dart:developer' as developer;
import 'dart:collection';
import 'shadow_node.dart';
import 'yoga_enums.dart';

/// Result of a layout calculation
class LayoutResult {
  final double left;
  final double top;
  final double width;
  final double height;

  LayoutResult({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  @override
  String toString() {
    return 'LayoutResult(left: $left, top: $top, width: $width, height: $height)';
  }
}

/// Manager for the shadow tree that handles layout calculations
class ShadowTree {
  /// Map of node IDs to shadow nodes
  final Map<String, ShadowNode> _nodes = {};

  /// Root node ID
  String? _rootNodeId;

  /// Get a node by ID
  ShadowNode? getNode(String nodeId) {
    return _nodes[nodeId];
  }

  /// Create a new shadow node with the given ID
  ShadowNode createNode(String nodeId) {
    // If node already exists, return it
    if (_nodes.containsKey(nodeId)) {
      return _nodes[nodeId]!;
    }

    // Create new node
    final node = ShadowNode(nodeId);
    _nodes[nodeId] = node;

    // If this is the first node, set it as root
    if (_rootNodeId == null) {
      _rootNodeId = nodeId;
    }

    return node;
  }

  /// Set a node as the root
  void setRoot(String nodeId) {
    if (!_nodes.containsKey(nodeId)) {
      throw Exception('Cannot set non-existent node as root: $nodeId');
    }
    _rootNodeId = nodeId;
  }

  /// Apply layout properties to a node
  void applyLayoutProps(String nodeId, Map<String, dynamic> props) {
    final node = getNode(nodeId) ?? createNode(nodeId);
    node.applyLayoutProps(props);
  }

  /// Update layout properties for a node
  void updateLayoutProps(String nodeId, Map<String, dynamic> props) {
    final node = getNode(nodeId);
    if (node != null) {
      node.updateLayoutProps(props);
    }
  }

  /// Add a child to a parent node
  void addChild(String parentId, String childId) {
    final parentNode = getNode(parentId) ?? createNode(parentId);
    final childNode = getNode(childId) ?? createNode(childId);

    parentNode.addChild(childNode);
  }

  /// Insert a child at a specific index
  void insertChild(String parentId, String childId, int index) {
    final parentNode = getNode(parentId) ?? createNode(parentId);
    final childNode = getNode(childId) ?? createNode(childId);

    parentNode.insertChild(childNode, index);
  }

  /// Remove child from parent
  bool removeChild(String parentId, String childId) {
    final parentNode = getNode(parentId);
    final childNode = getNode(childId);

    if (parentNode == null || childNode == null) {
      return false;
    }

    return parentNode.removeChild(childNode);
  }

  /// Calculate layout with given dimensions
  Map<String, LayoutResult> calculateLayout(double width, double height) {
    // This method orchestrates the layout calculation by:
    // 1. Finding the root node
    // 2. Setting its dimensions
    // 3. Running the yoga calculation
    // 4. Extracting layout results from all nodes

    if (_rootNodeId == null) {
      return {};
    }

    final rootNode = _nodes[_rootNodeId!];
    if (rootNode == null) {
      return {};
    }

    // Set dimensions on root node
    rootNode.yogaNode.setWidth(width);
    rootNode.yogaNode.setHeight(height);

    // Calculate layout
    rootNode.yogaNode.calculateLayout(
        width: width, height: height, direction: YogaDirection.ltr);

    // Extract layout results
    final results = <String, LayoutResult>{};

    // Use BFS to traverse the tree
    final queue = Queue<ShadowNode>();
    queue.add(rootNode);

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();

      // Get layout information
      final left = node.yogaNode.getLayoutLeft();
      final top = node.yogaNode.getLayoutTop();
      final nodeWidth = node.yogaNode.getLayoutWidth();
      final nodeHeight = node.yogaNode.getLayoutHeight();

      // Store layout result
      results[node.id] = LayoutResult(
        left: left,
        top: top,
        width: nodeWidth,
        height: nodeHeight,
      );

      // Add children to the queue
      for (final child in node.children) {
        queue.add(child);
      }
    }

    return results;
  }

  /// Remove a node from the tree
  void removeNode(String nodeId) {
    final node = _nodes[nodeId];
    if (node == null) return;

    // Remove from parent if it has one
    if (node.parent != null) {
      node.parent!.removeChild(node);
    }

    // Dispose the node
    node.dispose();

    // Remove from nodes map
    _nodes.remove(nodeId);

    // If this was the root, clear root ID
    if (_rootNodeId == nodeId) {
      _rootNodeId = null;
    }
  }

  /// Clear the entire tree
  void clear() {
    // Dispose all nodes
    for (final node in _nodes.values) {
      node.dispose();
    }

    // Clear collections
    _nodes.clear();
    _rootNodeId = null;
  }

  /// Check if tree is empty
  bool get isEmpty => _nodes.isEmpty;

  /// Check if tree has a root
  bool get hasRoot => _rootNodeId != null;

  /// Get the root node
  ShadowNode? get rootNode => _rootNodeId != null ? _nodes[_rootNodeId!] : null;
}
