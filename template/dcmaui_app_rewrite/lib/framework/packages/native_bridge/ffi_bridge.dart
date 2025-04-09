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
  late final int Function(Pointer<Utf8>, double, double, double, double)
      _updateViewLayout;
  late final Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>)
      _measureText;

  // Add the calculate layout function pointer
  late final CalculateLayoutDart _calculateLayoutNative;

  // Add the node hierarchy functions
  late final SyncNodeHierarchyDart _syncNodeHierarchy;
  late final GetNodeHierarchyDart _getNodeHierarchy;

  // Add batch update state
  bool _batchUpdateInProgress = false;
  final List<Map<String, dynamic>> _pendingBatchUpdates = [];

  // Event callback
  Function(String viewId, String eventType, Map<String, dynamic> eventData)?
      _eventHandler;

  // Method channel for events - PUBLIC so it can be accessed directly
  static const MethodChannel eventChannel = MethodChannel('com.dcmaui.events');

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

    // Get function pointers for new layout methods
    _updateViewLayout = _nativeLib.lookupFunction<
        Int8 Function(Pointer<Utf8>, Float, Float, Float, Float),
        int Function(Pointer<Utf8>, double, double, double,
            double)>('dcmaui_update_view_layout');

    _measureText = _nativeLib.lookupFunction<
        Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>),
        Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>,
            Pointer<Utf8>)>('dcmaui_measure_text');

    // Initialize the calculate layout function
    _calculateLayoutNative =
        _nativeLib.lookupFunction<CalculateLayoutNative, CalculateLayoutDart>(
            'dcmaui_calculate_layout');

    // Initialize the node hierarchy sync functions
    _syncNodeHierarchy = _nativeLib.lookupFunction<SyncNodeHierarchyNative,
        SyncNodeHierarchyDart>('dcmaui_sync_node_hierarchy');

    _getNodeHierarchy =
        _nativeLib.lookupFunction<GetNodeHierarchyNative, GetNodeHierarchyDart>(
            'dcmaui_get_node_hierarchy');

    // Set up method channel for handling events
    _setupMethodChannelEventHandling();
  }

  // Set up method channel for event handling
  void _setupMethodChannelEventHandling() {
    eventChannel.setMethodCallHandler((call) async {
      if (call.method == 'onEvent') {
        final Map<dynamic, dynamic> args = call.arguments;
        final String viewId = args['viewId'];
        final String eventType = args['eventType'];
        final Map<String, dynamic> eventData =
            Map<String, dynamic>.from(args['eventData']);

        developer.log(
            'Event received in Dart through method channel: $viewId - $eventType - Data: $eventData',
            name: 'FFI');

        if (_eventHandler != null) {
          _eventHandler!(viewId, eventType, eventData);
        }
      }
      return null;
    });

    developer.log('Method channel event handling initialized', name: 'FFI');
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
    developer.log('Registering for events: $viewId, $eventTypes', name: 'FFI');

    // DIRECT METHOD CHANNEL ONLY - No FFI for events
    try {
      final result = await eventChannel.invokeMethod<bool>('registerEvents', {
        'viewId': viewId,
        'eventTypes': eventTypes,
      });

      if (result == true) {
        developer.log('Event registration succeeded via method channel',
            name: 'FFI');
        return true;
      } else {
        developer.log('Method channel event registration failed', name: 'FFI');
        return false;
      }
    } catch (e) {
      developer.log('Method channel event registration error: $e', name: 'FFI');
      return false;
    }
  }

  @override
  Future<bool> removeEventListeners(
      String viewId, List<String> eventTypes) async {
    // DIRECT METHOD CHANNEL ONLY - No FFI for events
    try {
      final result = await eventChannel.invokeMethod<bool>('unregisterEvents', {
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
      // ADD THIS DETAILED LOGGING:
      developer.log(
          '🔄 LAYOUT UPDATE: $viewId - EXACT VALUES: left=$left, top=$top, width=$width, height=$height',
          name: 'FFI_LAYOUT');

      final viewIdPtr = viewId.toNativeUtf8();
      final result =
          _updateViewLayout(viewIdPtr.cast(), left, top, width, height);
      calloc.free(viewIdPtr);

      developer.log(
          '${result != 0 ? '✅' : '❌'} FFI layout result: $result for view: $viewId',
          name: 'FFI_LAYOUT');
      return result != 0;
    } catch (e, stack) {
      developer.log('❌ FFI: Error updating view layout: $e',
          name: 'FFINativeBridge', error: e, stackTrace: stack);
      return false;
    }
  }

  @override
  Future<bool> calculateLayout(
      {required double screenWidth, required double screenHeight}) async {
    try {
      developer.log(
          '🔄 Calculating layout via FFI: screenWidth=$screenWidth, screenHeight=$screenHeight',
          name: 'FFI_LAYOUT');

      final result = _calculateLayoutNative(screenWidth, screenHeight);

      developer.log(
          '${result != 0 ? '✅' : '❌'} FFI calculate layout result: $result',
          name: 'FFI_LAYOUT');
      return result != 0;
    } catch (e, stack) {
      developer.log('❌ FFI: Error calculating layout: $e',
          name: 'FFINativeBridge', error: e, stackTrace: stack);
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> syncNodeHierarchy(
      {required String rootId, required Map<String, dynamic> nodeTree}) async {
    try {
      developer.log('🔄 Syncing node hierarchy', name: 'FFI_SYNC');

      return using((arena) {
        final rootIdPtr = rootId.toNativeUtf8(allocator: arena);
        final nodeTreeJson = jsonEncode(nodeTree);
        final nodeTreeJsonPtr = nodeTreeJson.toNativeUtf8(allocator: arena);

        final resultPtr = _syncNodeHierarchy(rootIdPtr, nodeTreeJsonPtr);

        if (resultPtr.address == 0) {
          return {'success': false, 'error': 'Failed to sync node hierarchy'};
        }

        final resultString = resultPtr.toDartString();
        calloc.free(resultPtr);

        try {
          final Map<String, dynamic> result = jsonDecode(resultString);
          developer.log('✅ Node hierarchy sync complete: ${result['success']}',
              name: 'FFI_SYNC');
          return result;
        } catch (e) {
          developer.log('❌ Failed to parse sync result: $e', name: 'FFI_SYNC');
          return {'success': false, 'error': 'Failed to parse sync result: $e'};
        }
      });
    } catch (e, stack) {
      developer.log('❌ Exception in syncNodeHierarchy: $e',
          name: 'FFI_SYNC', error: e, stackTrace: stack);
      return {'success': false, 'error': e.toString()};
    }
  }

  @override
  Future<Map<String, dynamic>> getNodeHierarchy(
      {required String nodeId}) async {
    try {
      developer.log('🔍 Getting node hierarchy for: $nodeId', name: 'FFI_SYNC');

      return using((arena) {
        final nodeIdPtr = nodeId.toNativeUtf8(allocator: arena);

        final resultPtr = _getNodeHierarchy(nodeIdPtr);

        if (resultPtr.address == 0) {
          return {'success': false, 'error': 'Failed to get node hierarchy'};
        }

        final resultString = resultPtr.toDartString();
        calloc.free(resultPtr);

        try {
          final Map<String, dynamic> result = jsonDecode(resultString);
          return {'success': true, 'hierarchy': result};
        } catch (e) {
          developer.log('❌ Failed to parse hierarchy result: $e',
              name: 'FFI_SYNC');
          return {
            'success': false,
            'error': 'Failed to parse hierarchy result: $e'
          };
        }
      });
    } catch (e, stack) {
      developer.log('❌ Exception in getNodeHierarchy: $e',
          name: 'FFI_SYNC', error: e, stackTrace: stack);
      return {'success': false, 'error': e.toString()};
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
}
