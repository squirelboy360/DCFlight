import 'dart:developer' as developer;
import 'package:dc_test/framework/constants/layout_properties.dart';
import 'yoga_node.dart';
import 'yoga_enums.dart';
import 'layout_calculator.dart';

/// Deprecated layout manager - redirects to LayoutCalculator
/// This is kept for backward compatibility
class DartLayoutManager {
  /// Singleton instance
  static final DartLayoutManager instance = DartLayoutManager._();

  /// Layout calculator instance
  final LayoutCalculator _layoutCalculator = LayoutCalculator.instance;

  /// Node mapping - maps view IDs to Yoga nodes
  final Map<String, YogaNode> _nodeMapping = {};

  /// Private constructor
  DartLayoutManager._();

  /// Get a node for a view
  YogaNode? getNodeForView(String viewId) {
    return _nodeMapping[viewId];
  }

  /// Create a Yoga node for a view
  YogaNode createNodeForView(String viewId) {
    // Check if already exists
    if (_nodeMapping.containsKey(viewId)) {
      return _nodeMapping[viewId]!;
    }

    // Create new node
    final node = YogaNode();
    _nodeMapping[viewId] = node;
    return node;
  }

  /// Register a parent-child relationship
  void registerParentChild(String parentId, String childId) {
    // This functionality is now handled by the shadow tree
    // No need to do anything here
  }

  /// Apply flexbox properties to a node
  void applyFlexboxProps(String viewId, Map<String, dynamic> props) {
    // This functionality is now handled by the shadow tree in LayoutCalculator
    // No need to do anything here with the old node mapping
  }

  /// Calculate layout for a view hierarchy
  Map<String, _LayoutResult> calculateLayout(
      String rootId, double width, double height) {
    // Get the results from the layout calculator
    // This assumes you'll do proper node building elsewhere

    developer.log('Warning: Using deprecated DartLayoutManager',
        name: 'LayoutManager');

    // Just use empty results for backward compatibility
    return <String, _LayoutResult>{};
  }
}

/// Layout result class for backward compatibility
class _LayoutResult {
  final double left;
  final double top;
  final double width;
  final double height;

  _LayoutResult({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}
