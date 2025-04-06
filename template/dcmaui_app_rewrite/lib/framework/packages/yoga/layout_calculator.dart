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

    // Clear processed nodes and rebuild the shadow tree
    _processedNodes.clear();
    _shadowTree.clear();
    _buildShadowTree(rootNode);

    // Log how many nodes were built
    developer.log('Built shadow tree with ${_processedNodes.length} nodes',
        name: 'LayoutCalculator');

    // Set width and height for calculation
    // Convert percentages to numbers for Yoga calculation
    double calculationWidth = 0;
    double calculationHeight = 0;

    if (width is String && width.endsWith('%')) {
      // For percentages, use a standard reference (like 100% = 400pt)
      calculationWidth = 400.0; // Default viewport width
    } else if (width is num) {
      calculationWidth = width.toDouble();
    }

    if (height is String && height.endsWith('%')) {
      // For percentages, use a standard reference (like 100% = 800pt)
      calculationHeight = 800.0; // Default viewport height
    } else if (height is num) {
      calculationHeight = height.toDouble();
    }

    // Ensure we have valid dimensions
    calculationWidth = calculationWidth > 0 ? calculationWidth : 400.0;
    calculationHeight = calculationHeight > 0 ? calculationHeight : 800.0;

    developer.log(
        'Calculating layout with dimensions: $calculationWidth x $calculationHeight',
        name: 'LayoutCalculator');

    // Calculate layout using shadow tree
    _shadowTree.calculateLayout(
      width: calculationWidth,
      height: calculationHeight,
    );

    // Extract layout results for all nodes
    final layoutResults = <String, LayoutResult>{};

    for (var nodeId in _processedNodes) {
      final nodeLayout = _shadowTree.getNodeLayout(nodeId);
      if (nodeLayout != null) {
        layoutResults[nodeId] = LayoutResult(
          left: nodeLayout.left,
          top: nodeLayout.top,
          width: nodeLayout.width,
          height: nodeLayout.height,
        );

        // Log each layout result for debugging
        developer.log(
            'Layout for $nodeId: left=${nodeLayout.left}, top=${nodeLayout.top}, width=${nodeLayout.width}, height=${nodeLayout.height}',
            name: 'LayoutCalculator');
      }
    }

    final endTime = DateTime.now();
    final elapsed = endTime.difference(startTime).inMilliseconds;
    developer.log(
        'Layout calculation completed in ${elapsed}ms for ${layoutResults.length} nodes',
        name: 'LayoutCalculator');

    return layoutResults;
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
      // Extract layout properties
      final layoutProps = _extractLayoutProps(node.props);

      // Add node to shadow tree
      _shadowTree.addNode(
        id: node.nativeViewId!,
        parentId: node.parent?.nativeViewId,
        layoutProps: layoutProps,
      );

      // Process children
      for (var child in node.children) {
        _buildShadowTree(child);
      }
    }
  }

  /// Extract layout props from component props
  Map<String, dynamic> _extractLayoutProps(Map<String, dynamic> props) {
    final layoutProps = <String, dynamic>{};

    for (final prop in props.entries) {
      if (LayoutProps.isLayoutProperty(prop.key)) {
        layoutProps[prop.key] = prop.value;
      }
    }

    return layoutProps;
  }

  /// Apply calculated layouts to native views
  Future<void> applyCalculatedLayouts(Map<String, LayoutResult> layouts) async {
    developer.log('🔄 Applying layout for ${layouts.length} views',
        name: 'LayoutCalculator');

    for (final entry in layouts.entries) {
      final viewId = entry.key;
      final layout = entry.value;

      // Apply layout using native bridge
      final success = await _nativeBridge.updateViewLayout(
        viewId,
        layout.left,
        layout.top,
        layout.width,
        layout.height,
      );

      developer.log('${success ? '✅' : '❌'} Applied layout to $viewId: $layout',
          name: 'LayoutCalculator');
    }

    developer.log('🎉 All layouts applied!', name: 'LayoutCalculator');
  }

  /// Calculate and apply layout in one step for convenience
  Future<Map<String, LayoutResult>> calculateAndApplyLayout(
    VDomNode rootNode,
    dynamic width,
    dynamic height,
  ) async {
    developer.log('Starting layout calculation and application',
        name: 'LayoutCalculator');

    final layouts = calculateLayout(rootNode, width, height);

    if (layouts.isEmpty) {
      developer.log('WARNING: No layouts were calculated!',
          name: 'LayoutCalculator');
    }

    await applyCalculatedLayouts(layouts);
    return layouts;
  }

  /// Update layout props for a specific node
  void updateNodeLayoutProps(String nodeId, Map<String, dynamic> layoutProps) {
    _shadowTree.updateNodeProps(nodeId, layoutProps);
  }

  /// Remove a node from the shadow tree
  void removeNode(String nodeId) {
    _shadowTree.removeNode(nodeId);
    _processedNodes.remove(nodeId);
  }

  /// Clear the entire shadow tree
  void clear() {
    _shadowTree.clear();
    _processedNodes.clear();
  }

  /// Add this method to clear the shadow tree and rebuild it
  void clearAndRebuildShadowTree(VDomNode? rootNode) {
    _processedNodes.clear();
    _shadowTree.clear();

    if (rootNode != null) {
      _buildShadowTree(rootNode);
      developer.log('Shadow tree rebuilt with ${_processedNodes.length} nodes',
          name: 'LayoutCalculator');
    }
  }

  /// Add this method to invalidate the layout
  void invalidateLayout() {
    developer.log('Invalidating layout calculations', name: 'LayoutCalculator');

    // We'll mark all nodes as dirty to force recalculation
    for (var nodeId in _processedNodes) {
      _shadowTree.markNodeDirty(nodeId);
    }
  }
}
