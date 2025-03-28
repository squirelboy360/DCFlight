import 'package:dc_test/templating/framework/core/main/interface/main_view_coordinator.dart';

/// Main entry point for the DC MAUI Framework
/// Exposes all components and utilities

// Core system
export 'core/main/interface/main_view_coordinator.dart';
export 'core/vdom/vdom/vdom.dart';

// Controls/Components
export 'controls/index.dart';

// Layout components
export 'controls/view.dart';
export 'controls/scrollview.dart';
export 'controls/safe_area_view.dart';

// Text components
export 'controls/text.dart';
export 'controls/textinput.dart';

// Interactive components
export 'controls/button.dart';
export 'controls/checkbox.dart';
export 'controls/switch.dart';
export 'controls/gesture_detector.dart';
export 'controls/touchable_highlight.dart';
export 'controls/touchable_opacity.dart';
export 'controls/touchable_without_feedback.dart';

// Media components
export 'controls/image.dart';
export 'controls/modal.dart';

// List components
export 'controls/list_view.dart';

// Specialized components
export 'controls/activity_indicator.dart';
export 'controls/animated_view.dart';

// Hooks system
export 'core/main/abstractions/hooks/use_state.dart';

// Utilities
export 'core/main/abstractions/utility/flutter_helpers.dart';
export 'core/main/abstractions/utility/performance_monitor.dart';





/// DC Framework Version
const String dcFrameworkVersion = '0.1.1'; // Updated version

// Add debugging helpers for common framework issues
class DCFrameworkDebug {
  /// Check if native bridge is properly connected
  static Future<bool> checkNativeBridge() async {
    try {
      // Try to create a simple view to test the bridge
      await MainViewCoordinatorInterface.createView(
          'debug_test_view', 'DCView', {
        'style': {'backgroundColor': '#FFFFFF'}
      });
      return true;
    } catch (e) {
      print('DC Framework: Native bridge test failed - $e');
      return false;
    }
  }

  /// Log the active view registry for debugging
  static void logViewRegistry() {
    MainViewCoordinatorInterface().logNativeViewTree();
  }

  /// Reset the view registry if views become unresponsive
  static Future<bool> resetRegistry() async {
    try {
      await MainViewCoordinatorInterface.resetViewRegistry();
      return true;
    } catch (e) {
      print('DC Framework: Reset registry failed - $e');
      return false;
    }
  }
}
