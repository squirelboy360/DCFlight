import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

import 'native_bridge.dart';
import 'dart:developer' as developer;

// Define typedefs at the top level, not inside the class
typedef CalculateLayoutNative = Int8 Function(
    Float screenWidth, Float screenHeight);
typedef CalculateLayoutDart = int Function(
    double screenWidth, double screenHeight);

// NEW: Typedefs for node hierarchy sync functions
typedef SyncNodeHierarchyNative = Pointer<Utf8> Function(
    Pointer<Utf8> rootId, Pointer<Utf8> nodeTreeJson);
typedef SyncNodeHierarchyDart = Pointer<Utf8> Function(
    Pointer<Utf8> rootId, Pointer<Utf8> nodeTreeJson);

typedef GetNodeHierarchyNative = Pointer<Utf8> Function(Pointer<Utf8> nodeId);
typedef GetNodeHierarchyDart = Pointer<Utf8> Function(Pointer<Utf8> nodeId);

/// FFI-based implementation of NativeBridge for iOS/macOS
class FFINativeBridge implements NativeBridge {
  late final DynamicLibrary _nativeLib;

  // Function pointers for native UI operations (ONLY)
  late final int Function() _initialize;
  late final int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>)
      _createView;
  late final int Function(Pointer<Utf8>, Pointer<Utf8>) _updateView;
  late final int Function(Pointer<Utf8>) _deleteView;
  late final int Function(Pointer<Utf8>, Pointer<Utf8>, int) _attachView;
  late final int Function(Pointer<Utf8>, Pointer<Utf8>) _setChildren;

  // New function pointers for layout updates and text measurement
  late final Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>)
      _measureText;

  // Add batch update state
  bool _batchUpdateInProgress = false;
  final List<Map<String, dynamic>> _pendingBatchUpdates = [];

  // Event callback
  Function(String viewId, String eventType, Map<String, dynamic> eventData)?
      _eventHandler;

  // Method channels
  static const MethodChannel eventChannel = MethodChannel('com.dcmaui.events');
  static const MethodChannel layoutChannel = MethodChannel('com.dcmaui.layout');

  // Map to store callbacks for each view and event type
  final Map<String, Map<String, Function>> _eventCallbacks = {};

  // Sets up communication with native code
  FFINativeBridge() {
    // Load the native library
    if (Platform.isIOS || Platform.isMacOS) {
      _nativeLib = DynamicLibrary.process();
    } else {
      throw UnsupportedError('FFI bridge only supports iOS and macOS');
    }

    // Get function pointers for UI operations ONLY
    _initialize = _nativeLib
        .lookupFunction<Int8 Function(), int Function()>('dcmaui_initialize');

    _createView = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>),
        int Function(
            Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>)>('dcmaui_create_view');

    _updateView = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Pointer<Utf8>),
        int Function(Pointer<Utf8>, Pointer<Utf8>)>('dcmaui_update_view');

    _deleteView = _nativeLib.lookupFunction<Int8 Function(Pointer<Utf8>),
        int Function(Pointer<Utf8>)>('dcmaui_delete_view');

    _attachView = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Pointer<Utf8>, Int32),
        int Function(Pointer<Utf8>, Pointer<Utf8>, int)>('dcmaui_attach_view');

    _setChildren = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Pointer<Utf8>),
        int Function(Pointer<Utf8>, Pointer<Utf8>)>('dcmaui_set_children');

    _measureText = _nativeLib.lookupFunction<
        Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>),
        Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>,
            Pointer<Utf8>)>('dcmaui_measure_text');

    // Set up method channels for events and layout
    _setupMethodChannelEventHandling();
    _setupLayoutMethodChannel();
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

        print(
            'EVENT RECEIVED FROM NATIVE: $eventType for $viewId with data: $typedEventData');

        // Forward to the appropriate handler
        if (_eventHandler != null) {
          _eventHandler!(viewId, eventType, typedEventData);
        } else {
          print('WARNING: No event handler registered to process event');
        }
      }
      return null;
    });

    print('Method channel event handling initialized');
  }

  // Set up method channel for layout operations
  void _setupLayoutMethodChannel() {
    // Nothing to set up for incoming messages, this channel is for outbound calls
    print('Layout method channel initialized');
  }

  @override
  Future<bool> initialize() async {
    try {
      developer.log('Initializing FFI bridge', name: 'FFI');
      final result = _initialize() != 0;
      developer.log('FFI bridge initialization result: $result', name: 'FFI');
      return result;
    } catch (e) {
      developer.log('Failed to initialize FFI bridge: $e', name: 'FFI');
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
      developer.log('Creating view via FFI: $viewId, $type', name: 'FFI');

      // ADD THIS DETAILED LOGGING:
      developer.log('DETAILED PROPS BEING SENT: ${jsonEncode(props)}',
          name: 'FFI_PROPS');

      return using((arena) {
        // Preprocess props to handle special types before encoding to JSON
        final processedProps = _preprocessProps(props);

        // ADD THIS DETAILED LOGGING:
        developer.log(
            'PROCESSED PROPS BEING SENT: ${jsonEncode(processedProps)}',
            name: 'FFI_PROPS');

        final viewIdPointer = viewId.toNativeUtf8(allocator: arena);
        final typePointer = type.toNativeUtf8(allocator: arena);
        final propsJson = jsonEncode(processedProps);
        final propsPointer = propsJson.toNativeUtf8(allocator: arena);

        final result = _createView(viewIdPointer, typePointer, propsPointer);
        developer.log('FFI createView result: $result', name: 'FFI');
        return result != 0;
      });
    } catch (e) {
      developer.log('FFI createView error: $e', name: 'FFI');
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

    developer.log('FFI updateView: viewId=$viewId, props=$propPatches',
        name: 'FFI');

    // ADD THIS DETAILED LOGGING:
    developer.log(
        'DETAILED UPDATE PROPS BEING SENT: ${jsonEncode(propPatches)}',
        name: 'FFI_PROPS');

    return using((arena) {
      final viewIdPointer = viewId.toNativeUtf8(allocator: arena);

      // Process props for updates
      final processedProps = _preprocessProps(propPatches);
      final propsJson = jsonEncode(processedProps);

      // ADD THIS DETAILED LOGGING:
      developer.log(
          'PROCESSED UPDATE PROPS BEING SENT: ${jsonEncode(processedProps)}',
          name: 'FFI_PROPS');

      developer.log('FFI updateView sending JSON: $propsJson', name: 'FFI');
      final propsPointer = propsJson.toNativeUtf8(allocator: arena);

      final result = _updateView(viewIdPointer, propsPointer);
      developer.log('FFI updateView result: $result', name: 'FFI');
      return result != 0;
    });
  }

  @override
  Future<bool> deleteView(String viewId) async {
    return using((arena) {
      final viewIdPointer = viewId.toNativeUtf8(allocator: arena);
      final result = _deleteView(viewIdPointer);
      return result != 0;
    });
  }

  @override
  Future<bool> attachView(String childId, String parentId, int index) async {
    return using((arena) {
      final childIdPointer = childId.toNativeUtf8(allocator: arena);
      final parentIdPointer = parentId.toNativeUtf8(allocator: arena);

      final result = _attachView(childIdPointer, parentIdPointer, index);
      return result != 0;
    });
  }

  @override
  Future<bool> setChildren(String viewId, List<String> childrenIds) async {
    return using((arena) {
      final viewIdPointer = viewId.toNativeUtf8(allocator: arena);
      final childrenJson = jsonEncode(childrenIds);
      final childrenPointer = childrenJson.toNativeUtf8(allocator: arena);

      final result = _setChildren(viewIdPointer, childrenPointer);
      return result != 0;
    });
  }

  @override
  Future<bool> addEventListeners(String viewId, List<String> eventTypes) async {
    print('Registering for events: $viewId, $eventTypes');

    // Using method channel for events
    try {
      await eventChannel.invokeMethod('addEventListeners', {
        'viewId': viewId,
        'eventTypes': eventTypes,
      });
      print('Successfully registered events for view $viewId: $eventTypes');
      return true;
    } catch (e) {
      print('Error registering events: $e');
      return false;
    }
  }

  @override
  Future<bool> removeEventListeners(
      String viewId, List<String> eventTypes) async {
    // DIRECT METHOD CHANNEL ONLY - No FFI for events
    try {
      final result =
          await eventChannel.invokeMethod<bool>('removeEventListeners', {
        'viewId': viewId,
        'eventTypes': eventTypes,
      });

      if (result == true) {
        return true;
      } else {
        developer.log('Method channel event unregistration failed',
            name: 'FFI');
        return false;
      }
    } catch (e) {
      developer.log('Method channel event unregistration error: $e',
          name: 'FFI');
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
      // CHANGED: Use method channel instead of FFI for layout operations
      developer.log(
          '🔄 LAYOUT UPDATE VIA METHOD CHANNEL: $viewId - left=$left, top=$top, width=$width, height=$height',
          name: 'LAYOUT');

      final result =
          await layoutChannel.invokeMethod<bool>('updateViewLayout', {
        'viewId': viewId,
        'left': left,
        'top': top,
        'width': width,
        'height': height,
      });

      return result ?? false;
    } catch (e, stack) {
      developer.log('❌ Error updating view layout: $e',
          name: 'FFINativeBridge', error: e, stackTrace: stack);
      return false;
    }
  }

  @override
  Future<bool> calculateLayout(
      {required double screenWidth, required double screenHeight}) async {
    try {
      // CHANGED: Use method channel instead of FFI for layout calculations
      developer.log(
          '🔄 Calculating layout via METHOD CHANNEL: screenWidth=$screenWidth, screenHeight=$screenHeight',
          name: 'LAYOUT');

      final result = await layoutChannel.invokeMethod<bool>('calculateLayout', {
        'screenWidth': screenWidth,
        'screenHeight': screenHeight,
      });

      return result ?? false;
    } catch (e, stack) {
      developer.log('❌ Error calculating layout: $e',
          name: 'FFINativeBridge', error: e, stackTrace: stack);
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> syncNodeHierarchy({
    required String rootId,
    required String nodeTree,
  }) async {
    try {
      // CHANGED: Use method channel for hierarchy sync
      final result = await layoutChannel
          .invokeMapMethod<String, dynamic>('syncNodeHierarchy', {
        'rootId': rootId,
        'nodeTree': nodeTree,
      });

      return result ?? {'success': false, 'error': 'Invalid response'};
    } catch (e) {
      print("[METHOD_CHANNEL] Error during node hierarchy sync: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> getNodeHierarchy(
      {required String nodeId}) async {
    try {
      // CHANGED: Use method channel for hierarchy retrieval
      final result = await layoutChannel
          .invokeMapMethod<String, dynamic>('getNodeHierarchy', {
        'nodeId': nodeId,
      });

      return result ?? {'error': 'Invalid response'};
    } catch (e) {
      print("[METHOD_CHANNEL] Error getting node hierarchy: $e");
      return {'error': e.toString()};
    }
  }

  @override
  Future<Map<String, double>> measureText(
      String viewId, String text, Map<String, dynamic> textAttributes) async {
    developer.log('FFI measureText: viewId=$viewId, text=$text', name: 'FFI');

    return using((arena) {
      final viewIdPointer = viewId.toNativeUtf8(allocator: arena);
      final textPointer = text.toNativeUtf8(allocator: arena);
      final attributesJson = jsonEncode(textAttributes);
      final attributesPointer = attributesJson.toNativeUtf8(allocator: arena);

      final resultPointer =
          _measureText(viewIdPointer, textPointer, attributesPointer);

      if (resultPointer.address == 0) {
        return {'width': 0.0, 'height': 0.0};
      }

      final resultString = resultPointer.toDartString();
      final Map<String, dynamic> resultMap = jsonDecode(resultString);
      return {
        'width': resultMap['width']?.toDouble() ?? 0.0,
        'height': resultMap['height']?.toDouble() ?? 0.0
      };
    });
  }

  // Helper method to preprocess props for JSON serialization
  Map<String, dynamic> _preprocessProps(Map<String, dynamic> props) {
    final processedProps = <String, dynamic>{};

    // ADD THIS DETAILED LOGGING:
    developer.log('PREPROCESSING PROPS: ${props.keys.join(", ")}',
        name: 'FFI_PROPS');

    props.forEach((key, value) {
      if (value is Function) {
        // Handle event handlers
        if (key.startsWith('on')) {
          final eventType = key.substring(2).toLowerCase();
          processedProps['_has${key.substring(2)}Handler'] = true;
          developer.log('Found function handler for event: $eventType',
              name: 'FFI');
        }
      } else if (value is Color) {
        // Convert Color objects to hex strings with alpha
        processedProps[key] =
            '#${value.value.toRadixString(16).padLeft(8, '0')}';
        developer.log('Converting color prop $key to: ${processedProps[key]}',
            name: 'FFI_PROPS');
      } else if (value == double.infinity) {
        // Convert infinity to 100% string for percentage sizing
        processedProps[key] = '100%';
        developer.log(
            'Converting infinity prop $key to: ${processedProps[key]}',
            name: 'FFI_PROPS');
      } else if (value is String &&
          (value.endsWith('%') || value.startsWith('#'))) {
        // Pass percentage strings and color strings through directly
        processedProps[key] = value;
        developer.log('Passing through special value: $key=$value',
            name: 'FFI');
      } else if (key == 'width' ||
          key == 'height' ||
          key.startsWith('margin') ||
          key.startsWith('padding')) {
        // Make sure numeric values go through as doubles for consistent handling
        if (value is num) {
          processedProps[key] = value.toDouble();
          developer.log(
              'Converting numeric layout prop $key to double: ${processedProps[key]}',
              name: 'FFI_PROPS');
        } else {
          processedProps[key] = value;
          developer.log(
              'Layout prop $key kept as is: $value (${value.runtimeType})',
              name: 'FFI_PROPS');
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
    // Create a method channel if needed
    final methodChannel = MethodChannel('com.dcmaui.bridge');

    try {
      return await methodChannel.invokeMethod(method, arguments);
    } catch (e) {
      print('Error invoking method $method: $e');
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

    final success = await invokeMethod('commitBatchUpdate', {
      'updates': _pendingBatchUpdates,
    });

    _batchUpdateInProgress = false;
    _pendingBatchUpdates.clear();
    return success == true;
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

  // Implement the new methods for debug features
  @override
  Future<bool> setVisualDebugEnabled(bool enabled) async {
    try {
      // Use layoutChannel for debug features
      await layoutChannel
          .invokeMethod('setVisualDebugEnabled', {'enabled': enabled});
      return true;
    } catch (e) {
      print("[METHOD_CHANNEL] Error enabling visual debugging: $e");
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
    print(
        'Native event received: $eventType for $viewId with data: $eventData');
    // Find registered callback for this view and event
    if (_eventHandler != null) {
      _eventHandler!(viewId, eventType, eventData);
    } else {
      print('Warning: No event handler registered to process event');
    }
  }
}
