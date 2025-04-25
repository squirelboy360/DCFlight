import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dispatcher.dart';
import 'dart:developer' as developer;

/// Method channel-based implementation of NativeBridge
class PlatformDispatcherIml implements PlatformDispatcher {
  // Method channels
  static const MethodChannel bridgeChannel = MethodChannel('com.dcmaui.bridge');
  static const MethodChannel eventChannel = MethodChannel('com.dcmaui.events');
  static const MethodChannel layoutChannel = MethodChannel('com.dcmaui.layout');

  // Add batch update state
  bool _batchUpdateInProgress = false;
  final List<Map<String, dynamic>> _pendingBatchUpdates = [];

  // Event callback
  Function(String viewId, String eventType, Map<String, dynamic> eventData)?
      _eventHandler;

  // Map to store callbacks for each view and event type
  final Map<String, Map<String, Function>> _eventCallbacks = {};

  // Sets up communication with native code
  PlatformDispatcherIml() {
    // Set up method channels for events and layout
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

        debugPrint(
            'EVENT RECEIVED FROM NATIVE: $eventType for $viewId with data: $typedEventData');

        // First try to find the callback in _eventCallbacks
        final callback = _eventCallbacks[viewId]?[eventType];
        if (callback != null) {
          try {
            // Handle parameter count mismatch by checking function parameters
            final Function func = callback;
            if (func is Function()) {
              // No parameters - just call it directly
              func();
              debugPrint(
                  'Event callback executed for $eventType on $viewId (no params)');
            } else if (func is Function(Map<String, dynamic>)) {
              // One parameter - pass the event data
              func(typedEventData);
              debugPrint(
                  'Event callback executed for $eventType on $viewId (with event data)');
            } else {
              // Try anyway with a general approach
              Function.apply(callback, [], {});
              debugPrint(
                  'Event callback executed for $eventType on $viewId (direct apply)');
            }
          } catch (e) {
            debugPrint('Error executing callback: $e');
          }
        } else {
          // If no direct callback found, fall back to the global handler
          if (_eventHandler != null) {
            _eventHandler!(viewId, eventType, typedEventData);
            debugPrint('Event forwarded to global handler');
          } else {
            debugPrint('WARNING: No event handler registered to process event');
          }
        }
      }
      return null;
    });

    debugPrint('Method channel event handling initialized');
  }

  @override
  Future<bool> initialize() async {
    try {
      developer.log('Initializing method channel bridge', name: 'BRIDGE');
      final result = await bridgeChannel.invokeMethod<bool>('initialize');
      developer.log('Bridge initialization result: $result', name: 'BRIDGE');
      return result ?? false;
    } catch (e) {
      developer.log('Failed to initialize bridge: $e', name: 'BRIDGE');
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
      developer.log('Creating view via method channel: $viewId, $type',
          name: 'BRIDGE');

      // Preprocess props to handle special types before encoding to JSON
      final processedProps = _preprocessProps(props);

      final result = await bridgeChannel.invokeMethod<bool>('createView', {
        'viewId': viewId,
        'viewType': type,
        'props': processedProps,
      });

      return result ?? false;
    } catch (e) {
      developer.log('Method channel createView error: $e', name: 'BRIDGE');
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
      debugPrint("executing diffed props to native side $propPatches for view id: $viewId");
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
      developer.log('Method channel updateView error: $e', name: 'BRIDGE');
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
      developer.log('Method channel deleteView error: $e', name: 'BRIDGE');
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
      developer.log('Method channel attachView error: $e', name: 'BRIDGE');
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
      developer.log('Method channel setChildren error: $e', name: 'BRIDGE');
      return false;
    }
  }

  @override
  Future<bool> addEventListeners(String viewId, List<String> eventTypes) async {
    debugPrint('Registering for events: $viewId, $eventTypes');

    // Using method channel for events
    try {
      await eventChannel.invokeMethod('addEventListeners', {
        'viewId': viewId,
        'eventTypes': eventTypes,
      });
      debugPrint('Successfully registered events for view $viewId: $eventTypes');
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
      developer.log('Method channel event unregistration error: $e',
          name: 'BRIDGE');
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
      developer.log('Error updating view layout: $e', name: 'BRIDGE');
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
      developer.log('Error calculating layout: $e', name: 'BRIDGE');
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> syncNodeHierarchy({
    required String rootId,
    required String nodeTree,
  }) async {
    try {
      final result = await layoutChannel
          .invokeMapMethod<String, dynamic>('syncNodeHierarchy', {
        'rootId': rootId,
        'nodeTree': nodeTree,
      });

      return result ?? {'success': false, 'error': 'Invalid response'};
    } catch (e) {
      debugPrint("Error during node hierarchy sync: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> getNodeHierarchy(
      {required String nodeId}) async {
    try {
      final result = await layoutChannel
          .invokeMapMethod<String, dynamic>('getNodeHierarchy', {
        'nodeId': nodeId,
      });

      return result ?? {'error': 'Invalid response'};
    } catch (e) {
      debugPrint("Error getting node hierarchy: $e");
      return {'error': e.toString()};
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
      developer.log('Error checking view existence: $e', name: 'BRIDGE');
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
      developer.log(
          'Calling component method: $viewId.$methodName with args: $args',
          name: 'BRIDGE');
      return await bridgeChannel.invokeMethod('callComponentMethod', {
        'viewId': viewId,
        'methodName': methodName,
        'args': args,
      });
    } catch (e) {
      developer.log('Error calling component method $methodName on $viewId: $e',
          name: 'BRIDGE');
      return null; // Or throw an exception if preferred
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
  Future<bool> setVisualDebugEnabled(bool enabled) async {
    try {
      await layoutChannel
          .invokeMethod('setVisualDebugEnabled', {'enabled': enabled});
      return true;
    } catch (e) {
      debugPrint("Error enabling visual debugging: $e");
      return false;
    }
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
    // Find registered callback for this view and event
    if (_eventHandler != null) {
      _eventHandler!(viewId, eventType, eventData);
    } else {
      debugPrint('Warning: No event handler registered to process event');
    }
  }
}
