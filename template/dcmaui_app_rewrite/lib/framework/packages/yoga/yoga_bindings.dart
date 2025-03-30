import 'dart:ffi';
import 'dart:io';
import 'yoga_enums.dart';
import 'dart:developer' as developer;

/// FFI bindings to the Yoga C API
class YogaBindings {
  /// Singleton instance
  static final YogaBindings instance = YogaBindings._();

  /// The dynamic library
  late final DynamicLibrary _yogaLib;

  // Function pointers
  late final Pointer<Void> Function() _YGNodeNew;
  late final void Function(Pointer<Void>) _YGNodeFree;
  late final void Function(Pointer<Void>, Pointer<Void>, int)
      _YGNodeInsertChild;
  late final void Function(Pointer<Void>, Pointer<Void>, int)
      _YGNodeRemoveChild;
  late final void Function(Pointer<Void>) _YGNodeRemoveAllChildren;
  late final int Function(Pointer<Void>) _YGNodeGetChildCount;
  late final Pointer<Void> Function(Pointer<Void>, int) _YGNodeGetChild;
  late final void Function(Pointer<Void>, double, double, int)
      _YGNodeCalculateLayout;
  late final double Function(Pointer<Void>) _YGNodeLayoutGetLeft;
  late final double Function(Pointer<Void>) _YGNodeLayoutGetTop;
  late final double Function(Pointer<Void>) _YGNodeLayoutGetWidth;
  late final double Function(Pointer<Void>) _YGNodeLayoutGetHeight;

  // Style setters
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetFlexDirection;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetJustifyContent;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetAlignItems;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetAlignSelf;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetFlexWrap;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetFlex;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetFlexGrow;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetFlexShrink;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetFlexBasis;
  late final void Function(Pointer<Void>) _YGNodeStyleSetFlexBasisAuto;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetWidth;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetHeight;
  late final void Function(Pointer<Void>) _YGNodeStyleSetWidthAuto;
  late final void Function(Pointer<Void>) _YGNodeStyleSetHeightAuto;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetMinWidth;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetMinHeight;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetMaxWidth;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetMaxHeight;
  late final void Function(Pointer<Void>, int, double) _YGNodeStyleSetMargin;
  late final void Function(Pointer<Void>, int, double) _YGNodeStyleSetPadding;

  // Private constructor
  YogaBindings._() {
    _initializeBindings();
  }

  bool _isInitialized = false;

