import 'dart:developer' as developer;
import 'yoga_node.dart';
import 'yoga_enums.dart';

/// Result of layout calculation for a node
class LayoutResult {
  /// Left position
  final double left;

  /// Top position
  final double top;

  /// Width
  final double width;

  /// Height
  final double height;

  /// Create a new layout result
  LayoutResult({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  @override
  String toString() =>
      'LayoutResult(left: $left, top: $top, width: $width, height: $height)';
}

/// A node in the shadow tree
class ShadowNode {
  /// Unique ID for this node
  final String id;

  /// Corresponding YogaNode for layout calculations
  final YogaNode yogaNode;

  /// Child nodes
  final List<ShadowNode> children = [];

  /// Parent node
  ShadowNode? parent;

  /// Whether the node is dirty and needs layout recalculation
  bool _isDirty = true;

  /// Last calculated layout result
  LayoutResult? _lastLayout;

  /// Create a new shadow node
  ShadowNode(this.id) : yogaNode = YogaNode() {
    // When the YogaNode is marked dirty, mark this node dirty too
    markDirty();
  }

  /// Dispose of resources
  void dispose() {
    // Remove from parent first
    if (parent != null) {
      parent!.children.remove(this);
      parent = null;
    }

    // Dispose all children first
    for (final child in List<ShadowNode>.from(children)) {
      child.dispose();
    }
    children.clear();

    // Dispose yoga node
    yogaNode.dispose();
  }

  /// Add a child node
  void addChild(ShadowNode child, [int? index]) {
    // Remove from previous parent
    if (child.parent != null) {
      child.parent!.removeChild(child);
    }

    // Set new parent
    child.parent = this;

    // Add to children list
    final insertIndex = index ?? children.length;
    if (insertIndex < children.length) {
      children.insert(insertIndex, child);
    } else {
      children.add(child);
    }

    // Add to yoga node
    yogaNode.insertChild(child.yogaNode, insertIndex);

    developer.log(
        'Added node ${child.id} as child to ${id} (child #$insertIndex)',
        name: 'ShadowNode');
  }

  /// Remove a child node
  void removeChild(ShadowNode child) {
    final index = children.indexOf(child);
    if (index != -1) {
      children.removeAt(index);
      child.parent = null;
      yogaNode.removeChild(child.yogaNode);
      markDirty();

      developer.log('Removed node ${child.id} from ${id}', name: 'ShadowNode');
    }
  }

  /// Remove all children
  void removeAllChildren() {
    for (final child in List<ShadowNode>.from(children)) {
      removeChild(child);
    }
    yogaNode.removeAllChildren();
    markDirty();
  }

  /// Mark the node as dirty
  void markDirty() {
    _isDirty = true;
    yogaNode.markDirty();

    // Mark parent as dirty
    if (parent != null) {
      parent!.markDirty();
    }
  }

  /// Check if the node is dirty
  bool get isDirty => _isDirty || yogaNode.isDirty;

  /// Get the last calculated layout
  LayoutResult? get layout => _lastLayout;

  /// Calculate layout
  void calculateLayout(double? width, double? height, YogaDirection direction) {
    if (!isDirty && _lastLayout != null) {
      return; // Skip calculation if not dirty
    }

    // Calculate layout using yoga - use non-null values
    final calculationWidth = width ?? double.infinity;
    final calculationHeight = height ?? double.infinity;

    yogaNode.calculateLayout(calculationWidth, calculationHeight, direction);

    // Store the calculated layout
    _lastLayout = LayoutResult(
      left: yogaNode.layoutLeft,
      top: yogaNode.layoutTop,
      width: yogaNode.layoutWidth,
      height: yogaNode.layoutHeight,
    );

    // Mark as not dirty
    _isDirty = false;

    developer.log(
        'Layout for node $id: left=${_lastLayout!.left}, top=${_lastLayout!.top}, width=${_lastLayout!.width}, height=${_lastLayout!.height}',
        name: 'ShadowNode');
  }

  /// Apply layout properties to the yoga node
  void applyLayoutProps(Map<String, dynamic> props) {
    if (!isValid) return;

    // Width and height
    if (props.containsKey('width')) _setWidth(props['width']);
    if (props.containsKey('height')) _setHeight(props['height']);
    if (props.containsKey('minWidth')) _setMinWidth(props['minWidth']);
    if (props.containsKey('maxWidth')) _setMaxWidth(props['maxWidth']);
    if (props.containsKey('minHeight')) _setMinHeight(props['minHeight']);
    if (props.containsKey('maxHeight')) _setMaxHeight(props['maxHeight']);

    // Margin
    if (props.containsKey('margin')) _setMargin(YogaEdge.all, props['margin']);
    if (props.containsKey('marginTop')) {
      _setMargin(YogaEdge.top, props['marginTop']);
    }
    if (props.containsKey('marginRight')) {
      _setMargin(YogaEdge.right, props['marginRight']);
    }
    if (props.containsKey('marginBottom')) {
      _setMargin(YogaEdge.bottom, props['marginBottom']);
    }
    if (props.containsKey('marginLeft')) {
      _setMargin(YogaEdge.left, props['marginLeft']);
    }
    if (props.containsKey('marginHorizontal')) {
      _setMargin(YogaEdge.horizontal, props['marginHorizontal']);
    }
    if (props.containsKey('marginVertical')) {
      _setMargin(YogaEdge.vertical, props['marginVertical']);
    }

    // Padding
    if (props.containsKey('padding')) {
      _setPadding(YogaEdge.all, props['padding']);
    }
    if (props.containsKey('paddingTop')) {
      _setPadding(YogaEdge.top, props['paddingTop']);
    }
    if (props.containsKey('paddingRight')) {
      _setPadding(YogaEdge.right, props['paddingRight']);
    }
    if (props.containsKey('paddingBottom')) {
      _setPadding(YogaEdge.bottom, props['paddingBottom']);
    }
    if (props.containsKey('paddingLeft')) {
      _setPadding(YogaEdge.left, props['paddingLeft']);
    }
    if (props.containsKey('paddingHorizontal')) {
      _setPadding(YogaEdge.horizontal, props['paddingHorizontal']);
    }
    if (props.containsKey('paddingVertical')) {
      _setPadding(YogaEdge.vertical, props['paddingVertical']);
    }

    // Position
    if (props.containsKey('left')) _setPosition(YogaEdge.left, props['left']);
    if (props.containsKey('top')) _setPosition(YogaEdge.top, props['top']);
    if (props.containsKey('right')) {
      _setPosition(YogaEdge.right, props['right']);
    }
    if (props.containsKey('bottom')) {
      _setPosition(YogaEdge.bottom, props['bottom']);
    }

    // Position type
    if (props.containsKey('position')) {
      final positionType = _convertToYogaPositionType(props['position']);
      if (positionType != null) yogaNode.positionType = positionType;
    }

    // Flex properties
    if (props.containsKey('flexDirection')) {
      final flexDirection = _convertToYogaFlexDirection(props['flexDirection']);
      if (flexDirection != null) yogaNode.flexDirection = flexDirection;
    }

    if (props.containsKey('justifyContent')) {
      final justifyContent =
          _convertToYogaJustifyContent(props['justifyContent']);
      if (justifyContent != null) yogaNode.justifyContent = justifyContent;
    }

    if (props.containsKey('alignItems')) {
      final alignItems = _convertToYogaAlign(props['alignItems']);
      if (alignItems != null) yogaNode.alignItems = alignItems;
    }

    if (props.containsKey('alignSelf')) {
      final alignSelf = _convertToYogaAlign(props['alignSelf']);
      if (alignSelf != null) yogaNode.alignSelf = alignSelf;
    }

    if (props.containsKey('alignContent')) {
      final alignContent = _convertToYogaAlign(props['alignContent']);
      if (alignContent != null) yogaNode.alignContent = alignContent;
    }

    if (props.containsKey('flexWrap')) {
      final flexWrap = _convertToYogaWrap(props['flexWrap']);
      if (flexWrap != null) yogaNode.flexWrap = flexWrap;
    }

    if (props.containsKey('flex')) {
      final flexValue = props['flex'];
      if (flexValue is num) yogaNode.flex = flexValue.toDouble();
    }

    if (props.containsKey('flexGrow')) {
      final flexGrow = props['flexGrow'];
      if (flexGrow is num) yogaNode.flexGrow = flexGrow.toDouble();
    }

    if (props.containsKey('flexShrink')) {
      final flexShrink = props['flexShrink'];
      if (flexShrink is num) yogaNode.flexShrink = flexShrink.toDouble();
    }

    if (props.containsKey('flexBasis')) {
      _setFlexBasis(props['flexBasis']);
    }

    // Display and overflow
    if (props.containsKey('display')) {
      final display = _convertToYogaDisplay(props['display']);
      if (display != null) yogaNode.display = display;
    }

    if (props.containsKey('overflow')) {
      final overflow = _convertToYogaOverflow(props['overflow']);
      if (overflow != null) yogaNode.overflow = overflow;
    }

    // Direction
    if (props.containsKey('direction')) {
      final direction = _convertToYogaDirection(props['direction']);
      if (direction != null) yogaNode.direction = direction;
    }

    // Border (although visual, it affects layout)
    if (props.containsKey('borderWidth')) {
      _setBorderWidth(YogaEdge.all, props['borderWidth']);
    }

    // Mark the node as dirty after applying properties
    markDirty();
  }

  // Helper methods to convert string values to Yoga enums
  YogaPositionType? _convertToYogaPositionType(dynamic value) {
    if (value is YogaPositionType) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'relative':
          return YogaPositionType.relative;
        case 'absolute':
          return YogaPositionType.absolute;
        default:
          return null;
      }
    }
    return null;
  }

