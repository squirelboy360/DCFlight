import 'package:flutter/services.dart';
import 'dart:developer' as developer;

/// Helper class for screen-related operations
class ScreenUtilities {
  static final ScreenUtilities _instance = ScreenUtilities._();

  /// Get the singleton instance
  static ScreenUtilities get instance => _instance;

  // Method channel for screen dimensions
  final MethodChannel _channel =
      const MethodChannel('com.dcmaui.screen_dimensions');

  // Cached dimensions
  double _screenWidth = 400.0; // Default fallback values
  double _screenHeight = 800.0;
  double _scale = 1.0;
  double _statusBarHeight = 0.0;

  ScreenUtilities._() {
    // Initialize dimensions on creation
    refreshDimensions();
  }

  /// Get screen width
  double get screenWidth => _screenWidth;

  /// Get screen height
  double get screenHeight => _screenHeight;

  /// Get pixel scale factor
  double get scale => _scale;

  /// Get status bar height
  double get statusBarHeight => _statusBarHeight;

  /// Update dimensions from method channel
  Future<void> refreshDimensions() async {
    try {
      final dimensions = await _channel
          .invokeMapMethod<String, dynamic>('getScreenDimensions');

      if (dimensions != null) {
        _screenWidth = dimensions['width'].toDouble();
        _screenHeight = dimensions['height'].toDouble();
        _scale = dimensions['scale'].toDouble();
        _statusBarHeight = dimensions['statusBarHeight'].toDouble();

        developer.log(
            'Screen dimensions updated: $_screenWidth x $_screenHeight',
            name: 'ScreenUtilities');
      }
    } catch (e) {
      developer.log('Failed to get screen dimensions: $e',
          name: 'ScreenUtilities');
    }
  }

  /// Calculate width from percentage
  double widthFromPercentage(String percentage) {
    if (percentage.endsWith('%')) {
      final value =
          double.tryParse(percentage.substring(0, percentage.length - 1));
      if (value != null) {
        return _screenWidth * value / 100.0;
      }
    }
    return 0;
  }

  /// Calculate height from percentage
  double heightFromPercentage(String percentage) {
    if (percentage.endsWith('%')) {
      final value =
          double.tryParse(percentage.substring(0, percentage.length - 1));
      if (value != null) {
        return _screenHeight * value / 100.0;
      }
    }
    return 0;
  }
}
