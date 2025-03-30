import 'dart:ffi';
import 'dart:developer' as developer;
import 'yoga_bindings.dart';
import 'yoga_enums.dart';

/// Wrapper for a Yoga node
class YogaNode {
  /// The native Yoga node pointer
  final Pointer<Void> _node;

  /// Child nodes
  final List<YogaNode> _children = [];

  /// Reference to Yoga bindings
  final YogaBindings _yoga = YogaBindings.instance;

  /// Whether this node is valid
  bool _isValid = true;

  /// Create a new Yoga node
  YogaNode() : _node = YogaBindings.instance.nodeNew() {
    // Set default properties
    setFlexDirection(YogaFlexDirection.column);
    setJustifyContent(YogaJustifyContent.flexStart);
    setAlignItems(YogaAlign.stretch);
  }

  /// Free resources - must be called when node is no longer needed
  void dispose() {
    // First dispose all children
    final childrenToDispose = List<YogaNode>.from(_children);
    for (final child in childrenToDispose) {
      child.dispose();
    }
    _children.clear();

    if (_isValid) {
      _yoga.nodeFree(_node);
      _isValid = false;
    }
  }

  /// Add a child node
  void addChild(YogaNode child) {
    if (!_isValid || !child._isValid) {
      developer.log('Cannot add child to invalid node', name: 'YogaNode');
      return;
    }

    _children.add(child);
    _yoga.nodeInsertChild(_node, child._node, _children.indexOf(child));
  }

  /// Insert child at index
  void insertChild(YogaNode child, int index) {
    if (!_isValid || !child._isValid) {
      developer.log('Cannot insert child into invalid node', name: 'YogaNode');
      return;
    }

    if (index < 0 || index > _children.length) {
      developer.log('Invalid index for insertChild: $index', name: 'YogaNode');
      return;
    }

    _children.insert(index, child);
    _yoga.nodeInsertChild(_node, child._node, index);
  }

  /// Remove a child
  bool removeChild(YogaNode child) {
    if (!_isValid) {
      developer.log('Cannot remove child from invalid node', name: 'YogaNode');
      return false;
    }

    final index = _children.indexOf(child);
    if (index == -1) {
      return false;
    }

    _yoga.nodeRemoveChild(_node, child._node, index);
    _children.removeAt(index);
    return true;
  }

  /// Remove all children
  void removeAllChildren() {
    if (!_isValid) return;

    _yoga.nodeRemoveAllChildren(_node);
    _children.clear();
  }

  /// Get number of children
  int getChildCount() {
    return _children.length;
  }

  /// Get child at index
  YogaNode? getChild(int index) {
    if (index < 0 || index >= _children.length) {
      return null;
    }
    return _children[index];
  }

  /// Calculate layout
  void calculateLayout(
      {required double width,
      required double height,
      YogaDirection direction = YogaDirection.ltr}) {
    if (!_isValid) {
      developer.log('Cannot calculate layout on invalid node',
          name: 'YogaNode');
      return;
    }

    _yoga.nodeCalculateLayout(_node, width, height, direction);
  }

  /// Get layout left position
  double getLayoutLeft() {
    if (!_isValid) return 0;
    return _yoga.nodeLayoutGetLeft(_node);
  }

  /// Get layout top position
  double getLayoutTop() {
    if (!_isValid) return 0;
    return _yoga.nodeLayoutGetTop(_node);
  }

  /// Get layout width
  double getLayoutWidth() {
    if (!_isValid) return 0;
    return _yoga.nodeLayoutGetWidth(_node);
  }

  /// Get layout height
  double getLayoutHeight() {
    if (!_isValid) return 0;
    return _yoga.nodeLayoutGetHeight(_node);
  }

  /// Set flex direction
  void setFlexDirection(YogaFlexDirection direction) {
    if (!_isValid) return;
    _yoga.nodeStyleSetFlexDirection(_node, direction);
  }

  /// Set justify content
  void setJustifyContent(YogaJustifyContent justify) {
    if (!_isValid) return;
    _yoga.nodeStyleSetJustifyContent(_node, justify);
  }

  /// Set align items
  void setAlignItems(YogaAlign align) {
    if (!_isValid) return;
    _yoga.nodeStyleSetAlignItems(_node, align);
  }

  /// Set align self
  void setAlignSelf(YogaAlign align) {
    if (!_isValid) return;
    _yoga.nodeStyleSetAlignSelf(_node, align);
  }

  /// Set flex wrap
  void setFlexWrap(YogaWrap wrap) {
    if (!_isValid) return;
    _yoga.nodeStyleSetFlexWrap(_node, wrap);
  }

  /// Set flex
  void setFlex(double flex) {
    if (!_isValid) return;
    _yoga.nodeStyleSetFlex(_node, flex);
  }

  /// Set flex grow
  void setFlexGrow(double grow) {
    if (!_isValid) return;
    _yoga.nodeStyleSetFlexGrow(_node, grow);
  }

  /// Set flex shrink
  void setFlexShrink(double shrink) {
    if (!_isValid) return;
    _yoga.nodeStyleSetFlexShrink(_node, shrink);
  }

  /// Set flex basis
  void setFlexBasis(double basis) {
    if (!_isValid) return;
    _yoga.nodeStyleSetFlexBasis(_node, basis);
  }

  /// Set flex basis auto
  void setFlexBasisAuto() {
    if (!_isValid) return;
    _yoga.nodeStyleSetFlexBasisAuto(_node);
  }

  /// Set width
  void setWidth(double width) {
    if (!_isValid) return;
    _yoga.nodeStyleSetWidth(_node, width);
  }

  /// Set height
  void setHeight(double height) {
    if (!_isValid) return;
    _yoga.nodeStyleSetHeight(_node, height);
  }

  /// Set width to auto
  void setWidthAuto() {
    if (!_isValid) return;
    _yoga.nodeStyleSetWidthAuto(_node);
  }

  /// Set height to auto
  void setHeightAuto() {
    if (!_isValid) return;
    _yoga.nodeStyleSetHeightAuto(_node);
  }

  /// Set min width
  void setMinWidth(double minWidth) {
    if (!_isValid) return;
    _yoga.nodeStyleSetMinWidth(_node, minWidth);
  }

  /// Set min height
  void setMinHeight(double minHeight) {
    if (!_isValid) return;
    _yoga.nodeStyleSetMinHeight(_node, minHeight);
  }

  /// Set max width
  void setMaxWidth(double maxWidth) {
    if (!_isValid) return;
    _yoga.nodeStyleSetMaxWidth(_node, maxWidth);
  }

  /// Set max height
  void setMaxHeight(double maxHeight) {
    if (!_isValid) return;
    _yoga.nodeStyleSetMaxHeight(_node, maxHeight);
  }

  /// Set margin for edge
  void setMargin(YogaEdge edge, double margin) {
    if (!_isValid) return;
    _yoga.nodeStyleSetMargin(_node, edge, margin);
  }

  /// Set padding for edge
  void setPadding(YogaEdge edge, double padding) {
    if (!_isValid) return;
    _yoga.nodeStyleSetPadding(_node, edge, padding);
  }
}
