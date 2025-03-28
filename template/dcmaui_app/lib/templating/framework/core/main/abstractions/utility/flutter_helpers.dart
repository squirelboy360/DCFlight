import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide TextStyle;
import 'package:flutter/cupertino.dart';

// void showFlutterView({required Widget flutterView}) {
//   runApp(flutterView);
// }

/// Utility functions for Flutter-specific operations
class FlutterUtility {
  /// Converts a Flutter Color object to a hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0')}';
  }

  /// Converts a hex string to a Flutter Color
  static Color hexToColor(String hex) {
    if (hex.startsWith('#')) {
      hex = hex.substring(1);
    }

    if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha if not present
    }

    return Color(int.parse(hex, radix: 16));
  }

  /// Logs information about the current platform and device
  static void logPlatformInfo() {
    debugPrint('Platform: ${defaultTargetPlatform.toString()}');

    // Use FlutterView.of or PlatformDispatcher instead of deprecated window
    final FlutterView view = PlatformDispatcher.instance.views.first;
    debugPrint('Device Pixel Ratio: ${view.devicePixelRatio}');
    debugPrint(
        'Screen Size: ${view.physicalSize.width}x${view.physicalSize.height}');
  }
}