  /// Initialize the bindings
  void _initializeBindings() {
    if (_isInitialized) return;

    try {
      // Load the Yoga library
      if (Platform.isIOS || Platform.isMacOS) {
        _yogaLib =
            DynamicLibrary.process(); // Yoga is linked into the main process
      } else if (Platform.isAndroid) {
        _yogaLib = DynamicLibrary.open('libyogabridge.so');
      } else {
        throw UnsupportedError('Yoga bindings not supported on this platform');
      }

      // Define function bindings
      _YGNodeNew = _yogaLib
          .lookup<NativeFunction<Pointer<Void> Function()>>('YGNodeNew')
          .asFunction();

      _YGNodeFree = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('YGNodeFree')
          .asFunction();

      _YGNodeInsertChild = _yogaLib
          .lookup<
              NativeFunction<
                  Void Function(Pointer<Void>, Pointer<Void>,
                      Int32)>>('YGNodeInsertChild')
          .asFunction();

      _YGNodeRemoveChild = _yogaLib
          .lookup<
              NativeFunction<
                  Void Function(Pointer<Void>, Pointer<Void>,
                      Int32)>>('YGNodeRemoveChild')
          .asFunction();

      _YGNodeRemoveAllChildren = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>(
              'YGNodeRemoveAllChildren')
          .asFunction();

      _YGNodeGetChildCount = _yogaLib
          .lookup<NativeFunction<Uint32 Function(Pointer<Void>)>>(
              'YGNodeGetChildCount')
          .asFunction();

      _YGNodeGetChild = _yogaLib
          .lookup<
              NativeFunction<
                  Pointer<Void> Function(
                      Pointer<Void>, Uint32)>>('YGNodeGetChild')
          .asFunction();

      _YGNodeCalculateLayout = _yogaLib
          .lookup<
              NativeFunction<
                  Void Function(Pointer<Void>, Float, Float,
                      Int32)>>('YGNodeCalculateLayout')
          .asFunction();

      _YGNodeLayoutGetLeft = _yogaLib
          .lookup<NativeFunction<Float Function(Pointer<Void>)>>(
              'YGNodeLayoutGetLeft')
          .asFunction();

      _YGNodeLayoutGetTop = _yogaLib
          .lookup<NativeFunction<Float Function(Pointer<Void>)>>(
              'YGNodeLayoutGetTop')
          .asFunction();

      _YGNodeLayoutGetWidth = _yogaLib
          .lookup<NativeFunction<Float Function(Pointer<Void>)>>(
              'YGNodeLayoutGetWidth')
          .asFunction();

      _YGNodeLayoutGetHeight = _yogaLib
          .lookup<NativeFunction<Float Function(Pointer<Void>)>>(
              'YGNodeLayoutGetHeight')
          .asFunction();

      _YGNodeStyleSetFlexDirection = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetFlexDirection')
          .asFunction();

      _YGNodeStyleSetJustifyContent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetJustifyContent')
          .asFunction();

      _YGNodeStyleSetAlignItems = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetAlignItems')
          .asFunction();

      _YGNodeStyleSetAlignSelf = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetAlignSelf')
          .asFunction();

      _YGNodeStyleSetFlexWrap = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetFlexWrap')
          .asFunction();

      _YGNodeStyleSetFlex = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetFlex')
          .asFunction();

      _YGNodeStyleSetFlexGrow = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetFlexGrow')
          .asFunction();

      _YGNodeStyleSetFlexShrink = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetFlexShrink')
          .asFunction();

      _YGNodeStyleSetFlexBasis = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetFlexBasis')
          .asFunction();

      _YGNodeStyleSetFlexBasisAuto = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>(
              'YGNodeStyleSetFlexBasisAuto')
          .asFunction();

      _YGNodeStyleSetWidth = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetWidth')
          .asFunction();

      _YGNodeStyleSetHeight = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetHeight')
          .asFunction();

      _YGNodeStyleSetWidthAuto = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>(
              'YGNodeStyleSetWidthAuto')
          .asFunction();

      _YGNodeStyleSetHeightAuto = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>(
              'YGNodeStyleSetHeightAuto')
          .asFunction();

      _YGNodeStyleSetMinWidth = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMinWidth')
          .asFunction();

      _YGNodeStyleSetMinHeight = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMinHeight')
          .asFunction();

      _YGNodeStyleSetMaxWidth = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMaxWidth')
          .asFunction();

      _YGNodeStyleSetMaxHeight = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMaxHeight')
          .asFunction();

      _YGNodeStyleSetMargin = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>(
              'YGNodeStyleSetMargin')
          .asFunction();

      _YGNodeStyleSetPadding = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>(
              'YGNodeStyleSetPadding')
          .asFunction();

      _isInitialized = true;
      developer.log('Yoga bindings initialized successfully',
          name: 'YogaBindings');
    } catch (e) {
      developer.log('Failed to initialize Yoga bindings: $e',
          name: 'YogaBindings', error: e);
      throw Exception('Failed to initialize Yoga bindings: $e');
    }
  }

  // Public API methods that wrap the function pointers

  /// Create a new Yoga node
  Pointer<Void> nodeNew() {
    return _YGNodeNew();
  }

  /// Free a Yoga node
  void nodeFree(Pointer<Void> node) {
    _YGNodeFree(node);
  }

  /// Insert a child node
  void nodeInsertChild(Pointer<Void> node, Pointer<Void> child, int index) {
    _YGNodeInsertChild(node, child, index);
  }

  /// Remove a child node
  void nodeRemoveChild(Pointer<Void> node, Pointer<Void> child, int index) {
    _YGNodeRemoveChild(node, child, index);
  }

  /// Remove all children
  void nodeRemoveAllChildren(Pointer<Void> node) {
    _YGNodeRemoveAllChildren(node);
  }

  /// Get child count
  int nodeGetChildCount(Pointer<Void> node) {
    return _YGNodeGetChildCount(node);
  }

  /// Get a child node
  Pointer<Void> nodeGetChild(Pointer<Void> node, int index) {
    return _YGNodeGetChild(node, index);
  }

  /// Calculate layout
  void nodeCalculateLayout(Pointer<Void> node, double width, double height,
      YogaDirection direction) {
    _YGNodeCalculateLayout(node, width, height, direction.index);
  }

