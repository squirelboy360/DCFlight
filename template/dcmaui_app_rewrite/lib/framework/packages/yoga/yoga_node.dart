import 'dart:ffi';
import 'dart:developer' as developer;
import 'yoga_bindings.dart';
import 'yoga_enums.dart';

/// A wrapper class for a Yoga node
class YogaNode {
  /// The pointer to the native Yoga node
  Pointer<Void>? _node;
  
  /// Whether this node owns the native node (responsible for freeing)
  final bool _ownsNode;
  
  /// Whether this node has been disposed
  bool _disposed = false;
  
  /// List of child nodes
  final List<YogaNode> _children = [];
  
  /// Parent node
  YogaNode? parent;
  
  /// Counter for safe operations tracking
  static int _activeOperations = 0;

  /// Create a new Yoga node
  YogaNode() 
      : _node = null,
        _ownsNode = true {
    try {
      _node = YogaBindings.instance.nodeNew();
      
      // Set default values if created successfully
      if (_node != null && !isDisposed) {
        YogaBindings.instance.nodeStyleSetFlexDirection(_node!, YogaFlexDirection.column);
        YogaBindings.instance.nodeStyleSetAlignItems(_node!, YogaAlign.stretch);
      }
    } catch (e) {
      developer.log('Error creating Yoga node: $e', name: 'YogaNode');
      _disposed = true;
    }
  }

  /// Create a yoga node from an existing pointer
  YogaNode.fromPointer(Pointer<Void> node) 
      : _node = node, 
        _ownsNode = false;

  /// Whether this node has been disposed
  bool get isDisposed => _disposed || _node == null;

  /// Begin a safe operation, returns true if operation can proceed
  bool _beginSafeOperation() {
    if (isDisposed) {
      return false;
    }
    
    _activeOperations++;
    return true;
  }
  
  /// End a safe operation
  void _endSafeOperation() {
    if (_activeOperations > 0) {
      _activeOperations--;
    }
  }
  
  /// Get the underlying Yoga node pointer safely
  Pointer<Void>? get nodePtr {
    return isDisposed ? null : _node;
  }

  /// Free the native resources
  void dispose() {
    if (_disposed || _node == null) {
      return; // Already disposed
    }
    
    _disposed = true; // Mark as disposed first to prevent further operations
    
    if (_ownsNode) {
      // Remove from parent first if needed
      if (parent != null && !parent!.isDisposed) {
        try {
          parent!._children.remove(this);
          parent = null;
        } catch (e) {
          developer.log('Error removing from parent during dispose: $e', name: 'YogaNode');
        }
      }
      
      // Free all children first
      for (final child in List<YogaNode>.from(_children)) {
        // Just remove the parent reference, don't recursively call remove
        child.parent = null;
        child.dispose();
      }
      _children.clear();
      
      // Wait for any active operations to complete
      if (_activeOperations > 0) {
        developer.log('Warning: disposing node with $_activeOperations active operations',
          name: 'YogaNode');
        // Give a small delay to allow operations to complete
        Future.delayed(Duration(milliseconds: 10), () {
          _finalizeDispose();
        });
      } else {
        _finalizeDispose();
      }
    } else {
      _node = null;
    }
  }
  
  /// Finalize the disposal of resources
  void _finalizeDispose() {
    if (_node != null) {
      try {
        final nodeToFree = _node;
        _node = null; // Clear reference first
        YogaBindings.instance.nodeFree(nodeToFree!);
      } catch (e) {
        developer.log('Error freeing Yoga node: $e', name: 'YogaNode');
      }
    }
  }

