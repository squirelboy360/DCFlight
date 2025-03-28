import 'dart:async';
import 'package:dc_test/templating/framework/core/main/abstractions/hooks/low_levels/state_abstraction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MainViewCoordinatorInterface {
  static const MethodChannel _channel = MethodChannel('com.dcmaui.framework');
  static const EventChannel _eventChannel =
      EventChannel('com.dcmaui.framework/events');

  static final StreamController<Map<String, dynamic>> _eventController =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get eventStream =>
      _eventController.stream;

  static bool _initialized = false;

  // Initialize the coordinator
  static Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('DC MAUI: Setting up method channel handler');
    _channel.setMethodCallHandler(_handleMethodCall);

    debugPrint('DC MAUI: Setting up event channel listener');
    _eventChannel.receiveBroadcastStream().map<Map<String, dynamic>>((event) {
      if (event is Map) {
        return _convertToStringKeyMap(event as Map<Object?, Object?>);
      }
      return {'error': 'Invalid event format'};
    }).listen((event) {
      debugPrint('DC MAUI: Received event from native: $event');

      // Process events from native to dispatch to handlers
      if (event.containsKey('viewId') &&
          event.containsKey('eventName') &&
          event.containsKey('params')) {
        final viewId = event['viewId'] as String;
        final eventName = event['eventName'] as String;
        final params = event['params'] as Map<String, dynamic>;

        // Find and call the registered handler
        final handler =
            GlobalStateManager.instance.getEventHandler(viewId, eventName);
        if (handler != null) {
          debugPrint(
              'DC MAUI: Dispatching event $eventName to handler for view $viewId');
          try {
            handler(params);
          } catch (e) {
            debugPrint('DC MAUI: Error in event handler: $e');
          }
        }
      }

      _eventController.add(event);
    });

    try {
      // Send initialize signal to native side
      debugPrint('DC MAUI: Calling initialize on native side');
      await _channel.invokeMethod('initialize');
      _initialized = true;
      debugPrint('DC MAUI: MainViewCoordinatorInterface initialized');
    } catch (e) {
      debugPrint('DC MAUI: ERROR initializing - $e');
      // Create root container view manually to bypass initialization
      await createRootContainer();
    }
  }

  // Helper method to convert Map<Object?, Object?> to Map<String, dynamic>
  static Map<String, dynamic> _convertToStringKeyMap(
      Map<Object?, Object?> map) {
    return Map<String, dynamic>.fromEntries(
      map.entries.map(
        (entry) => MapEntry(
          entry.key.toString(),
          _convertValue(entry.value),
        ),
      ),
    );
  }

  // Helper method to recursively convert values
  static dynamic _convertValue(Object? value) {
    if (value is Map<Object?, Object?>) {
      return _convertToStringKeyMap(value);
    } else if (value is List) {
      return value.map((item) => _convertValue(item)).toList();
    }
    return value;
  }

  // Create a root container view directly
  static Future<void> createRootContainer() async {
    try {
      debugPrint('DC MAUI: Creating root container view');
      await _channel.invokeMethod('createRootContainer');
    } catch (e) {
      debugPrint('DC MAUI: ERROR creating root container - $e');
    }
  }

  // Create a view on the native side
  static Future<bool> createView(
      String viewId, String viewType, Map<String, dynamic> props) async {
    try {
      // Clean the props to ensure they're serializable
      final cleanProps = _cleanPropsForSerialization(props);

      debugPrint('DC MAUI: Creating view $viewId of type $viewType');
      final result = await _channel.invokeMethod('createView', {
        'viewId': viewId,
        'viewType': viewType,
        'props': cleanProps,
      });
      debugPrint('Core: View created result: $result');
      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR creating view: $e');
      debugPrint('Core: Props that failed: $props');
      return false;
    }
  }

  // Update a view's properties
  static Future<bool> updateView(
      String viewId, Map<String, dynamic> props) async {
    try {
      final cleanProps = _cleanPropsForSerialization(props);

      // Add enhanced debugging for state updates
      debugPrint('Core: Updating view $viewId with props: $cleanProps');

      final result = await _channel.invokeMethod('updateView', {
        'viewId': viewId,
        'props': cleanProps,
      });

      // Debug the result
      debugPrint('Core: View update result: $result');

      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR updating view: $e');
      return false;
    }
  }

  // Delete a view from the native side
  static Future<bool> deleteView(String viewId) async {
    try {
      final result =
          await _channel.invokeMethod('deleteView', {'viewId': viewId});
      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR deleting view: $e');
      return false;
    }
  }

  // Set children relationship on native side
  static Future<bool> setChildren(
      String parentId, List<String> childIds) async {
    try {
      // Debug output to check parameter values
      debugPrint('Core: Setting children for $parentId: $childIds');

      final result = await _channel.invokeMethod('setChildren', {
        'parentId': parentId,
        'childIds': childIds, // Make sure this key matches what Swift expects
      });
      debugPrint('Core: SetChildren result: $result');
      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR setting children: $e');
      // Add more detailed error information
      debugPrint(
          'Core: Parameters were: parentId=$parentId, childIds=$childIds');
      return false;
    }
  }

  // Register event listeners for a view - enhanced implementation
  static Future<bool> addEventListeners(
      String viewId, List<String> eventNames) async {
    try {
      debugPrint('Core: Adding event listeners: $eventNames for view: $viewId');

      // CRITICAL FIX: The Swift code expects 'eventTypes' not 'eventNames'
      final result = await _channel.invokeMethod('addEventListeners', {
        'viewId': viewId,
        'eventTypes':
            eventNames, // Changed key from 'eventNames' to 'eventTypes'
      });

      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR adding event listeners: $e');
      return false;
    }
  }

  // Remove event listeners from a view
  static Future<bool> removeEventListeners(
      String viewId, List<String> eventNames) async {
    try {
      final result = await _channel.invokeMethod('removeEventListeners', {
        'viewId': viewId,
        'eventNames': eventNames,
      });
      return result == true;
    } catch (e) {
      debugPrint('Core: ERROR removing event listeners: $e');
      return false;
    }
  }

  // Get information about a view
  static Future<Map<String, dynamic>?> getViewInfo(String viewId) async {
    try {
      final result = await _channel.invokeMethod('getViewInfo', {
        'viewId': viewId,
      });

      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } catch (e) {
      debugPrint('DC MAUI: Error getting view info: $e');
      return null;
    }
  }

  // Reset the view registry (for recovery from errors)
  static Future<bool> resetViewRegistry() async {
    try {
      final result = await _channel.invokeMethod('resetViewRegistry');
      return result == true;
    } catch (e) {
      debugPrint('DC MAUI: ERROR resetting view registry - $e');
      return false;
    }
  }

  // CRITICAL FIX: Improved event handling for received events
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint(
        'DC MAUI: Received method call: ${call.method} with args: ${call.arguments}');

    if (call.method == 'onNativeEvent') {
      final event =
          _convertToStringKeyMap(call.arguments as Map<Object?, Object?>);
      final String viewId = event['viewId'];

      // Get the original event name from native
      String originalEventName = event['eventName'] ?? '';
      debugPrint('DC MAUI: Received event $originalEventName for view $viewId');

      // Generate all possible standardized event name formats to try
      final possibleEventNames = _getAllPossibleEventNames(originalEventName);
      debugPrint('DC MAUI: Trying event names: $possibleEventNames');

      // Find a matching handler
      Function? handler;
      String? matchedEventName;

      for (final eventName in possibleEventNames) {
        handler =
            GlobalStateManager.instance.getEventHandler(viewId, eventName);
        if (handler != null) {
          matchedEventName = eventName;
          debugPrint('DC MAUI: Found handler for event name: $eventName');
          break;
        }
      }

      // Ensure params match React Native format
      Map<String, dynamic> params;
      if (event['params'] is Map) {
        params = event['params'] as Map<String, dynamic>;

        // Make sure target is included
        if (!params.containsKey('target')) {
          params['target'] = viewId;
        }
      } else {
        // Default empty params with target
        params = {'target': viewId};
      }

      // Call handler if found
      if (handler != null && matchedEventName != null) {
        try {
          debugPrint(
              'DC MAUI: Invoking handler for event $originalEventName (matched to $matchedEventName) on view $viewId');
          handler(params);
        } catch (e, stack) {
          debugPrint('DC MAUI: Error in event handler: $e');
          debugPrint('Stack trace: $stack');
        }
      } else {
        debugPrint(
            'DC MAUI: No handler found for event $originalEventName on view $viewId');
      }

      // Use a standardized event name for consistency in streams
      final standardizedEventName = possibleEventNames.isNotEmpty
          ? possibleEventNames[0]
          : originalEventName;

      _eventController.add({
        'viewId': viewId,
        'eventName': standardizedEventName,
        'params': params,
      });

      return;
    } else if (call.method == 'logTree') {
      final treeData = call.arguments as String;
      debugPrint(
          '\n=== NATIVE VIEW TREE ===\n$treeData\n=====================');
      return;
    }

    return null;
  }

  // Helper method to generate all possible event name formats
  static List<String> _getAllPossibleEventNames(String originalEventName) {
    final result = <String>[];

    // React-style with 'on' prefix
    if (originalEventName.startsWith('on')) {
      result.add(originalEventName);

      // Add version with different casing
      final eventNameWithoutPrefix = originalEventName.substring(2);
      result.add(
          'on${eventNameWithoutPrefix.substring(0, 1).toUpperCase()}${eventNameWithoutPrefix.substring(1)}');
      result.add(
          'on${eventNameWithoutPrefix.substring(0, 1).toLowerCase()}${eventNameWithoutPrefix.substring(1)}');
    }
    // Native-style without 'on' prefix
    else {
      // Add standard React-style version
      final capitalized = originalEventName.substring(0, 1).toUpperCase() +
          originalEventName.substring(1);
      result.add('on$capitalized');

      // Add other variants
      result.add('on$originalEventName');
      result.add(originalEventName);

      // Handle special case for longPress which is a common issue
      if (originalEventName.toLowerCase() == 'longpress') {
        result.add('onLongPress');
        result.add('longPress');
      }
    }

    return result;
  }

  // Add a method to request the native side to print its view tree
  Future<void> logNativeViewTree() async {
    try {
      await _channel.invokeMethod('logViewTree');
    } catch (e) {
      debugPrint('DC MAUI: ERROR logging view tree - $e');
    }
  }

  // Helper method to clean props for serialization
  static Map<String, dynamic> _cleanPropsForSerialization(
      Map<String, dynamic> props) {
    final result = <String, dynamic>{};

    // Deep copy of props, removing functions which can't be serialized
    props.forEach((key, value) {
      if (value is Function) {
        // Skip functions - they'll be handled separately through event registration
      } else if (value is Map) {
        // Recursively process nested maps
        result[key] = _cleanMapForSerialization(value);
      } else if (value is List) {
        // Process lists
        result[key] = _cleanListForSerialization(value);
      } else {
        // Regular value
        result[key] = value;
      }
    });

    return result;
  }

  // Clean a map for serialization
  static Map<String, dynamic> _cleanMapForSerialization(Map value) {
    final result = <String, dynamic>{};
    value.forEach((key, val) {
      if (val is Function) {
        // Skip functions
      } else if (val is Map) {
        result[key] = _cleanMapForSerialization(val);
      } else if (val is List) {
        result[key] = _cleanListForSerialization(val);
      } else {
        result[key] = val;
      }
    });
    return result;
  }

  // Clean a list for serialization
  static List _cleanListForSerialization(List value) {
    final result = [];
    for (final item in value) {
      if (item is Function) {
        // Skip functions
      } else if (item is Map) {
        result.add(_cleanMapForSerialization(item));
      } else if (item is List) {
        result.add(_cleanListForSerialization(item));
      } else {
        result.add(item);
      }
    }
    return result;
  }
}
