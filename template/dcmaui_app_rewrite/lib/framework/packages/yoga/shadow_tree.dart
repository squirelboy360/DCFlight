import 'dart:developer' as developer;

import 'shadow_node.dart';
import 'yoga_enums.dart';
import '../../utilities/screen_utilities.dart';

/// A tree of shadow nodes for layout calculation
class ShadowTree {
  /// Map of nodes by ID
  final Map<String, ShadowNode> _nodes = {};

  /// List of root nodes
  final List<ShadowNode> _rootNodes = [];

  /// Create a new shadow tree
  ShadowTree();

  /// Clear the entire tree
  void clear() {
    // Dispose all nodes
    for (final node in _nodes.values) {
      node.dispose();
    }

    // Clear collections
    _nodes.clear();
    _rootNodes.clear();

    developer.log('Shadow tree cleared', name: 'ShadowTree');
  }

  /// Create or get a node
  ShadowNode getOrCreateNode(String id) {
    if (_nodes.containsKey(id)) {
      return _nodes[id]!;
    }

    // Create a new node
    final node = ShadowNode(id);
    _nodes[id] = node;

    // Initially assume it's a root node until added as a child
    _rootNodes.add(node);

    return node;
  }

  /// Add a node to the tree
  ShadowNode addNode(String id, {String? parentId, int? index}) {
    final node = getOrCreateNode(id);

    if (parentId != null) {
      final parent = getOrCreateNode(parentId);

      // If it was a root node, remove it from root nodes list
      if (_rootNodes.contains(node)) {
        _rootNodes.remove(node);
      }

      // Add to parent
      parent.addChild(node, index);

      developer.log(
          'Added node $id as child to $parentId (child #${index ?? parent.children.length - 1})',
          name: 'ShadowTree');
    } else if (!_rootNodes.contains(node)) {
      // Ensure it's in the root nodes list
      _rootNodes.add(node);

      developer.log('Added node $id as root node', name: 'ShadowTree');
    }

    return node;
  }

  /// Remove a node from the tree
  void removeNode(String id) {
    if (_nodes.containsKey(id)) {
      final node = _nodes[id]!;

      // Remove from root nodes if applicable
      _rootNodes.remove(node);

      // Remove from parent if applicable
      if (node.parent != null) {
        node.parent!.removeChild(node);
      }

      // Dispose the node
      node.dispose();

      // Remove from nodes map
      _nodes.remove(id);

      developer.log('Removed node $id from tree', name: 'ShadowTree');
    }
  }

  /// Get a node by ID
  ShadowNode? getNode(String id) {
    return _nodes[id];
  }

  /// Update layout props for a node
  void updateNodeProps(String id, Map<String, dynamic> props) {
    final node = getOrCreateNode(id);
    node.applyLayoutProps(props);

    developer.log('Updated layout props for node $id', name: 'ShadowTree');
  }

  /// Calculate layout for the entire tree
  void calculateLayout(
      {required double width,
      required double height,
      required YogaDirection direction}) {
    developer.log(
        'Calculating layout for ${_rootNodes.length} root nodes with dimensions: ${width}x${height}',
        name: 'ShadowTree');

    // Calculate layout for each root node
    for (final rootNode in _rootNodes) {
      developer.log('Root node is dirty: ${rootNode.isDirty}',
          name: 'ShadowTree');

      rootNode.calculateLayout(width, height, direction);
    }
  }

  /// Get layout result for a node
  LayoutResult? getLayoutForNode(String id) {
    return _nodes[id]?.layout;
  }

  /// Get all nodes
  List<ShadowNode> get nodes => _nodes.values.toList();

  /// Get root nodes
  List<ShadowNode> get rootNodes => _rootNodes;

  /// Check if a node exists
  bool hasNode(String id) => _nodes.containsKey(id);

  /// Get nodes count
  int get nodeCount => _nodes.length;
}
