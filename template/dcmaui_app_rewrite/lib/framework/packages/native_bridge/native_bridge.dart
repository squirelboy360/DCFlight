import 'dart:async';
import 'dart:io' show Platform;

import 'ffi_bridge.dart';

/// Abstract interface for platform-specific native bridges
abstract class NativeBridge {
  /// Initialize the native bridge
  Future<bool> initialize();

  /// Create a native view with the given ID, type and properties
  Future<bool> createView(
      String viewId, String type, Map<String, dynamic> props);

  /// Update a view's properties
  Future<bool> updateView(String viewId, Map<String, dynamic> propPatches);

  /// Delete a view
  Future<bool> deleteView(String viewId);

  /// Attach a child view to a parent view
  Future<bool> attachView(String childId, String parentId, int index);

  /// Set all children for a view (replacing existing children)
  Future<bool> setChildren(String viewId, List<String> childrenIds);

  /// Add event listener to a view
  Future<bool> addEventListeners(String viewId, List<String> eventTypes);

  /// Remove event listener from a view
  Future<bool> removeEventListeners(String viewId, List<String> eventTypes);

  /// Register a callback to handle native events
  void setEventHandler(
      Function(String viewId, String eventType, Map<String, dynamic> eventData)
          handler);

  /// Update a view's layout (position and size) directly
  Future<bool> updateViewLayout(
      String viewId, double left, double top, double width, double height);

  /// Request native text measurement
  Future<Map<String, double>> measureText(
      String viewId, String text, Map<String, dynamic> textAttributes);

  /// Calculate layout for the entire UI tree
  Future<bool> calculateLayout(
      {required double screenWidth, required double screenHeight});

  /// Synchronize node hierarchy between Dart and native
  Future<Map<String, dynamic>> syncNodeHierarchy(
      {required String rootId, required Map<String, dynamic> nodeTree});

  /// Get the native node hierarchy starting from a specific node
  Future<Map<String, dynamic>> getNodeHierarchy({required String nodeId});

  /// Invoke a method on the native side
  Future<dynamic> invokeMethod(String method,
      [Map<String, dynamic>? arguments]);

  /// Start a batch update
  Future<bool> startBatchUpdate();

  /// Commit a batch update
  Future<bool> commitBatchUpdate();

  /// Cancel a batch update
  Future<bool> cancelBatchUpdate();
}

/// Factory for creating platform-specific native bridges
class NativeBridgeFactory {
  static NativeBridge create() {
    if (Platform.isIOS || Platform.isMacOS) {
      return FFINativeBridge();
    } else {
      throw UnsupportedError('Unsupported platform for native bridge');
    }
  }
}
