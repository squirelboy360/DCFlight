import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dispatcher.dart';

/// Method channel-based implementation of NativeBridge
class PlatformDispatcherIml implements PlatformDispatcher {
  // Method channels
  static const MethodChannel bridgeChannel = MethodChannel('com.dcmaui.bridge');
  static const MethodChannel eventChannel = MethodChannel('com.dcmaui.events');
  static const MethodChannel layoutChannel = MethodChannel('com.dcmaui.layout');

  // Add batch update state
  bool _batchUpdateInProgress = false;
  final List<Map<String, dynamic>> _pendingBatchUpdates = [];

  // Map to store callbacks for each view and event type
  final Map<String, Map<String, Function>> _eventCallbacks = {};
  
  // Global event handler for fallback when a specific callback isn't found
  Function(String viewId, String eventType, Map<String, dynamic> eventData)? _eventHandler;

  // Sets up communication with native code
  PlatformDispatcherIml() {
    // Set up method channels for events
    _setupMethodChannelEventHandling();
    debugPrint('Method channel bridge initialized');
  }

  // Set up method channel for event handling
  void _setupMethodChannelEventHandling() {
    eventChannel.setMethodCallHandler((call) async {
      if (call.method == 'onEvent') {
        final Map<dynamic, dynamic> args = call.arguments;
        final String viewId = args['viewId'];
        final String eventType = args['eventType'];
        final Map<dynamic, dynamic> eventData = args['eventData'] ?? {};

        // Convert dynamic map to String, dynamic map
        final typedEventData = eventData.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );

        // Forward the event to the handler
        handleNativeEvent(viewId, eventType, typedEventData);
      }
      return null;
    });
  }

  @override
  Future<bool> initialize() async {
    try {
      final result = await bridgeChannel.invokeMethod<bool>('initialize');
      return result ?? false;
    } catch (e) {
      debugPrint('Failed to initialize bridge: $e');
      return false;
    }
  }

  @override
  Future<bool> createView(
      String viewId, String type, Map<String, dynamic> props) async {
    // Track operation for batch updates if needed
    if (_batchUpdateInProgress) {
      _pendingBatchUpdates.add({
        'operation': 'createView',
        'viewId': viewId,
        'viewType': type,
        'props': props,
      });
      return true;
    }

    try {
      // Preprocess props to handle special types before encoding to JSON
      final processedProps = _preprocessProps(props);

      final result = await bridgeChannel.invokeMethod<bool>('createView', {
        'viewId': viewId,
        'viewType': type,
        'props': processedProps,
      });

      return result ?? false;
    } catch (e) {
      debugPrint('Method channel createView error: $e');
      return false;
    }
  }

  @override
  Future<bool> updateView(
      String viewId, Map<String, dynamic> propPatches) async {
    // Track operation for batch updates if needed
    if (_batchUpdateInProgress) {
      _pendingBatchUpdates.add({
        'operation': 'updateView',
        'viewId': viewId,
        'props': propPatches,
      });
      return true;
    }

    try {
      // Process props for updates
      final processedProps = _preprocessProps(propPatches);

      final result = await bridgeChannel.invokeMethod<bool>('updateView', {
        'viewId': viewId,
        'props': processedProps,
      });

      return result ?? false;
    } catch (e) {
      debugPrint('Method channel updateView error: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteView(String viewId) async {
    try {
      final result = await bridgeChannel.invokeMethod<bool>('deleteView', {
        'viewId': viewId,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('Method channel deleteView error: $e');
      return false;
    }
  }

  @override
  Future<bool> attachView(String childId, String parentId, int index) async {
    try {
      final result = await bridgeChannel.invokeMethod<bool>('attachView', {
        'childId': childId,
        'parentId': parentId,
        'index': index,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('Method channel attachView error: $e');
      return false;
    }
  }

  @override
  Future<bool> setChildren(String viewId, List<String> childrenIds) async {
    try {
      final result = await bridgeChannel.invokeMethod<bool>('setChildren', {
        'viewId': viewId,
        'childrenIds': childrenIds,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('Method channel setChildren error: $e');
      return false;
    }
  }

  @override
  Future<bool> addEventListeners(String viewId, List<String> eventTypes) async {
    try {
      await eventChannel.invokeMethod('addEventListeners', {
        'viewId': viewId,
        'eventTypes': eventTypes,
      });
      return true;
    } catch (e) {
      debugPrint('Error registering events: $e');
      return false;
    }
  }

  @override
  Future<bool> removeEventListeners(
      String viewId, List<String> eventTypes) async {
    try {
      final result =
          await eventChannel.invokeMethod<bool>('removeEventListeners', {
        'viewId': viewId,
        'eventTypes': eventTypes,
      });

      return result ?? false;
    } catch (e) {
      debugPrint('Method channel event unregistration error: $e');
      return false;
    }
  }

  @override
  void setEventHandler(
      Function(String viewId, String eventType, Map<String, dynamic> eventData)
          handler) {
    _eventHandler = handler;
  }

  @override
  Future<bool> updateViewLayout(String viewId, double left, double top,
      double width, double height) async {
    try {
      final result =
          await layoutChannel.invokeMethod<bool>('updateViewLayout', {
        'viewId': viewId,
        'left': left,
        'top': top,
        'width': width,
        'height': height,
      });

      return result ?? false;
    } catch (e) {
      debugPrint('Error updating view layout: $e');
      return false;
    }
  }

  @override
  Future<bool> calculateLayout() async {
    try {
      final result =
          await layoutChannel.invokeMethod<bool>('calculateLayout', {});
      return result ?? false;
    } catch (e) {
      debugPrint('Error calculating layout: $e');
      return false;
    }
  }

  @override
  Future<bool> viewExists(String viewId) async {
    try {
      final result = await bridgeChannel.invokeMethod<bool>('viewExists', {
        'viewId': viewId,
      });
      
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking view existence: $e');
      return false;
    }
  }

  // Helper method to preprocess props for JSON serialization
  Map<String, dynamic> _preprocessProps(Map<String, dynamic> props) {
    final processedProps = <String, dynamic>{};

    props.forEach((key, value) {
      if (value is Function) {
        // Handle event handlers
        if (key.startsWith('on')) {
          key.substring(2).toLowerCase();
          processedProps['_has${key.substring(2)}Handler'] = true;
        }
      } else if (value is Color) {
        // Convert Color objects to hex strings with alpha
        processedProps[key] =
            '#${value.value.toRadixString(16).padLeft(8, '0')}';
      } else if (value == double.infinity) {
        // Convert infinity to 100% string for percentage sizing
        processedProps[key] = '100%';
      } else if (value is String &&
          (value.endsWith('%') || value.startsWith('#'))) {
        // Pass percentage strings and color strings through directly
        processedProps[key] = value;
      } else if (key == 'width' ||
          key == 'height' ||
          key.startsWith('margin') ||
          key.startsWith('padding')) {
        // Make sure numeric values go through as doubles for consistent handling
        if (value is num) {
          processedProps[key] = value.toDouble();
        } else {
          processedProps[key] = value;
        }
      } else if (value != null) {
        processedProps[key] = value;
      }
    });

    return processedProps;
  }

  @override
  Future<dynamic> invokeMethod(String method,
      [Map<String, dynamic>? arguments]) async {
    try {
      return await bridgeChannel.invokeMethod(method, arguments);
    } catch (e) {
      debugPrint('Error invoking method $method: $e');
      return null;
    }
  }

  @override
  Future<dynamic> callComponentMethod(
      String viewId, String methodName, Map<String, dynamic> args) async {
    try {
      return await bridgeChannel.invokeMethod('callComponentMethod', {
        'viewId': viewId,
        'methodName': methodName,
        'args': args,
      });
    } catch (e) {
      debugPrint('Error calling component method $methodName on $viewId: $e');
      return null;
    }
  }

  @override
  Future<bool> startBatchUpdate() async {
    if (_batchUpdateInProgress) {
      return false;
    }

    _batchUpdateInProgress = true;
    _pendingBatchUpdates.clear();
    return true;
  }

  @override
  Future<bool> commitBatchUpdate() async {
    if (!_batchUpdateInProgress) {
      return false;
    }

    try {
      final success =
          await bridgeChannel.invokeMethod<bool>('commitBatchUpdate', {
        'updates': _pendingBatchUpdates,
      });

      _batchUpdateInProgress = false;
      _pendingBatchUpdates.clear();
      return success ?? false;
    } catch (e) {
      _batchUpdateInProgress = false;
      _pendingBatchUpdates.clear();
      return false;
    }
  }

  @override
  Future<bool> cancelBatchUpdate() async {
    if (!_batchUpdateInProgress) {
      return false;
    }

    _batchUpdateInProgress = false;
    _pendingBatchUpdates.clear();
    return true;
  }

  @override
  void registerEventCallback(
      String viewId, String eventType, Function callback) {
    _eventCallbacks[viewId] ??= {};
    _eventCallbacks[viewId]![eventType] = callback;
  }

  @override
  void handleNativeEvent(
      String viewId, String eventType, Map<String, dynamic> eventData) {
    // First try to find a specific callback for this view and event
    final callback = _eventCallbacks[viewId]?[eventType];
    if (callback != null) {
      try {
        // Handle parameter count mismatch by checking function parameters
        final Function func = callback;
        if (func is Function()) {
          func();
        } else if (func is Function(Map<String, dynamic>)) {
          func(eventData);
        } else {
          Function.apply(callback, [], {});
        }
        return;
      } catch (e) {
        debugPrint('Error executing callback: $e');
      }
    }
    
    // If no specific callback found, use the global event handler as fallback
    if (_eventHandler != null) {
      try {
        _eventHandler!(viewId, eventType, eventData);
      } catch (e) {
        debugPrint('Error executing global event handler: $e');
      }
    }
  }
}