  /// Insert a child node
  void insertChild(YogaNode child, int index) {
    // Safety check with proper cleanup
    if (!_beginSafeOperation()) {
      developer.log('Cannot insert child: node is disposed', name: 'YogaNode');
      return;
    }
    
    if (child.isDisposed) {
      _endSafeOperation();
      developer.log('Cannot insert child: child node is disposed', name: 'YogaNode');
      return;
    }
    
    try {
      // Remove from previous parent if any
      if (child.parent != null && child.parent != this && !child.parent!.isDisposed) {
        child.parent!._children.remove(child);
        
        // Only update Yoga if both nodes are valid
        if (child.parent!._node != null && child._node != null) {
          // Find the index in the previous parent's children
          final oldParentChildIndex = child.parent!._children.indexOf(child);
          if (oldParentChildIndex != -1) {
            YogaBindings.instance.nodeRemoveChild(
                child.parent!._node!, child._node!, oldParentChildIndex);
          }
        }
      }
      
      // Set new parent
      child.parent = this;
      
      // Add to children list
      if (index < _children.length) {
        _children.insert(index, child);
      } else {
        _children.add(child);
        index = _children.length - 1; // Adjust index for Yoga
      }
      
      // Update native tree if both nodes are valid
      if (_node != null && child._node != null) {
        YogaBindings.instance.nodeInsertChild(_node!, child._node!, index);
        
        // Don't mark parent dirty directly - Yoga will automatically mark ancestors dirty
        // when child relationships change
      }
    } catch (e) {
      developer.log('Error inserting child in Yoga: $e', name: 'YogaNode');
    } finally {
      _endSafeOperation();
    }
  }

  /// Remove a child node
  void removeChild(YogaNode child) {
    if (!_beginSafeOperation()) {
      developer.log('Cannot remove child: node is disposed', name: 'YogaNode');
      return;
    }
    
    if (child.isDisposed) {
      _endSafeOperation();
      developer.log('Cannot remove child: child node is disposed', name: 'YogaNode');
      return;
    }
    
    try {
      final index = _children.indexOf(child);
      if (index != -1) {
        _children.removeAt(index);
        child.parent = null;
        
        if (_node != null && child._node != null) {
          YogaBindings.instance.nodeRemoveChild(_node!, child._node!, index);
          
          // Don't mark parent dirty directly - Yoga will handle this automatically
          // when child relationships change
        }
      }
    } catch (e) {
      developer.log('Error removing child in Yoga: $e', name: 'YogaNode');
    } finally {
      _endSafeOperation();
    }
  }

  /// Remove all children
  void removeAllChildren() {
    if (!_beginSafeOperation()) {
      developer.log('Cannot remove children: node is disposed', name: 'YogaNode');
      return;
    }
    
    try {
      // Create a copy of the children list to avoid modification during iteration
      final childrenToRemove = List<YogaNode>.from(_children);
      for (var child in childrenToRemove) {
        child.parent = null;
      }
      _children.clear();
      
      if (_node != null) {
        YogaBindings.instance.nodeRemoveAllChildren(_node!);
        
        // Don't mark parent dirty directly - Yoga will handle this automatically
        // when child relationships change
      }
    } catch (e) {
      developer.log('Error removing all children in Yoga: $e', name: 'YogaNode');
    } finally {
      _endSafeOperation();
    }
  }

  /// Get child count
  int get childCount => _children.length;

  /// Get a child node
  YogaNode? getChild(int index) {
    if (index < 0 || index >= _children.length) return null;
    return _children[index];
  }

  /// Mark the node as dirty
  void markDirty() {
    if (!_beginSafeOperation()) {
      return; // Silently ignore if disposed
    }
    
    try {
      if (_node != null) {
        // According to Yoga's source code, only leaf nodes with measure functions
        // should call YGNodeMarkDirty directly
        if (_children.isEmpty && YogaBindings.instance.nodeHasMeasureFunc(_node!)) {
          // Only leaf nodes with measure functions should call nodeMarkDirty directly
          YogaBindings.instance.nodeMarkDirty(_node!);
        } else {
          // For non-leaf nodes or nodes without measure functions:
          // Instead of directly marking this node dirty, propagate dirtiness up the tree
          if (parent != null && !parent!.isDisposed) {
            parent!.markDirty();
          }
        }
      }
    } catch (e) {
      developer.log('Error in markDirty: $e', name: 'YogaNode');
    } finally {
      _endSafeOperation();
    }
  }

  /// Check if the node is dirty
  bool get isDirty {
    if (isDisposed) return false;
    
    try {
      return _node != null && YogaBindings.instance.nodeIsDirty(_node!);
    } catch (e) {
      developer.log('Error checking if node is dirty: $e', name: 'YogaNode');
      return false;
    }
  }

