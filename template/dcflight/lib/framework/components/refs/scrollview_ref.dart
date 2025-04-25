import 'package:dcflight/framework/packages/native_bridge/dispatcher.dart';
import 'package:flutter/foundation.dart';

/// Reference to control ScrollView components
class ScrollViewRef {
  /// View ID of the associated ScrollView component
  String? _viewId;

  /// Set the associated view ID (called internally by the framework)
  void setViewId(String viewId) {
    _viewId = viewId;
    debugPrint('🔗 ScrollViewRef attached to view: $viewId');
  }

  /// Get the associated view ID
  String? get viewId => _viewId;

  /// Scroll to a specific offset
  /// 
  /// [x] Horizontal scroll offset
  /// [y] Vertical scroll offset
  /// [animated] Whether to animate the scroll
  Future<void> scrollTo({
    required double x,
    required double y,
    bool animated = true,
  }) async {
    if (_viewId == null) {
      debugPrint('⚠️ Cannot scroll: ScrollViewRef not attached to any ScrollView');
      return;
    }
    
    try {
      // Fixed: Using positional parameters instead of named parameters
      await PlatformDispatcher.instance.callComponentMethod(
        _viewId!,
        'scrollTo',
        {
          'x': x,
          'y': y,
          'animated': animated,
        },
      );
      debugPrint('✅ Scrolled to position ($x, $y) on view $_viewId');
    } catch (e) {
      debugPrint('❌ Failed to scroll: $e');
    }
  }

  /// Scroll to the bottom of the view
  Future<void> scrollToBottom({bool animated = true}) async {
    if (_viewId == null) {
      debugPrint('⚠️ Cannot scroll to bottom: ScrollViewRef not attached to any ScrollView');
      return;
    }
    
    try {
      // Fixed: Using positional parameters instead of named parameters
      await PlatformDispatcher.instance.callComponentMethod(
        _viewId!,
        'scrollToEnd',
        {
          'animated': animated,
        },
      );
      debugPrint('✅ Scrolled to bottom on view $_viewId');
    } catch (e) {
      debugPrint('❌ Failed to scroll to bottom: $e');
    }
  }
  
  /// Scroll to the top of the view
  Future<void> scrollToTop({bool animated = true}) async {
    await scrollTo(x: 0, y: 0, animated: animated);
  }
}