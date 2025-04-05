import 'dart:developer' as developer;
import 'dart:collection';
import 'shadow_node.dart';
import 'yoga_enums.dart';

/// Result of layout calculation
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
}

/// Manager for the shadow tree that handles layout calculations
class ShadowTree {
  /// Map of node IDs to shadow nodes
  final Map<String, ShadowNode> _nodes = {};

  /// Root node ID
  String? _rootNodeId;

  /// Create a node with a unique ID
  ShadowNode createNode(String id) {
    if (_nodes.containsKey(id)) {
      return _nodes[id]!;
    }

    final node = ShadowNode(id);
    _nodes[id] = node;
    return node;
  }

  /// Set the root node ID
  void setRoot(String id) {
    if (!_nodes.containsKey(id)) {
      developer.log('Root node $id not found in shadow tree',
          name: 'ShadowTree');
      return;
    }

    _rootNodeId = id;
  }

  /// Add a child to a parent node
  void addChild(String parentId, String childId) {
    final parent = _nodes[parentId];
    final child = _nodes[childId];

    if (parent == null || child == null) {
      developer.log('Parent $parentId or child $childId not found',
          name: 'ShadowTree');
      return;
    }

    parent.addChild(child);
  }

  /// Remove a node and its children
  void removeNode(String id) {
    final node = _nodes[id];
    if (node == null) return;

    // Find and remove node from its parent
    for (final potentialParent in _nodes.values) {
      potentialParent.removeChild(node);
    }

    // Remove the node and all its children
    final nodesToRemove = <String>[];

    // Helper to collect all descendants
    void collectDescendants(ShadowNode currentNode) {
      nodesToRemove.add(currentNode.id);

      for (final child in currentNode.children) {
        collectDescendants(child);
      }
    }

    collectDescendants(node);

    // Remove all collected nodes
    for (final id in nodesToRemove) {
      _nodes.remove(id);
    }

    // Update root if needed
    if (_rootNodeId == id) {
      _rootNodeId = null;
    }
  }

  /// Update layout props for a node
  void updateLayoutProps(String id, Map<String, dynamic> props) {
    final node = _nodes[id];
    if (node == null) {
      developer.log('Node $id not found for prop update', name: 'ShadowTree');
      return;
    }

    node.applyLayoutProps(props);
  }

  /// Clear the entire tree
  void clear() {
    _nodes.clear();
    _rootNodeId = null;
  }

  /// Calculate layout with given dimensions
  /// Handle string, number, or null dimensions - pass through as-is to Yoga
  Map<String, LayoutResult> calculateLayout(dynamic width, dynamic height) {
    if (_rootNodeId == null) {
      return {};
    }

    final rootNode = _nodes[_rootNodeId!];
    if (rootNode == null) {
      return {};
    }

    // Handle percentage values for root node dimensions
    // For width and height, pass the strings directly to the native side
    if (width is String && width.endsWith('%')) {
      // This is fine - percentage will be handled in yoga_node.dart
      rootNode.yogaNode
          .setWidthPercent(double.parse(width.substring(0, width.length - 1)));
    } else if (width is num) {
      rootNode.yogaNode.setWidth(width.toDouble());
    }

    if (height is String && height.endsWith('%')) {
      // This is fine - percentage will be handled in yoga_node.dart
      rootNode.yogaNode.setHeightPercent(
          double.parse(height.substring(0, height.length - 1)));
    } else if (height is num) {
      rootNode.yogaNode.setHeight(height.toDouble());
    }

    // Calculate layout - use numeric dimensions for calculation
    // but percentages are already applied above
    double calcWidth = (width is num) ? width.toDouble() : 0;
    double calcHeight = (height is num) ? height.toDouble() : 0;

    // Calculate layout
    rootNode.yogaNode.calculateLayout(
        width: calcWidth, height: calcHeight, direction: YogaDirection.ltr);

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
}
