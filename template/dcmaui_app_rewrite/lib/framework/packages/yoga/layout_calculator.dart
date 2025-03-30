import 'dart:developer' as developer;
import 'package:dc_test/framework/constants/layout_properties.dart';
import 'package:dc_test/framework/packages/vdom/vdom_node.dart';
import 'package:dc_test/framework/packages/vdom/vdom_element.dart';
import 'dart_layout_manager.dart';

/// Class responsible for calculating layout using Yoga in the Dart side
class LayoutCalculator {
  /// Singleton instance
  static final LayoutCalculator instance = LayoutCalculator._();

  /// Layout manager
  final DartLayoutManager _layoutManager = DartLayoutManager.instance;

  /// View tree mapping - maps view IDs to their parent and children
  final Map<String, _ViewTreeNode> _viewTree = {};

  /// ID counter for auto-generated IDs
  int _idCounter = 0;

  /// Private constructor
  LayoutCalculator._();

  /// Calculate layout for a component tree
  Map<String, LayoutResult> calculateLayout(
      VDomNode root, double containerWidth, double containerHeight) {
    // Ensure all nodes have IDs
    _ensureNodeIds(root);

    // Build view tree for layout calculation
    _buildViewTree(root);

    // Create and set up Yoga nodes
    final rootId = _getNodeId(root);
    if (rootId == null) {
      developer.log('Root node has no ID', name: 'LayoutCalculator');
      return {};
    }

    // Apply layout props to Yoga nodes
    _applyLayoutProps(root);

    // Register parent-child relationships
    _registerParentChildRelationships();

    // Calculate layout
    final layoutResults =
        _layoutManager.calculateLayout(rootId, containerWidth, containerHeight);

    // Convert to public results
    final results = <String, LayoutResult>{};
    for (final entry in layoutResults.entries) {
      results[entry.key] = LayoutResult(
        left: entry.value.left,
        top: entry.value.top,
        width: entry.value.width,
        height: entry.value.height,
      );
    }

    return results;
  }

  /// Register parent-child relationships from view tree
  void _registerParentChildRelationships() {
    for (final node in _viewTree.values) {
      final parentId = node.parentId;
      final childId = node.id;

      if (parentId != null) {
        _layoutManager.registerParentChild(parentId, childId);
      }
    }
  }

  /// Ensure all nodes have IDs
  void _ensureNodeIds(VDomNode node) {
    if (node is VDomElement) {
      node.nativeViewId ??= 'temp_${_idCounter++}';

      // Process children
      for (final child in node.children) {
        _ensureNodeIds(child);
      }
    }
  }

  /// Build view tree for layout calculation
  void _buildViewTree(VDomNode node, {String? parentId}) {
    final id = _getNodeId(node);
    if (id == null) return;

    // Create tree node if needed
    if (!_viewTree.containsKey(id)) {
      _viewTree[id] = _ViewTreeNode(id: id, parentId: parentId);
    } else {
      // Update parent if needed
      _viewTree[id]!.parentId = parentId;
    }

    // Create Yoga node
    _layoutManager.createNodeForView(id);

    // Process children
    if (node is VDomElement) {
      for (final child in node.children) {
        final childId = _getNodeId(child);
        if (childId != null) {
          _viewTree[id]!.childrenIds.add(childId);
          _buildViewTree(child, parentId: id);
        }
      }
    }
  }

  /// Apply layout properties to Yoga nodes
  void _applyLayoutProps(VDomNode node) {
    final id = _getNodeId(node);
    if (id == null) return;

    if (node is VDomElement) {
      // Extract layout-related props
      final layoutProps = _extractLayoutProps(node.props);

      // Apply to Yoga node
      _layoutManager.applyFlexboxProps(id, layoutProps);

      // Process children
      for (final child in node.children) {
        _applyLayoutProps(child);
      }
    }
  }

  /// Extract layout-relevant props from node props
  Map<String, dynamic> _extractLayoutProps(Map<String, dynamic> props) {
    final layoutProps = <String, dynamic>{};

    // Use the central source of truth for layout property names
    for (final propName in LayoutProperties.all) {
      if (props.containsKey(propName)) {
        layoutProps[propName] = props[propName];
      }
    }

    return layoutProps;
  }

  /// Get node ID, either native view ID or key
  String? _getNodeId(VDomNode node) {
    if (node is VDomElement) {
      return node.nativeViewId;
    }
    return null;
  }
}

/// Helper class for view tree node
class _ViewTreeNode {
  final String id;
  String? parentId;
  final List<String> childrenIds = [];

  _ViewTreeNode({required this.id, this.parentId});
}

/// Public layout result class
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
