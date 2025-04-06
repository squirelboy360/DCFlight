import 'dart:ffi';
import 'dart:developer' as developer;
import 'yoga_bindings.dart';
import 'yoga_enums.dart';

/// A wrapper class for a Yoga node
class YogaNode {
  /// The pointer to the native Yoga node
  final Pointer<Void> _node;
  
  /// Whether this node owns the native node (responsible for freeing)
  final bool _ownsNode;
  
  /// List of child nodes
  final List<YogaNode> _children = [];
  
  /// Parent node
  YogaNode? parent;

  /// Create a new Yoga node
  YogaNode() 
      : _node = YogaBindings.instance.nodeNew(),
        _ownsNode = true {
    // Initialize with defaults
    YogaBindings.instance.nodeStyleSetFlexDirection(_node, YogaFlexDirection.column);
    YogaBindings.instance.nodeStyleSetAlignItems(_node, YogaAlign.stretch);
  }

  /// Create a yoga node from an existing pointer
  YogaNode.fromPointer(this._node) : _ownsNode = false;

  /// Free the native resources
  void dispose() {
    if (_ownsNode) {
      // Remove from parent first if needed
      if (parent != null) {
        parent!._children.remove(this);
        parent = null;
      }
      
      // Free all children first
      for (final child in _children) {
        child.parent = null;
        child.dispose();
      }
      _children.clear();
      
      // Free this node
      YogaBindings.instance.nodeFree(_node);
    }
  }

  /// Insert a child node
  void insertChild(YogaNode child, int index) {
    // Remove from previous parent if any
    if (child.parent != null && child.parent != this) {
      child.parent!._children.remove(child);
    }
    
    // Set new parent
    child.parent = this;
    
    // Add to children list
    if (index < _children.length) {
      _children.insert(index, child);
    } else {
      _children.add(child);
    }
    
    // Update native tree
    YogaBindings.instance.nodeInsertChild(_node, child._node, index);
    markDirty();
  }

  /// Remove a child node
  void removeChild(YogaNode child) {
    final index = _children.indexOf(child);
    if (index != -1) {
      _children.removeAt(index);
      child.parent = null;
      YogaBindings.instance.nodeRemoveChild(_node, child._node, index);
      markDirty();
    }
  }

  /// Remove all children
  void removeAllChildren() {
    for (var child in _children) {
      child.parent = null;
    }
    _children.clear();
    YogaBindings.instance.nodeRemoveAllChildren(_node);
    markDirty();
  }

  /// Get child count
  int get childCount => _children.length;

  /// Get a child node
  YogaNode getChild(int index) {
    return _children[index];
  }

  /// Mark the node as dirty
  void markDirty() {
    YogaBindings.instance.nodeMarkDirty(_node);
  }

  /// Check if the node is dirty
  bool get isDirty => YogaBindings.instance.nodeIsDirty(_node);

  /// Calculate layout
  void calculateLayout(double width, double height, YogaDirection direction) {
    YogaBindings.instance.nodeCalculateLayout(_node, width, height, direction);
  }

  /// Get layout left position
  double get layoutLeft => YogaBindings.instance.nodeLayoutGetLeft(_node);

  /// Get layout top position
  double get layoutTop => YogaBindings.instance.nodeLayoutGetTop(_node);

  /// Get layout right position
  double get layoutRight => YogaBindings.instance.nodeLayoutGetRight(_node);

  /// Get layout bottom position
  double get layoutBottom => YogaBindings.instance.nodeLayoutGetBottom(_node);

  /// Get layout width
  double get layoutWidth => YogaBindings.instance.nodeLayoutGetWidth(_node);

  /// Get layout height
  double get layoutHeight => YogaBindings.instance.nodeLayoutGetHeight(_node);

  /// Get layout direction
  YogaDirection get layoutDirection => 
      YogaBindings.instance.nodeLayoutGetDirection(_node);

  /// Check if layout had overflow
  bool get layoutHadOverflow => 
      YogaBindings.instance.nodeLayoutGetHadOverflow(_node);
      
  /// Set flex direction
  set flexDirection(YogaFlexDirection direction) {
    YogaBindings.instance.nodeStyleSetFlexDirection(_node, direction);
    markDirty();
  }

  /// Set justify content
  set justifyContent(YogaJustifyContent justify) {
    YogaBindings.instance.nodeStyleSetJustifyContent(_node, justify);
    markDirty();
  }

  /// Set align items
  set alignItems(YogaAlign align) {
    YogaBindings.instance.nodeStyleSetAlignItems(_node, align);
    markDirty();
  }

  /// Set align self
  set alignSelf(YogaAlign align) {
    YogaBindings.instance.nodeStyleSetAlignSelf(_node, align);
    markDirty();
  }

  /// Set align content
  set alignContent(YogaAlign align) {
    YogaBindings.instance.nodeStyleSetAlignContent(_node, align);
    markDirty();
  }

  /// Set flex wrap
  set flexWrap(YogaWrap wrap) {
    YogaBindings.instance.nodeStyleSetFlexWrap(_node, wrap);
    markDirty();
  }

  /// Set direction
  set direction(YogaDirection direction) {
    YogaBindings.instance.nodeStyleSetDirection(_node, direction);
    markDirty();
  }

  /// Set display type
  set display(YogaDisplay display) {
    YogaBindings.instance.nodeStyleSetDisplay(_node, display);
    markDirty();
  }

