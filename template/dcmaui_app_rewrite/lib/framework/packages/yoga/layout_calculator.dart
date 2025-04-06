import 'dart:async';
import 'dart:developer' as developer;

import 'shadow_tree.dart';
import 'shadow_node.dart';
import 'yoga_enums.dart';
import '../../utilities/screen_utilities.dart';
import '../../packages/native_bridge/native_bridge.dart';

/// Calculator for layout computations and updates
class LayoutCalculator {
  /// Singleton instance
  static final LayoutCalculator instance = LayoutCalculator._();

  /// The shadow tree
  final ShadowTree _shadowTree = ShadowTree();

  /// Native bridge for UI updates
  NativeBridge? _nativeBridge;

  /// Whether a layout calculation is in progress
  bool _isCalculating = false;

  /// Create a new layout calculator
  LayoutCalculator._();

  /// Initialize with a native bridge
  void initialize(NativeBridge bridge) {
    _nativeBridge = bridge;

    // Listen for screen dimension changes
    ScreenUtilities.instance
        .addDimensionChangeListener(_onScreenDimensionsChanged);
  }

  /// Handle screen dimension changes
  void _onScreenDimensionsChanged() {
    // Recalculate layout with new dimensions
    calculateAndApplyLayout(null, null, YogaDirection.ltr, forceUpdate: true);
  }

  /// Add a node to the shadow tree
  void addNode(String id, {String? parentId, int? index}) {
    _shadowTree.addNode(id, parentId: parentId, index: index);
  }

  /// Update layout props for a node
  void updateNodeLayoutProps(String id, Map<String, dynamic> props) {
    _shadowTree.updateNodeProps(id, props);
  }

  /// Remove a node from the shadow tree
  void removeNode(String id) {
    _shadowTree.removeNode(id);
  }

  /// Clear the shadow tree
  void clearTree() {
    _shadowTree.clear();
  }

  /// Calculate and apply layout
  Future<void> calculateAndApplyLayout(
      double? width, double? height, YogaDirection direction,
      {bool forceUpdate = false}) async {
    if (_isCalculating && !forceUpdate) {
      developer.log('Layout calculation already in progress, skipping',
          name: 'LayoutCalculator');
      return;
    }

    developer.log('Starting layout calculation and application',
        name: 'LayoutCalculator');

    _isCalculating = true;

    try {
      // Get the start time
      final startTime = DateTime.now();

      // Calculate layout with proper parameters - handle null values
      _shadowTree.calculateLayout(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          direction: direction);

      // Get all nodes with calculated layout
      final allNodes = _shadowTree.nodes;
      developer.log('Built shadow tree with ${allNodes.length} nodes',
          name: 'LayoutCalculator');

      // Prepare for layout application
      final nodesToUpdate = <String, LayoutResult>{};

      // Collect layout results for all nodes
      for (final node in allNodes) {
        if (node.layout != null) {
          nodesToUpdate[node.id] = node.layout!;

          developer.log(
              'Layout for ${node.id}: left=${node.layout!.left}, top=${node.layout!.top}, width=${node.layout!.width}, height=${node.layout!.height}',
              name: 'LayoutCalculator');
        }
      }

      // Calculate duration
      final calculationDuration = DateTime.now().difference(startTime);
      developer.log(
          'Layout calculation completed in ${calculationDuration.inMilliseconds}ms for ${nodesToUpdate.length} nodes',
          name: 'LayoutCalculator');

      // Apply layout to native views
      if (_nativeBridge != null) {
        await _applyLayoutToNativeViews(nodesToUpdate);
      }
    } finally {
      _isCalculating = false;
    }
  }

  /// Apply layout to native views
  Future<void> _applyLayoutToNativeViews(
      Map<String, LayoutResult> layouts) async {
    if (_nativeBridge == null || layouts.isEmpty) return;

    developer.log('🔄 Applying layout for ${layouts.length} views',
        name: 'LayoutCalculator');

    try {
      // Apply each layout
      for (final entry in layouts.entries) {
        final viewId = entry.key;
        final layout = entry.value;

        final success = await _nativeBridge!.updateViewLayout(
            viewId, layout.left, layout.top, layout.width, layout.height);

        if (success) {
          developer.log('✅ Applied layout to $viewId: $layout',
              name: 'LayoutCalculator');
        } else {
          developer.log('❌ Failed to apply layout to $viewId: $layout',
              name: 'LayoutCalculator');
        }
      }

      developer.log('🎉 All layouts applied!', name: 'LayoutCalculator');
    } catch (e) {
      developer.log('❌ Error applying layout: $e',
          name: 'LayoutCalculator', error: e);
    }
  }

  /// Get layout for a node
  LayoutResult? getLayoutForNode(String id) {
    return _shadowTree.getLayoutForNode(id);
  }

  /// Get current node count for debugging
  int get nodeCount => _shadowTree.nodeCount;
}
