import 'yoga_node.dart';
import 'layout_calculator.dart';

/// Deprecated layout manager - redirects to LayoutCalculator
/// This is kept for backward compatibility
class DartLayoutManager {
  /// Singleton instance
  static final DartLayoutManager instance = DartLayoutManager._();

  /// Layout calculator instance
  final LayoutCalculator _layoutCalculator = LayoutCalculator.instance;

  /// Private constructor
  DartLayoutManager._();

  /// Create a Yoga node for a view (stub method)
  YogaNode createNodeForView(String viewId) {
    return YogaNode();
  }

  /// Apply flexbox properties to a node (redirects to layout calculator)
  void applyFlexboxProps(String viewId, Map<String, dynamic> props) {
    _layoutCalculator.updateNodeLayoutProps(viewId, props);
  }

  /// Get a node for a view (stub method)
  YogaNode? getNodeForView(String viewId) {
    return null;
  }

  /// Register a parent-child relationship (stub method)
  void registerParentChild(String parentId, String childId) {}

  /// Calculate layout for a view hierarchy (stub method)
  Map<String, _LayoutResult> calculateLayout(
      String rootId, double width, double height) {
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
