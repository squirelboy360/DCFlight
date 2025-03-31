import 'dart:async';
import 'dart:developer' as developer;
import '../native_bridge/native_bridge.dart';
import '../yoga/layout_calculator.dart';

/// Class to manage scroll content metrics and virtualization
class ScrollMetricsManager {
  /// Singleton instance
  static final ScrollMetricsManager instance = ScrollMetricsManager._();

  /// Map of content sizes for scroll views
  final Map<String, ScrollMetrics> _contentSizes = {};

  /// Native bridge for communicating sizes back to native
  late final NativeBridge _nativeBridge;

  /// Private constructor
  ScrollMetricsManager._();

  /// Initialize the manager
  void initialize(NativeBridge bridge) {
    _nativeBridge = bridge;
  }

  /// Update content metrics for a scroll view
  Future<void> updateContentMetrics(
      String scrollViewId, double contentWidth, double contentHeight) async {
    // Ensure positive content dimensions with minimums
    contentWidth = contentWidth > 0 ? contentWidth : 100.0;
    contentHeight = contentHeight > 0 ? contentHeight : 100.0;

    // If no change in content size, skip update
    if (_contentSizes.containsKey(scrollViewId) &&
        _contentSizes[scrollViewId]!.contentWidth == contentWidth &&
        _contentSizes[scrollViewId]!.contentHeight == contentHeight) {
      return;
    }

    developer.log(
        'Updating scroll metrics for $scrollViewId: $contentWidth x $contentHeight',
        name: 'ScrollMetrics');

    // Store metrics
    _contentSizes[scrollViewId] = ScrollMetrics(
      contentWidth: contentWidth,
      contentHeight: contentHeight,
    );

    // Update native scroll view with content size
    try {
      await _sendContentSizeToNative(scrollViewId, contentWidth, contentHeight);
    } catch (e) {
      developer.log('Error sending content size to native: $e',
          name: 'ScrollMetrics');
    }
  }

  /// Calculate content size based on layout results
  Future<void> calculateContentSizeFromLayout(
      String scrollViewId,
      Map<String, LayoutResult> layoutResults,
      List<String> childViewIds) async {
    if (childViewIds.isEmpty) {
      return;
    }

    // Find the max right and bottom edges of children
    double maxRight = 0;
    double maxBottom = 0;

    for (final childId in childViewIds) {
      if (layoutResults.containsKey(childId)) {
        final layout = layoutResults[childId]!;
        // Calculate the right and bottom edges
        final right = layout.left + layout.width;
        final bottom = layout.top + layout.height;

        maxRight = maxRight > right ? maxRight : right;
        maxBottom = maxBottom > bottom ? maxBottom : bottom;
      }
    }

    // Add padding to ensure content is fully visible
    maxRight += 16; // Add some padding on the right
    maxBottom += 16; // Add some padding at the bottom

    developer.log(
        'Calculated scroll content bounds for $scrollViewId: $maxRight x $maxBottom',
        name: 'ScrollMetrics');

    // Update the content size
    await updateContentMetrics(scrollViewId, maxRight, maxBottom);
  }

  /// Send content size to native
  Future<void> _sendContentSizeToNative(
      String scrollViewId, double width, double height) async {
    // Update the view with content size properties
    final contentSizeProps = {
      'contentWidth': width,
      'contentHeight': height,
    };

    developer.log(
        'Sending content size to native for $scrollViewId: $width x $height',
        name: 'ScrollMetrics');

    await _nativeBridge.updateView(scrollViewId, contentSizeProps);
  }

  /// Get cached metrics for a scroll view
  ScrollMetrics? getMetrics(String scrollViewId) {
    return _contentSizes[scrollViewId];
  }

  /// Clear metrics for a scroll view
  void clearMetrics(String scrollViewId) {
    _contentSizes.remove(scrollViewId);
  }

  /// Update visible region for virtualized content
  Future<void> updateVisibleRegion(String scrollViewId, double x, double y,
      double width, double height) async {
    // This will be used for virtualization in the future
  }
}

/// Internal class to store scroll metrics
class ScrollMetrics {
  final double contentWidth;
  final double contentHeight;

  ScrollMetrics({required this.contentWidth, required this.contentHeight});
}
