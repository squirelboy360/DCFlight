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

  // Core node functions
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
  late final void Function(Pointer<Void>) _YGNodeReset;
  late final void Function(Pointer<Void>) _YGNodeMarkDirty;
  late final bool Function(Pointer<Void>) _YGNodeIsDirty;
  late final bool Function(Pointer<Void>) _YGNodeHasMeasureFunc;

  // Layout getters
  late final double Function(Pointer<Void>) _YGNodeLayoutGetLeft;
  late final double Function(Pointer<Void>) _YGNodeLayoutGetTop;
  late final double Function(Pointer<Void>) _YGNodeLayoutGetRight;
  late final double Function(Pointer<Void>) _YGNodeLayoutGetBottom;
  late final double Function(Pointer<Void>) _YGNodeLayoutGetWidth;
  late final double Function(Pointer<Void>) _YGNodeLayoutGetHeight;
  late final int Function(Pointer<Void>) _YGNodeLayoutGetDirection;
  late final bool Function(Pointer<Void>) _YGNodeLayoutGetHadOverflow;

  // Basic style setters
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetFlexDirection;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetJustifyContent;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetAlignItems;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetAlignSelf;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetAlignContent;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetFlexWrap;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetDisplay;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetOverflow;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetDirection;

  // Flex properties
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetFlex;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetFlexGrow;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetFlexShrink;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetFlexBasis;
  late final void Function(Pointer<Void>, double)
      _YGNodeStyleSetFlexBasisPercent;
  late final void Function(Pointer<Void>) _YGNodeStyleSetFlexBasisAuto;

  // Dimensions
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetWidth;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetHeight;
  late final void Function(Pointer<Void>) _YGNodeStyleSetWidthAuto;
  late final void Function(Pointer<Void>) _YGNodeStyleSetHeightAuto;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetMinWidth;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetMinHeight;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetMaxWidth;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetMaxHeight;

  // Percentage dimensions
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetWidthPercent;
  late final void Function(Pointer<Void>, double) _YGNodeStyleSetHeightPercent;
  late final void Function(Pointer<Void>, double)
      _YGNodeStyleSetMinWidthPercent;
  late final void Function(Pointer<Void>, double)
      _YGNodeStyleSetMinHeightPercent;
  late final void Function(Pointer<Void>, double)
      _YGNodeStyleSetMaxWidthPercent;
  late final void Function(Pointer<Void>, double)
      _YGNodeStyleSetMaxHeightPercent;

  // Position & edges
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetPositionType;
  late final void Function(Pointer<Void>, int, double) _YGNodeStyleSetPosition;
  late final void Function(Pointer<Void>, int, double)
      _YGNodeStyleSetPositionPercent;
  late final void Function(Pointer<Void>, int, double) _YGNodeStyleSetMargin;
  late final void Function(Pointer<Void>, int, double)
      _YGNodeStyleSetMarginPercent;
  late final void Function(Pointer<Void>, int) _YGNodeStyleSetMarginAuto;
  late final void Function(Pointer<Void>, int, double) _YGNodeStyleSetPadding;
  late final void Function(Pointer<Void>, int, double)
      _YGNodeStyleSetPaddingPercent;
  late final void Function(Pointer<Void>, int, double) _YGNodeStyleSetBorder;

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

      // Core node functions
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

      // Add node reset and dirty checking
      _YGNodeReset = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>('YGNodeReset')
          .asFunction();
      _YGNodeMarkDirty = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>(
              'YGNodeMarkDirty')
          .asFunction();
      _YGNodeIsDirty = _yogaLib
          .lookup<NativeFunction<Bool Function(Pointer<Void>)>>('YGNodeIsDirty')
          .asFunction();

      // Measure function check
      _YGNodeHasMeasureFunc = _yogaLib
          .lookup<NativeFunction<Bool Function(Pointer<Void>)>>(
              'YGNodeHasMeasureFunc')
          .asFunction();

      // Layout getters
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

      // Add additional layout getters for completeness
      _YGNodeLayoutGetRight = _yogaLib
          .lookup<NativeFunction<Float Function(Pointer<Void>)>>(
              'YGNodeLayoutGetRight')
          .asFunction();
      _YGNodeLayoutGetBottom = _yogaLib
          .lookup<NativeFunction<Float Function(Pointer<Void>)>>(
              'YGNodeLayoutGetBottom')
          .asFunction();
      _YGNodeLayoutGetDirection = _yogaLib
          .lookup<NativeFunction<Int32 Function(Pointer<Void>)>>(
              'YGNodeLayoutGetDirection')
          .asFunction();
      _YGNodeLayoutGetHadOverflow = _yogaLib
          .lookup<NativeFunction<Bool Function(Pointer<Void>)>>(
              'YGNodeLayoutGetHadOverflow')
          .asFunction();

      // Style setters - flexbox properties
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
      _YGNodeStyleSetAlignContent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetAlignContent')
          .asFunction();
      _YGNodeStyleSetFlexWrap = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetFlexWrap')
          .asFunction();
      _YGNodeStyleSetDirection = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetDirection')
          .asFunction();
      _YGNodeStyleSetDisplay = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetDisplay')
          .asFunction();
      _YGNodeStyleSetOverflow = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetOverflow')
          .asFunction();

      // Flex properties
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
      _YGNodeStyleSetFlexBasisPercent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetFlexBasisPercent')
          .asFunction();

      // Dimensions
      _YGNodeStyleSetWidth = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetWidth')
          .asFunction();
      _YGNodeStyleSetWidthPercent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetWidthPercent')
          .asFunction();
      _YGNodeStyleSetWidthAuto = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>(
              'YGNodeStyleSetWidthAuto')
          .asFunction();
      _YGNodeStyleSetHeight = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetHeight')
          .asFunction();
      _YGNodeStyleSetHeightPercent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetHeightPercent')
          .asFunction();
      _YGNodeStyleSetHeightAuto = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>)>>(
              'YGNodeStyleSetHeightAuto')
          .asFunction();
      _YGNodeStyleSetMinWidth = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMinWidth')
          .asFunction();
      _YGNodeStyleSetMinWidthPercent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMinWidthPercent')
          .asFunction();
      _YGNodeStyleSetMinHeight = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMinHeight')
          .asFunction();
      _YGNodeStyleSetMinHeightPercent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMinHeightPercent')
          .asFunction();
      _YGNodeStyleSetMaxWidth = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMaxWidth')
          .asFunction();
      _YGNodeStyleSetMaxWidthPercent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMaxWidthPercent')
          .asFunction();
      _YGNodeStyleSetMaxHeight = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMaxHeight')
          .asFunction();
      _YGNodeStyleSetMaxHeightPercent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Float)>>(
              'YGNodeStyleSetMaxHeightPercent')
          .asFunction();

      // Position, margin and padding
      _YGNodeStyleSetPositionType = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetPositionType')
          .asFunction();
      _YGNodeStyleSetPosition = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>(
              'YGNodeStyleSetPosition')
          .asFunction();
      _YGNodeStyleSetPositionPercent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>(
              'YGNodeStyleSetPositionPercent')
          .asFunction();
      _YGNodeStyleSetMargin = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>(
              'YGNodeStyleSetMargin')
          .asFunction();
      _YGNodeStyleSetMarginPercent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>(
              'YGNodeStyleSetMarginPercent')
          .asFunction();
      _YGNodeStyleSetMarginAuto = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32)>>(
              'YGNodeStyleSetMarginAuto')
          .asFunction();
      _YGNodeStyleSetPadding = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>(
              'YGNodeStyleSetPadding')
          .asFunction();
      _YGNodeStyleSetPaddingPercent = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>(
              'YGNodeStyleSetPaddingPercent')
          .asFunction();
      _YGNodeStyleSetBorder = _yogaLib
          .lookup<NativeFunction<Void Function(Pointer<Void>, Int32, Float)>>(
              'YGNodeStyleSetBorder')
          .asFunction();

      _isInitialized = true;
      developer.log('✅ Yoga bindings initialized with all required functions',
          name: 'YogaBindings');
    } catch (e, stack) {
      developer.log('❌ Failed to initialize Yoga bindings: $e',
          name: 'YogaBindings', error: e, stackTrace: stack);
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

  /// Reset a node to default values
  void nodeReset(Pointer<Void> node) {
    _YGNodeReset(node);
  }

  /// Mark a node as dirty
  void nodeMarkDirty(Pointer<Void> node) {
    _YGNodeMarkDirty(node);
  }

  /// Check if a node is dirty
  bool nodeIsDirty(Pointer<Void> node) {
    return _YGNodeIsDirty(node);
  }

  /// Check if node has a measure function
  bool nodeHasMeasureFunc(Pointer<Void> node) {
    return _YGNodeHasMeasureFunc(node);
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
    developer.log(
        '🔄 Calculating Yoga layout: $width x $height, direction: $direction',
        name: 'YogaBindings');
    _YGNodeCalculateLayout(node, width, height, direction.index);
    developer.log('✅ Yoga layout calculation complete', name: 'YogaBindings');
  }

  /// Get layout left position
  double nodeLayoutGetLeft(Pointer<Void> node) {
    return _YGNodeLayoutGetLeft(node);
  }

  /// Get layout top position
  double nodeLayoutGetTop(Pointer<Void> node) {
    return _YGNodeLayoutGetTop(node);
  }

  /// Get layout right position
  double nodeLayoutGetRight(Pointer<Void> node) {
    return _YGNodeLayoutGetRight(node);
  }

  /// Get layout bottom position
  double nodeLayoutGetBottom(Pointer<Void> node) {
    return _YGNodeLayoutGetBottom(node);
  }

  /// Get layout width
  double nodeLayoutGetWidth(Pointer<Void> node) {
    return _YGNodeLayoutGetWidth(node);
  }

  /// Get layout height
  double nodeLayoutGetHeight(Pointer<Void> node) {
    return _YGNodeLayoutGetHeight(node);
  }

  /// Get layout direction
  YogaDirection nodeLayoutGetDirection(Pointer<Void> node) {
    return YogaDirection.values[_YGNodeLayoutGetDirection(node)];
  }

  /// Check if layout had overflow
  bool nodeLayoutGetHadOverflow(Pointer<Void> node) {
    return _YGNodeLayoutGetHadOverflow(node);
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

  /// Set align content
  void nodeStyleSetAlignContent(Pointer<Void> node, YogaAlign align) {
    _YGNodeStyleSetAlignContent(node, align.index);
  }

  /// Set flex wrap
  void nodeStyleSetFlexWrap(Pointer<Void> node, YogaWrap wrap) {
    _YGNodeStyleSetFlexWrap(node, wrap.index);
  }

  /// Set direction
  void nodeStyleSetDirection(Pointer<Void> node, YogaDirection direction) {
    _YGNodeStyleSetDirection(node, direction.index);
  }

  /// Set display type
  void nodeStyleSetDisplay(Pointer<Void> node, YogaDisplay display) {
    _YGNodeStyleSetDisplay(node, display.index);
  }

  /// Set overflow
  void nodeStyleSetOverflow(Pointer<Void> node, YogaOverflow overflow) {
    _YGNodeStyleSetOverflow(node, overflow.index);
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

  /// Set flex basis as a percentage
  void nodeStyleSetFlexBasisPercent(Pointer<Void> node, double percent) {
    _YGNodeStyleSetFlexBasisPercent(node, percent);
  }

  /// Set flex basis auto
  void nodeStyleSetFlexBasisAuto(Pointer<Void> node) {
    _YGNodeStyleSetFlexBasisAuto(node);
  }

  /// Set width
  void nodeStyleSetWidth(Pointer<Void> node, double width) {
    _YGNodeStyleSetWidth(node, width);
  }

  /// Set width as a percentage
  void nodeStyleSetWidthPercent(Pointer<Void> node, double percent) {
    _YGNodeStyleSetWidthPercent(node, percent);
  }

  /// Set width auto
  void nodeStyleSetWidthAuto(Pointer<Void> node) {
    _YGNodeStyleSetWidthAuto(node);
  }

  /// Set height
  void nodeStyleSetHeight(Pointer<Void> node, double height) {
    _YGNodeStyleSetHeight(node, height);
  }

  /// Set height as a percentage
  void nodeStyleSetHeightPercent(Pointer<Void> node, double percent) {
    _YGNodeStyleSetHeightPercent(node, percent);
  }

  /// Set height auto
  void nodeStyleSetHeightAuto(Pointer<Void> node) {
    _YGNodeStyleSetHeightAuto(node);
  }

  /// Set min width
  void nodeStyleSetMinWidth(Pointer<Void> node, double minWidth) {
    _YGNodeStyleSetMinWidth(node, minWidth);
  }

  /// Set min width as a percentage
  void nodeStyleSetMinWidthPercent(Pointer<Void> node, double percent) {
    _YGNodeStyleSetMinWidthPercent(node, percent);
  }

  /// Set min height
  void nodeStyleSetMinHeight(Pointer<Void> node, double minHeight) {
    _YGNodeStyleSetMinHeight(node, minHeight);
  }

  /// Set min height as a percentage
  void nodeStyleSetMinHeightPercent(Pointer<Void> node, double percent) {
    _YGNodeStyleSetMinHeightPercent(node, percent);
  }

  /// Set max width
  void nodeStyleSetMaxWidth(Pointer<Void> node, double maxWidth) {
    _YGNodeStyleSetMaxWidth(node, maxWidth);
  }

  /// Set max width as a percentage
  void nodeStyleSetMaxWidthPercent(Pointer<Void> node, double percent) {
    _YGNodeStyleSetMaxWidthPercent(node, percent);
  }

  /// Set max height
  void nodeStyleSetMaxHeight(Pointer<Void> node, double maxHeight) {
    _YGNodeStyleSetMaxHeight(node, maxHeight);
  }

  /// Set max height as a percentage
  void nodeStyleSetMaxHeightPercent(Pointer<Void> node, double percent) {
    _YGNodeStyleSetMaxHeightPercent(node, percent);
  }

  /// Set position type
  void nodeStyleSetPositionType(
      Pointer<Void> node, YogaPositionType positionType) {
    _YGNodeStyleSetPositionType(node, positionType.index);
  }

  /// Set position for an edge
  void nodeStyleSetPosition(
      Pointer<Void> node, YogaEdge edge, double position) {
    _YGNodeStyleSetPosition(node, edge.index, position);
  }

  /// Set position for an edge as a percentage
  void nodeStyleSetPositionPercent(
      Pointer<Void> node, YogaEdge edge, double percent) {
    _YGNodeStyleSetPositionPercent(node, edge.index, percent);
  }

  /// Set margin for an edge
  void nodeStyleSetMargin(Pointer<Void> node, YogaEdge edge, double margin) {
    _YGNodeStyleSetMargin(node, edge.index, margin);
  }

  /// Set margin for an edge as a percentage
  void nodeStyleSetMarginPercent(
      Pointer<Void> node, YogaEdge edge, double percent) {
    _YGNodeStyleSetMarginPercent(node, edge.index, percent);
  }

  /// Set margin auto for an edge
  void nodeStyleSetMarginAuto(Pointer<Void> node, YogaEdge edge) {
    _YGNodeStyleSetMarginAuto(node, edge.index);
  }

  /// Set padding for an edge
  void nodeStyleSetPadding(Pointer<Void> node, YogaEdge edge, double padding) {
    _YGNodeStyleSetPadding(node, edge.index, padding);
  }

  /// Set padding for an edge as a percentage
  void nodeStyleSetPaddingPercent(
      Pointer<Void> node, YogaEdge edge, double percent) {
    _YGNodeStyleSetPaddingPercent(node, edge.index, percent);
  }

  /// Set border width for an edge
  void nodeStyleSetBorder(
      Pointer<Void> node, YogaEdge edge, double borderWidth) {
    _YGNodeStyleSetBorder(node, edge.index, borderWidth);
  }
}