  /// Get layout left position
  double nodeLayoutGetLeft(Pointer<Void> node) {
    return _YGNodeLayoutGetLeft(node);
  }

  /// Get layout top position
  double nodeLayoutGetTop(Pointer<Void> node) {
    return _YGNodeLayoutGetTop(node);
  }

  /// Get layout width
  double nodeLayoutGetWidth(Pointer<Void> node) {
    return _YGNodeLayoutGetWidth(node);
  }

  /// Get layout height
  double nodeLayoutGetHeight(Pointer<Void> node) {
    return _YGNodeLayoutGetHeight(node);
  }

  /// Set flex direction
  void nodeStyleSetFlexDirection(
      Pointer<Void> node, YogaFlexDirection direction) {
    _YGNodeStyleSetFlexDirection(node, direction.index);
  }

  /// Set justify content
  void nodeStyleSetJustifyContent(
      Pointer<Void> node, YogaJustifyContent justify) {
    _YGNodeStyleSetJustifyContent(node, justify.index);
  }

  /// Set align items
  void nodeStyleSetAlignItems(Pointer<Void> node, YogaAlign align) {
    _YGNodeStyleSetAlignItems(node, align.index);
  }

  /// Set align self
  void nodeStyleSetAlignSelf(Pointer<Void> node, YogaAlign align) {
    _YGNodeStyleSetAlignSelf(node, align.index);
  }

  /// Set flex wrap
  void nodeStyleSetFlexWrap(Pointer<Void> node, YogaWrap wrap) {
    _YGNodeStyleSetFlexWrap(node, wrap.index);
  }

  /// Set flex
  void nodeStyleSetFlex(Pointer<Void> node, double flex) {
    _YGNodeStyleSetFlex(node, flex);
  }

  /// Set flex grow
  void nodeStyleSetFlexGrow(Pointer<Void> node, double grow) {
    _YGNodeStyleSetFlexGrow(node, grow);
  }

  /// Set flex shrink
  void nodeStyleSetFlexShrink(Pointer<Void> node, double shrink) {
    _YGNodeStyleSetFlexShrink(node, shrink);
  }

  /// Set flex basis
  void nodeStyleSetFlexBasis(Pointer<Void> node, double basis) {
    _YGNodeStyleSetFlexBasis(node, basis);
  }

  /// Set flex basis auto
  void nodeStyleSetFlexBasisAuto(Pointer<Void> node) {
    _YGNodeStyleSetFlexBasisAuto(node);
  }

  /// Set width
  void nodeStyleSetWidth(Pointer<Void> node, double width) {
    _YGNodeStyleSetWidth(node, width);
  }

  /// Set height
  void nodeStyleSetHeight(Pointer<Void> node, double height) {
    _YGNodeStyleSetHeight(node, height);
  }

  /// Set width auto
  void nodeStyleSetWidthAuto(Pointer<Void> node) {
    _YGNodeStyleSetWidthAuto(node);
  }

  /// Set height auto
  void nodeStyleSetHeightAuto(Pointer<Void> node) {
    _YGNodeStyleSetHeightAuto(node);
  }

  /// Set min width
  void nodeStyleSetMinWidth(Pointer<Void> node, double minWidth) {
    _YGNodeStyleSetMinWidth(node, minWidth);
  }

  /// Set min height
  void nodeStyleSetMinHeight(Pointer<Void> node, double minHeight) {
    _YGNodeStyleSetMinHeight(node, minHeight);
  }

  /// Set max width
  void nodeStyleSetMaxWidth(Pointer<Void> node, double maxWidth) {
    _YGNodeStyleSetMaxWidth(node, maxWidth);
  }

  /// Set max height
  void nodeStyleSetMaxHeight(Pointer<Void> node, double maxHeight) {
    _YGNodeStyleSetMaxHeight(node, maxHeight);
  }

  /// Set margin for edge
  void nodeStyleSetMargin(Pointer<Void> node, YogaEdge edge, double margin) {
    _YGNodeStyleSetMargin(node, edge.index, margin);
  }

  /// Set padding for edge
  void nodeStyleSetPadding(Pointer<Void> node, YogaEdge edge, double padding) {
    _YGNodeStyleSetPadding(node, edge.index, padding);
  }
}
