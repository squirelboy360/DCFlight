import 'dart:async';
import 'dispatcher_imp.dart';

/// Abstract interface for platform-specific native bridges
abstract class PlatformDispatcher {
  static PlatformDispatcher get instance => _instance!;
  static PlatformDispatcher? _instance;

  static void initializeInstance(PlatformDispatcher bridge) {
    _instance = bridge;
  }

  // Basic UI operations
  Future<bool> initialize();
  Future<bool> createView(
      String viewId, String type, Map<String, dynamic> props);
  Future<bool> updateView(String viewId, Map<String, dynamic> propPatches);
  Future<bool> deleteView(String viewId);
  Future<bool> attachView(String childId, String parentId, int index);
  Future<bool> setChildren(String viewId, List<String> childrenIds);

  // Event handling methods
  Future<bool> addEventListeners(String viewId, List<String> eventTypes);
  Future<bool> removeEventListeners(String viewId, List<String> eventTypes);
  void setEventHandler(
      Function(String viewId, String eventType, Map<String, dynamic> eventData)
          handler);

  // Add default implementation for handleNativeEvent instead of making it abstract
  void handleNativeEvent(
      String viewId, String eventType, Map<String, dynamic> eventData) {
    final viewCallbacks = _eventCallbacks[viewId];
    if (viewCallbacks != null && viewCallbacks.containsKey(eventType)) {
      final callback = viewCallbacks[eventType];
      if (callback != null) {
        callback(eventData);
      }
    }
  }

  // Layout methods
  Future<bool> updateViewLayout(
      String viewId, double left, double top, double width, double height);
  Future<bool> calculateLayout();

  // Node synchronization methods
  Future<Map<String, dynamic>> syncNodeHierarchy(
      {required String rootId, required String nodeTree});
  Future<Map<String, dynamic>> getNodeHierarchy({required String nodeId});

  // Text measurement
  Future<Map<String, double>> measureText(
      String viewId, String text, Map<String, dynamic> textAttributes);

  // Method invocation
  Future<dynamic> invokeMethod(String method,
      [Map<String, dynamic>? arguments]);

  // Batch updates
  Future<bool> startBatchUpdate();
  Future<bool> commitBatchUpdate();
  Future<bool> cancelBatchUpdate();

  // Debug features
  Future<bool> setVisualDebugEnabled(bool enabled);

  // Add a storage mechanism for event callbacks
  final Map<String, Map<String, Function>> _eventCallbacks = {};

  // Register an event callback for a specific view and event type
  void registerEventCallback(
      String viewId, String eventType, Function callback) {
    _eventCallbacks[viewId] ??= {};
    _eventCallbacks[viewId]![eventType] = callback;
  }
}

/// Factory for creating platform-specific native bridges
class NativeBridgeFactory {
  static PlatformDispatcher create() {
    return PlatformDispatcherIml();
  }
}