  /// Calculate layout
  void calculateLayout(double width, double height, YogaDirection direction) {
    if (!_beginSafeOperation()) {
      developer.log('Cannot calculate layout: node is disposed', name: 'YogaNode');
      return;
    }
    
    try {
      if (_node != null) {
        YogaBindings.instance.nodeCalculateLayout(_node!, width, height, direction);
      }
    } catch (e) {
      developer.log('Error calculating layout in Yoga: $e', name: 'YogaNode');
    } finally {
      _endSafeOperation();
    }
  }

  /// Get layout left position
  double get layoutLeft => YogaBindings.instance.nodeLayoutGetLeft(_node!);

  /// Get layout top position
  double get layoutTop => YogaBindings.instance.nodeLayoutGetTop(_node!);

  /// Get layout right position
  double get layoutRight => YogaBindings.instance.nodeLayoutGetRight(_node!);

  /// Get layout bottom position
  double get layoutBottom => YogaBindings.instance.nodeLayoutGetBottom(_node!);

  /// Get layout width
  double get layoutWidth => YogaBindings.instance.nodeLayoutGetWidth(_node!);

  /// Get layout height
  double get layoutHeight => YogaBindings.instance.nodeLayoutGetHeight(_node!);

  /// Get layout direction
  YogaDirection get layoutDirection => 
      YogaBindings.instance.nodeLayoutGetDirection(_node!);

  /// Check if layout had overflow
  bool get layoutHadOverflow => 
      YogaBindings.instance.nodeLayoutGetHadOverflow(_node!);
      
  /// Set flex direction
  set flexDirection(YogaFlexDirection direction) {
    YogaBindings.instance.nodeStyleSetFlexDirection(_node!, direction);
    markDirty();
  }

  /// Set justify content
  set justifyContent(YogaJustifyContent justify) {
    YogaBindings.instance.nodeStyleSetJustifyContent(_node!, justify);
    markDirty();
  }

  /// Set align items
  set alignItems(YogaAlign align) {
    YogaBindings.instance.nodeStyleSetAlignItems(_node!, align);
    markDirty();
  }

  /// Set align self
  set alignSelf(YogaAlign align) {
    YogaBindings.instance.nodeStyleSetAlignSelf(_node!, align);
    markDirty();
  }

  /// Set align content
  set alignContent(YogaAlign align) {
    YogaBindings.instance.nodeStyleSetAlignContent(_node!, align);
    markDirty();
  }

  /// Set flex wrap
  set flexWrap(YogaWrap wrap) {
    YogaBindings.instance.nodeStyleSetFlexWrap(_node!, wrap);
    markDirty();
  }

  /// Set direction
  set direction(YogaDirection direction) {
    YogaBindings.instance.nodeStyleSetDirection(_node!, direction);
    markDirty();
  }

  /// Set display type
  set display(YogaDisplay display) {
    YogaBindings.instance.nodeStyleSetDisplay(_node!, display);
    markDirty();
  }

  /// Set overflow
  set overflow(YogaOverflow overflow) {
    YogaBindings.instance.nodeStyleSetOverflow(_node!, overflow);
    markDirty();
  }

  /// Set flex
  set flex(double flex) {
    YogaBindings.instance.nodeStyleSetFlex(_node!, flex);
    markDirty();
  }

  /// Set flex grow
  set flexGrow(double grow) {
    YogaBindings.instance.nodeStyleSetFlexGrow(_node!, grow);
    markDirty();
  }

  /// Set flex shrink
  set flexShrink(double shrink) {
    YogaBindings.instance.nodeStyleSetFlexShrink(_node!, shrink);
    markDirty();
  }