  /// Set overflow
  set overflow(YogaOverflow overflow) {
    YogaBindings.instance.nodeStyleSetOverflow(_node, overflow);
    markDirty();
  }

  /// Set flex
  set flex(double flex) {
    YogaBindings.instance.nodeStyleSetFlex(_node, flex);
    markDirty();
  }

  /// Set flex grow
  set flexGrow(double grow) {
    YogaBindings.instance.nodeStyleSetFlexGrow(_node, grow);
    markDirty();
  }

  /// Set flex shrink
  set flexShrink(double shrink) {
    YogaBindings.instance.nodeStyleSetFlexShrink(_node, shrink);
    markDirty();
  }

  /// Set flex basis
  void setFlexBasis(dynamic basis) {
    if (basis == null) {
      YogaBindings.instance.nodeStyleSetFlexBasisAuto(_node);
    } else if (basis is String && basis.endsWith('%')) {
      final percent = double.tryParse(basis.substring(0, basis.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetFlexBasisPercent(_node, percent);
    } else if (basis is num) {
      YogaBindings.instance.nodeStyleSetFlexBasis(_node, basis.toDouble());
    }
    markDirty();
  }

  /// Set width
  void setWidth(dynamic width) {
    if (width == null) {
      YogaBindings.instance.nodeStyleSetWidthAuto(_node);
    } else if (width is String && width.endsWith('%')) {
      final percent = double.tryParse(width.substring(0, width.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetWidthPercent(_node, percent);
    } else if (width is num) {
      YogaBindings.instance.nodeStyleSetWidth(_node, width.toDouble());
    }
    markDirty();
  }

  /// Set height
  void setHeight(dynamic height) {
    if (height == null) {
      YogaBindings.instance.nodeStyleSetHeightAuto(_node);
    } else if (height is String && height.endsWith('%')) {
      final percent = double.tryParse(height.substring(0, height.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetHeightPercent(_node, percent);
    } else if (height is num) {
      YogaBindings.instance.nodeStyleSetHeight(_node, height.toDouble());
    }
    markDirty();
  }

  /// Set min width
  void setMinWidth(dynamic minWidth) {
    if (minWidth is String && minWidth.endsWith('%')) {
      final percent = double.tryParse(minWidth.substring(0, minWidth.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetMinWidthPercent(_node, percent);
    } else if (minWidth is num) {
      YogaBindings.instance.nodeStyleSetMinWidth(_node, minWidth.toDouble());
    }
    markDirty();
  }

  /// Set min height
  void setMinHeight(dynamic minHeight) {
    if (minHeight is String && minHeight.endsWith('%')) {
      final percent = double.tryParse(minHeight.substring(0, minHeight.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetMinHeightPercent(_node, percent);
    } else if (minHeight is num) {
      YogaBindings.instance.nodeStyleSetMinHeight(_node, minHeight.toDouble());
    }
    markDirty();
  }

  /// Set max width
  void setMaxWidth(dynamic maxWidth) {
    if (maxWidth is String && maxWidth.endsWith('%')) {
      final percent = double.tryParse(maxWidth.substring(0, maxWidth.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetMaxWidthPercent(_node, percent);
    } else if (maxWidth is num) {
      YogaBindings.instance.nodeStyleSetMaxWidth(_node, maxWidth.toDouble());
    }
    markDirty();
  }

  /// Set max height
  void setMaxHeight(dynamic maxHeight) {
    if (maxHeight is String && maxHeight.endsWith('%')) {
      final percent = double.tryParse(maxHeight.substring(0, maxHeight.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetMaxHeightPercent(_node, percent);
    } else if (maxHeight is num) {
      YogaBindings.instance.nodeStyleSetMaxHeight(_node, maxHeight.toDouble());
    }
    markDirty();
  }

  /// Set position type
  set positionType(YogaPositionType positionType) {
    YogaBindings.instance.nodeStyleSetPositionType(_node, positionType);
    markDirty();
  }

  /// Set position for an edge
  void setPosition(YogaEdge edge, dynamic position) {
    if (position is String && position.endsWith('%')) {
      final percent = double.tryParse(position.substring(0, position.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetPositionPercent(_node, edge, percent);
    } else if (position is num) {
      YogaBindings.instance.nodeStyleSetPosition(_node, edge, position.toDouble());
    }
    markDirty();
  }

  /// Set margin for an edge
  void setMargin(YogaEdge edge, dynamic margin) {
    if (margin is String && margin.endsWith('%')) {
      final percent = double.tryParse(margin.substring(0, margin.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetMarginPercent(_node, edge, percent);
    } else if (margin is num) {
      YogaBindings.instance.nodeStyleSetMargin(_node, edge, margin.toDouble());
    } else if (margin == 'auto') {
      YogaBindings.instance.nodeStyleSetMarginAuto(_node, edge);
    }
    markDirty();
  }

  /// Set padding for an edge
  void setPadding(YogaEdge edge, dynamic padding) {
    if (padding is String && padding.endsWith('%')) {
      final percent = double.tryParse(padding.substring(0, padding.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetPaddingPercent(_node, edge, percent);
    } else if (padding is num) {
      YogaBindings.instance.nodeStyleSetPadding(_node, edge, padding.toDouble());
    }
    markDirty();
  }

  /// Set border width for an edge
  void setBorder(YogaEdge edge, dynamic borderWidth) {
    if (borderWidth is num) {
      YogaBindings.instance.nodeStyleSetBorder(_node, edge, borderWidth.toDouble());
    }
    markDirty();
  }
}