  YogaFlexDirection? _convertToYogaFlexDirection(dynamic value) {
    if (value is YogaFlexDirection) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'column':
          return YogaFlexDirection.column;
        case 'column-reverse':
        case 'columnreverse':
          return YogaFlexDirection.columnReverse;
        case 'row':
          return YogaFlexDirection.row;
        case 'row-reverse':
        case 'rowreverse':
          return YogaFlexDirection.rowReverse;
        default:
          return null;
      }
    }
    return null;
  }

  YogaJustifyContent? _convertToYogaJustifyContent(dynamic value) {
    if (value is YogaJustifyContent) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'flex-start':
        case 'flexstart':
          return YogaJustifyContent.flexStart;
        case 'center':
          return YogaJustifyContent.center;
        case 'flex-end':
        case 'flexend':
          return YogaJustifyContent.flexEnd;
        case 'space-between':
        case 'spacebetween':
          return YogaJustifyContent.spaceBetween;
        case 'space-around':
        case 'spacearound':
          return YogaJustifyContent.spaceAround;
        case 'space-evenly':
        case 'spaceevenly':
          return YogaJustifyContent.spaceEvenly;
        default:
          return null;
      }
    }
    return null;
  }

  YogaAlign? _convertToYogaAlign(dynamic value) {
    if (value is YogaAlign) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'auto':
          return YogaAlign.auto;
        case 'flex-start':
        case 'flexstart':
          return YogaAlign.flexStart;
        case 'center':
          return YogaAlign.center;
        case 'flex-end':
        case 'flexend':
          return YogaAlign.flexEnd;
        case 'stretch':
          return YogaAlign.stretch;
        case 'baseline':
          return YogaAlign.baseline;
        case 'space-between':
        case 'spacebetween':
          return YogaAlign.spaceBetween;
        case 'space-around':
        case 'spacearound':
          return YogaAlign.spaceAround;
        default:
          return null;
      }
    }
    return null;
  }

  YogaWrap? _convertToYogaWrap(dynamic value) {
    if (value is YogaWrap) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'nowrap':
        case 'no-wrap':
          return YogaWrap.nowrap;
        case 'wrap':
          return YogaWrap.wrap;
        case 'wrap-reverse':
        case 'wrapreverse':
          return YogaWrap.wrapReverse;
        default:
          return null;
      }
    }
    return null;
  }

  YogaDisplay? _convertToYogaDisplay(dynamic value) {
    if (value is YogaDisplay) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'flex':
          return YogaDisplay.flex;
        case 'none':
          return YogaDisplay.none;
        default:
          return null;
      }
    }
    return null;
  }

  YogaOverflow? _convertToYogaOverflow(dynamic value) {
    if (value is YogaOverflow) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'visible':
          return YogaOverflow.visible;
        case 'hidden':
          return YogaOverflow.hidden;
        case 'scroll':
          return YogaOverflow.scroll;
        default:
          return null;
      }
    }
    return null;
  }

  YogaDirection? _convertToYogaDirection(dynamic value) {
    if (value is YogaDirection) return value;
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'inherit':
          return YogaDirection.inherit;
        case 'ltr':
          return YogaDirection.ltr;
        case 'rtl':
          return YogaDirection.rtl;
        default:
          return null;
      }
    }
    return null;
  }

  /// Implementation of the helper methods needed for ShadowNode

  /// Whether this node is valid (not disposed)
  bool get isValid => yogaNode != null && !yogaNode.isDisposed;

  /// Set width property - handles various dimension values
  void _setWidth(dynamic width) {
    if (width == null || !isValid) return;

    if (width is String && width.endsWith('%')) {
      // Handle percentage values
      final percent = double.tryParse(width.substring(0, width.length - 1));
      if (percent != null) {
        yogaNode.setWidth(width); // Pass the original percentage string
      }
    } else if (width is num) {
      yogaNode.setWidth(width);
    } else if (width == 'auto') {
      yogaNode.setWidth(null); // In YogaNode, null means auto
    }
  }

  /// Set height property - handles various dimension values
  void _setHeight(dynamic height) {
    if (height == null || !isValid) return;

    if (height is String && height.endsWith('%')) {
      // Handle percentage values
      final percent = double.tryParse(height.substring(0, height.length - 1));
      if (percent != null) {
        yogaNode.setHeight(height); // Pass the original percentage string
      }
    } else if (height is num) {
      yogaNode.setHeight(height);
    } else if (height == 'auto') {
      yogaNode.setHeight(null); // In YogaNode, null means auto
    }
  }

  /// Set minimum width property
  void _setMinWidth(dynamic minWidth) {
    if (minWidth == null || !isValid) return;

    if (minWidth is String && minWidth.endsWith('%')) {
      // Handle percentage values
      final percent =
          double.tryParse(minWidth.substring(0, minWidth.length - 1));
      if (percent != null) {
        yogaNode.setMinWidth(minWidth); // Pass the original percentage string
      }
    } else if (minWidth is num) {
      yogaNode.setMinWidth(minWidth);
    }
  }

  /// Set maximum width property
  void _setMaxWidth(dynamic maxWidth) {
    if (maxWidth == null || !isValid) return;

    if (maxWidth is String && maxWidth.endsWith('%')) {
      // Handle percentage values
      final percent =
          double.tryParse(maxWidth.substring(0, maxWidth.length - 1));
      if (percent != null) {
        yogaNode.setMaxWidth(maxWidth); // Pass the original percentage string
      }
    } else if (maxWidth is num) {
      yogaNode.setMaxWidth(maxWidth);
    }
  }

  /// Set minimum height property
  void _setMinHeight(dynamic minHeight) {
    if (minHeight == null || !isValid) return;

    if (minHeight is String && minHeight.endsWith('%')) {
      // Handle percentage values
      final percent =
          double.tryParse(minHeight.substring(0, minHeight.length - 1));
      if (percent != null) {
        yogaNode.setMinHeight(minHeight); // Pass the original percentage string
      }
    } else if (minHeight is num) {
      yogaNode.setMinHeight(minHeight);
    }
  }

  /// Set maximum height property
  void _setMaxHeight(dynamic maxHeight) {
    if (maxHeight == null || !isValid) return;

    if (maxHeight is String && maxHeight.endsWith('%')) {
      // Handle percentage values
      final percent =
          double.tryParse(maxHeight.substring(0, maxHeight.length - 1));
      if (percent != null) {
        yogaNode.setMaxHeight(maxHeight); // Pass the original percentage string
      }
    } else if (maxHeight is num) {
      yogaNode.setMaxHeight(maxHeight);
    }
  }

  /// Set margin for a specific edge
  void _setMargin(YogaEdge edge, dynamic margin) {
    if (margin == null || !isValid) return;

    if (margin is String && margin.endsWith('%')) {
      // Handle percentage values
      final percent = double.tryParse(margin.substring(0, margin.length - 1));
      if (percent != null) {
        yogaNode.setMargin(edge, margin); // Pass the original percentage string
      }
    } else if (margin is num) {
      yogaNode.setMargin(edge, margin);
    } else if (margin == 'auto') {
      yogaNode.setMargin(edge, 'auto');
    }
  }

  /// Set padding for a specific edge
  void _setPadding(YogaEdge edge, dynamic padding) {
    if (padding == null || !isValid) return;

    if (padding is String && padding.endsWith('%')) {
      // Handle percentage values
      final percent = double.tryParse(padding.substring(0, padding.length - 1));
      if (percent != null) {
        yogaNode.setPadding(
            edge, padding); // Pass the original percentage string
      }
    } else if (padding is num) {
      yogaNode.setPadding(edge, padding);
    }
  }

  /// Set position for a specific edge
  void _setPosition(YogaEdge edge, dynamic position) {
    if (position == null || !isValid) return;

    if (position is String && position.endsWith('%')) {
      // Handle percentage values
      final percent =
          double.tryParse(position.substring(0, position.length - 1));
      if (percent != null) {
        yogaNode.setPosition(
            edge, position); // Pass the original percentage string
      }
    } else if (position is num) {
      yogaNode.setPosition(edge, position);
    }
  }

  /// Set border width for a specific edge
  void _setBorderWidth(YogaEdge edge, dynamic borderWidth) {
    if (borderWidth == null || !isValid) return;

    if (borderWidth is num) {
      yogaNode.setBorder(edge, borderWidth);
    }
  }

  /// Set flex basis property
  void _setFlexBasis(dynamic flexBasis) {
    if (flexBasis == null || !isValid) return;

    if (flexBasis is String && flexBasis.endsWith('%')) {
      // Handle percentage values
      final percent =
          double.tryParse(flexBasis.substring(0, flexBasis.length - 1));
      if (percent != null) {
        yogaNode.setFlexBasis(flexBasis); // Pass the original percentage string
      }
    } else if (flexBasis is num) {
      yogaNode.setFlexBasis(flexBasis);
    } else if (flexBasis == 'auto') {
      yogaNode.setFlexBasis('auto');
    }
  }

  /// Get edge name for property names
  String _getEdgeName(YogaEdge edge) {
    switch (edge) {
      case YogaEdge.top:
        return 'Top';
      case YogaEdge.right:
        return 'Right';
      case YogaEdge.bottom:
        return 'Bottom';
      case YogaEdge.left:
        return 'Left';
      case YogaEdge.all:
        return '';
      case YogaEdge.horizontal:
        return 'Horizontal';
      case YogaEdge.vertical:
        return 'Vertical';
      case YogaEdge.start:
        return 'Start';
      case YogaEdge.end:
        return 'End';
    }
  }
}