  /// Set flex basis
  void setFlexBasis(dynamic basis) {
    if (basis == null) {
      YogaBindings.instance.nodeStyleSetFlexBasisAuto(_node!);
    } else if (basis is String && basis.endsWith('%')) {
      final percent = double.tryParse(basis.substring(0, basis.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetFlexBasisPercent(_node!, percent);
    } else if (basis is num) {
      YogaBindings.instance.nodeStyleSetFlexBasis(_node!, basis.toDouble());
    }
    markDirty();
  }

  /// Set width
  void setWidth(dynamic width) {
    if (width == null) {
      YogaBindings.instance.nodeStyleSetWidthAuto(_node!);
    } else if (width is String && width.endsWith('%')) {
      final percent = double.tryParse(width.substring(0, width.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetWidthPercent(_node!, percent);
    } else if (width is num) {
      YogaBindings.instance.nodeStyleSetWidth(_node!, width.toDouble());
    }
    markDirty();
  }

  /// Set height
  void setHeight(dynamic height) {
    if (height == null) {
      YogaBindings.instance.nodeStyleSetHeightAuto(_node!);
    } else if (height is String && height.endsWith('%')) {
      final percent = double.tryParse(height.substring(0, height.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetHeightPercent(_node!, percent);
    } else if (height is num) {
      YogaBindings.instance.nodeStyleSetHeight(_node!, height.toDouble());
    }
    markDirty();
  }

  /// Set min width
  void setMinWidth(dynamic minWidth) {
    if (minWidth is String && minWidth.endsWith('%')) {
      final percent = double.tryParse(minWidth.substring(0, minWidth.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetMinWidthPercent(_node!, percent);
    } else if (minWidth is num) {
      YogaBindings.instance.nodeStyleSetMinWidth(_node!, minWidth.toDouble());
    }
    markDirty();
  }

  /// Set min height
  void setMinHeight(dynamic minHeight) {
    if (minHeight is String && minHeight.endsWith('%')) {
      final percent = double.tryParse(minHeight.substring(0, minHeight.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetMinHeightPercent(_node!, percent);
    } else if (minHeight is num) {
      YogaBindings.instance.nodeStyleSetMinHeight(_node!, minHeight.toDouble());
    }
    markDirty();
  }

  /// Set max width
  void setMaxWidth(dynamic maxWidth) {
    if (maxWidth is String && maxWidth.endsWith('%')) {
      final percent = double.tryParse(maxWidth.substring(0, maxWidth.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetMaxWidthPercent(_node!, percent);
    } else if (maxWidth is num) {
      YogaBindings.instance.nodeStyleSetMaxWidth(_node!, maxWidth.toDouble());
    }
    markDirty();
  }

  /// Set max height
  void setMaxHeight(dynamic maxHeight) {
    if (maxHeight is String && maxHeight.endsWith('%')) {
      final percent = double.tryParse(maxHeight.substring(0, maxHeight.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetMaxHeightPercent(_node!, percent);
    } else if (maxHeight is num) {
      YogaBindings.instance.nodeStyleSetMaxHeight(_node!, maxHeight.toDouble());
    }
    markDirty();
  }

  /// Set position type
  set positionType(YogaPositionType positionType) {
    YogaBindings.instance.nodeStyleSetPositionType(_node!, positionType);
    markDirty();
  }

  /// Set position for an edge
  void setPosition(YogaEdge edge, dynamic position) {
    if (position is String && position.endsWith('%')) {
      final percent = double.tryParse(position.substring(0, position.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetPositionPercent(_node!, edge, percent);
    } else if (position is num) {
      YogaBindings.instance.nodeStyleSetPosition(_node!, edge, position.toDouble());
    }
    markDirty();
  }

  /// Set margin for an edge
  void setMargin(YogaEdge edge, dynamic margin) {
    if (margin is String && margin.endsWith('%')) {
      final percent = double.tryParse(margin.substring(0, margin.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetMarginPercent(_node!, edge, percent);
    } else if (margin is num) {
      YogaBindings.instance.nodeStyleSetMargin(_node!, edge, margin.toDouble());
    } else if (margin == 'auto') {
      YogaBindings.instance.nodeStyleSetMarginAuto(_node!, edge);
    }
    markDirty();
  }

  /// Set padding for an edge
  void setPadding(YogaEdge edge, dynamic padding) {
    if (padding is String && padding.endsWith('%')) {
      final percent = double.tryParse(padding.substring(0, padding.length - 1)) ?? 0;
      YogaBindings.instance.nodeStyleSetPaddingPercent(_node!, edge, percent);
    } else if (padding is num) {
      YogaBindings.instance.nodeStyleSetPadding(_node!, edge, padding.toDouble());
    }
    markDirty();
  }

  /// Set border width for an edge
  void setBorder(YogaEdge edge, dynamic borderWidth) {
    if (borderWidth is num) {
      YogaBindings.instance.nodeStyleSetBorder(_node!, edge, borderWidth.toDouble());
    }
    markDirty();
  }
}
