import 'dart:developer' as developer;
import 'package:dc_test/framework/constants/layout_properties.dart';
import 'package:dc_test/framework/packages/vdom/vdom_node.dart';
import 'package:dc_test/framework/packages/vdom/vdom_element.dart';
import 'package:dc_test/framework/packages/native_bridge/native_bridge.dart';
import 'package:dc_test/framework/packages/native_bridge/ffi_bridge.dart';
import 'shadow_tree.dart';

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

  @override
  String toString() {
    return 'LayoutResult(left: $left, top: $top, width: $width, height: $height)';
  }
}

/// Layout calculator that uses a shadow tree for computation
class LayoutCalculator {
  /// Singleton instance
  static final LayoutCalculator instance = LayoutCalculator._();

  /// Native bridge for updating view layouts
  final NativeBridge _nativeBridge = FFINativeBridge();

  /// Shadow tree for layout calculations
  final ShadowTree _shadowTree = ShadowTree();

  /// Track nodes that have been processed during tree building
  final Set<String> _processedNodes = {};

  /// Private constructor
  LayoutCalculator._();

  /// Calculate layout for a view hierarchy
  Map<String, LayoutResult> calculateLayout(
      VDomNode rootNode, dynamic width, dynamic height) {
    // Start layout calculation
    final startTime = DateTime.now();

    try {
      // Check if root node has an ID
      if (rootNode.nativeViewId == null) {
        developer.log('Root node has no ID, cannot calculate layout',
            name: 'LayoutCalc');
        return {};
      }

      // Clear tracking state
      _processedNodes.clear();

      // Build shadow tree from VDOM tree
      _buildShadowTree(rootNode);

      // Set root node ID
      _shadowTree.setRoot(rootNode.nativeViewId!);

      // Don't convert any percentage values - pass them directly to the shadow tree
      // Handle double.infinity by converting to "100%"
      dynamic actualWidth = width;
      dynamic actualHeight = height;

      if (width is double && width.isInfinite) {
        actualWidth = "100%";
      }

      if (height is double && height.isInfinite) {
        actualHeight = "100%";
      }

      // Calculate layout using the shadow tree
      final shadowResults =
          _shadowTree.calculateLayout(actualWidth, actualHeight);

      // Convert shadow tree results to layout results
      final layoutResults = <String, LayoutResult>{};

      for (final entry in shadowResults.entries) {
        layoutResults[entry.key] = LayoutResult(
          left: entry.value.left,
          top: entry.value.top,
          width: entry.value.width,
          height: entry.value.height,
        );
      }

      // Log calculation time
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      developer.log(
          'Layout calculated in ${duration.inMilliseconds}ms - ${layoutResults.length} nodes',
          name: 'LayoutCalc');

      return layoutResults;
    } catch (e, stack) {
      developer.log('Error calculating layout: $e',
          name: 'LayoutCalc', error: e, stackTrace: stack);
      return {};
    }
  }

  /// Build shadow tree from VDOM tree
  void _buildShadowTree(VDomNode node) {
    // Skip if node has no ID or has already been processed
    if (node.nativeViewId == null ||
        _processedNodes.contains(node.nativeViewId!)) {
      return;
    }

    // Mark node as processed
    _processedNodes.add(node.nativeViewId!);

    if (node is VDomElement) {
      // Create shadow node
      final shadowNode = _shadowTree.createNode(node.nativeViewId!);

      // Apply layout props
      final layoutProps = _extractLayoutProps(node.props);
      shadowNode.applyLayoutProps(layoutProps);

      // Process children
      for (final child in node.children) {
        if (child.nativeViewId != null) {
          // Build shadow tree for child
          _buildShadowTree(child);

          // Add child to parent in shadow tree
          _shadowTree.addChild(node.nativeViewId!, child.nativeViewId!);
        }
      }
    }
  }

  /// Extract layout props from component props
  Map<String, dynamic> _extractLayoutProps(Map<String, dynamic> props) {
    final layoutProps = <String, dynamic>{};

    for (final prop in props.entries) {
      if (LayoutProps.isLayoutProperty(prop.key)) {
        // For layout properties that are double.infinity, convert to "100%"
        var value = prop.value;
        if (value is double && value.isInfinite) {
          value = "100%";
        }
        layoutProps[prop.key] = value;
      }
    }

    return layoutProps;
  }

  /// Apply calculated layouts to native views
  Future<void> applyCalculatedLayouts(Map<String, LayoutResult> layouts) async {
    for (final entry in layouts.entries) {
      final viewId = entry.key;
      final layout = entry.value;
      await _nativeBridge.updateViewLayout(
          viewId, layout.left, layout.top, layout.width, layout.height);
    }
  }

  /// Calculate and apply layout in one step for convenience
  Future<Map<String, LayoutResult>> calculateAndApplyLayout(
    VDomNode rootNode,
    dynamic width,
    dynamic height,
  ) async {
    final layouts = calculateLayout(rootNode, width, height);
    await applyCalculatedLayouts(layouts);
    return layouts;
  }

  /// Update layout props for a specific node
  void updateNodeLayoutProps(String nodeId, Map<String, dynamic> layoutProps) {
    // Handle double.infinity in layout props
    final processedProps = <String, dynamic>{};
    for (var entry in layoutProps.entries) {
      var value = entry.value;
      if (value is double && value.isInfinite) {
        value = "100%";
      }
      processedProps[entry.key] = value;
    }

    _shadowTree.updateLayoutProps(nodeId, processedProps);
  }

  /// Remove a node from the shadow tree
  void removeNode(String nodeId) {
    _shadowTree.removeNode(nodeId);
  }

  /// Clear the entire shadow tree
  void clear() {
    _shadowTree.clear();
    _processedNodes.clear();
  }
}
