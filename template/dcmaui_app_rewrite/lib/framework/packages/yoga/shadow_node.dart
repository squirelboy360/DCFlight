import 'dart:developer' as developer;
import 'yoga_node.dart';
import 'yoga_enums.dart';

/// Shadow node representing a UI element in the layout tree
class ShadowNode {
  /// Unique identifier for this node
  final String id;

  /// The Yoga node for layout calculations
  final YogaNode yogaNode;

  /// Parent node in the shadow tree
  ShadowNode? parent;

  /// Child nodes
  final List<ShadowNode> children = [];

  /// Layout props applied to this node
  Map<String, dynamic> layoutProps = {};

  /// Whether this node is dirty and needs layout recalculation
  bool isDirty = true;

  /// Whether this node is marked for deletion
  bool isDeleted = false;

  /// Create a shadow node with a unique ID and yoga node
  ShadowNode(this.id) : yogaNode = YogaNode() {
    // Set default properties
    yogaNode.setFlexDirection(YogaFlexDirection.column);
    yogaNode.setJustifyContent(YogaJustifyContent.flexStart);
    yogaNode.setAlignItems(YogaAlign.stretch);
  }

  /// Add a child node
  void addChild(ShadowNode child) {
    children.add(child);
    yogaNode.addChild(child.yogaNode);
    child.parent = this;
    markDirty();
  }

  /// Insert a child node at a specific index
  void insertChild(ShadowNode child, int index) {
    if (index < 0 || index > children.length) {
      developer.log('Invalid index for insertChild: $index',
          name: 'ShadowNode');
      return;
    }

    children.insert(index, child);
    yogaNode.insertChild(child.yogaNode, index);
    child.parent = this;
    markDirty();
  }

  /// Remove a child node
  bool removeChild(ShadowNode child) {
    final index = children.indexOf(child);
    if (index == -1) return false;

    yogaNode.removeChild(child.yogaNode);
    children.removeAt(index);
    child.parent = null;
    markDirty();
    return true;
  }

  /// Remove a child node by index
  bool removeChildAtIndex(int index) {
    if (index < 0 || index >= children.length) {
      return false;
    }

    final child = children[index];
    yogaNode.removeChild(child.yogaNode);
    children.removeAt(index);
    child.parent = null;
    markDirty();
    return true;
  }

  /// Remove all children
  void removeAllChildren() {
    for (final child in List.from(children)) {
      child.parent = null;
    }
    children.clear();
    yogaNode.removeAllChildren();
    markDirty();
  }

  /// Apply layout properties to the yoga node
  void applyLayoutProps(Map<String, dynamic> props) {
    layoutProps = Map<String, dynamic>.from(props);
    _applyPropsToYogaNode();
    markDirty();
  }

  /// Update specific properties
  void updateLayoutProps(Map<String, dynamic> props) {
    layoutProps.addAll(props);
    _applyPropsToYogaNode();
    markDirty();
  }

  /// Apply the stored layout props to the yoga node
  void _applyPropsToYogaNode() {
    final props = layoutProps;

    // Width and height (with percentage handling)
    if (props.containsKey('width')) {
      _applyDimension(props['width'], (val) => yogaNode.setWidth(val),
          (val) => yogaNode.setWidthPercent(val));
    }

    if (props.containsKey('height')) {
      _applyDimension(props['height'], (val) => yogaNode.setHeight(val),
          (val) => yogaNode.setHeightPercent(val));
    }

    // Min width/height
    if (props.containsKey('minWidth')) {
      final minWidth = _parseNumberProp(props['minWidth']);
      if (minWidth != null) {
        yogaNode.setMinWidth(minWidth);
      }
    }

    if (props.containsKey('minHeight')) {
      final minHeight = _parseNumberProp(props['minHeight']);
      if (minHeight != null) {
        yogaNode.setMinHeight(minHeight);
      }
    }

    // Max width/height
    if (props.containsKey('maxWidth')) {
      final maxWidth = _parseNumberProp(props['maxWidth']);
      if (maxWidth != null) {
        yogaNode.setMaxWidth(maxWidth);
      }
    }

    if (props.containsKey('maxHeight')) {
      final maxHeight = _parseNumberProp(props['maxHeight']);
      if (maxHeight != null) {
        yogaNode.setMaxHeight(maxHeight);
      }
    }

    // Flex properties
    if (props.containsKey('flex')) {
      final flex = _parseNumberProp(props['flex']);
      if (flex != null) {
        yogaNode.setFlex(flex);
      }
    }

    if (props.containsKey('flexGrow')) {
      final flexGrow = _parseNumberProp(props['flexGrow']);
      if (flexGrow != null) {
        yogaNode.setFlexGrow(flexGrow);
      }
    }

    if (props.containsKey('flexShrink')) {
      final flexShrink = _parseNumberProp(props['flexShrink']);
      if (flexShrink != null) {
        yogaNode.setFlexShrink(flexShrink);
      }
    }

    if (props.containsKey('flexBasis')) {
      final val = props['flexBasis'];
      if (val == 'auto') {
        yogaNode.setFlexBasisAuto();
      } else {
        final flexBasis = _parseNumberProp(val);
        if (flexBasis != null) {
          yogaNode.setFlexBasis(flexBasis);
        }
      }
    }

    // Flex direction
    if (props.containsKey('flexDirection')) {
      final direction = props['flexDirection'];
      switch (direction) {
        case 'row':
          yogaNode.setFlexDirection(YogaFlexDirection.row);
          break;
        case 'rowReverse':
          yogaNode.setFlexDirection(YogaFlexDirection.rowReverse);
          break;
        case 'column':
          yogaNode.setFlexDirection(YogaFlexDirection.column);
          break;
        case 'columnReverse':
          yogaNode.setFlexDirection(YogaFlexDirection.columnReverse);
          break;
      }
    }

    // Justify content
    if (props.containsKey('justifyContent')) {
      final justifyContent = props['justifyContent'];
      switch (justifyContent) {
        case 'flexStart':
          yogaNode.setJustifyContent(YogaJustifyContent.flexStart);
          break;
        case 'center':
          yogaNode.setJustifyContent(YogaJustifyContent.center);
          break;
        case 'flexEnd':
          yogaNode.setJustifyContent(YogaJustifyContent.flexEnd);
          break;
        case 'spaceBetween':
          yogaNode.setJustifyContent(YogaJustifyContent.spaceBetween);
          break;
        case 'spaceAround':
          yogaNode.setJustifyContent(YogaJustifyContent.spaceAround);
          break;
        case 'spaceEvenly':
          yogaNode.setJustifyContent(YogaJustifyContent.spaceEvenly);
          break;
      }
    }

    // Align items
    if (props.containsKey('alignItems')) {
      final alignItems = props['alignItems'];
      switch (alignItems) {
        case 'flexStart':
          yogaNode.setAlignItems(YogaAlign.flexStart);
          break;
        case 'center':
          yogaNode.setAlignItems(YogaAlign.center);
          break;
        case 'flexEnd':
          yogaNode.setAlignItems(YogaAlign.flexEnd);
          break;
        case 'stretch':
          yogaNode.setAlignItems(YogaAlign.stretch);
          break;
        case 'baseline':
          yogaNode.setAlignItems(YogaAlign.baseline);
          break;
      }
    }

    // Align self
    if (props.containsKey('alignSelf')) {
      final alignSelf = props['alignSelf'];
      switch (alignSelf) {
        case 'auto':
          yogaNode.setAlignSelf(YogaAlign.auto);
          break;
        case 'flexStart':
          yogaNode.setAlignSelf(YogaAlign.flexStart);
          break;
        case 'center':
          yogaNode.setAlignSelf(YogaAlign.center);
          break;
        case 'flexEnd':
          yogaNode.setAlignSelf(YogaAlign.flexEnd);
          break;
        case 'stretch':
          yogaNode.setAlignSelf(YogaAlign.stretch);
          break;
        case 'baseline':
          yogaNode.setAlignSelf(YogaAlign.baseline);
          break;
      }
    }

    // Flex wrap
    if (props.containsKey('flexWrap')) {
      final flexWrap = props['flexWrap'];
      switch (flexWrap) {
        case 'nowrap':
          yogaNode.setFlexWrap(YogaWrap.nowrap);
          break;
        case 'wrap':
          yogaNode.setFlexWrap(YogaWrap.wrap);
          break;
        case 'wrapReverse':
          yogaNode.setFlexWrap(YogaWrap.wrapReverse);
          break;
      }
    }

    // Position type
    if (props.containsKey('position')) {
      final position = props['position'];
      if (position == 'absolute') {
        yogaNode.setPositionType(YogaPositionType.absolute);
      } else {
        yogaNode.setPositionType(YogaPositionType.relative);
      }
    }

    // Apply margins
    _applyEdgeValues(
        props,
        'margin',
        (edge, value) => yogaNode.setMargin(edge, value),
        (edge, percent) => yogaNode.setMarginPercent(edge, percent));

    // Apply paddings
    _applyEdgeValues(
        props,
        'padding',
        (edge, value) => yogaNode.setPadding(edge, value),
        (edge, percent) => yogaNode.setPaddingPercent(edge, percent));
  }

  /// Parse a number/percentage value
  dynamic _parseNumberProp(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    } else if (value is String && value.endsWith('%')) {
      try {
        return double.parse(value.substring(0, value.length - 1));
      } catch (e) {
        return null;
      }
    } else if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Apply a dimension value that could be a number or percentage
  void _applyDimension(dynamic value, void Function(double) setAbsolute,
      void Function(double) setPercent) {
    if (value == null) return;

    if (value is num) {
      setAbsolute(value.toDouble());
    } else if (value is String && value == 'auto') {
      // Handle auto - leave it to the yoga node to figure out
    } else if (value is String && value.endsWith('%')) {
      final percentValue = _parseNumberProp(value);
      if (percentValue != null) {
        setPercent(percentValue);
      }
    } else if (value is String) {
      final pointValue = _parseNumberProp(value);
      if (pointValue != null) {
        setAbsolute(pointValue);
      }
    }
  }

  /// Apply edge values (margin/padding) with support for percentages
  void _applyEdgeValues(
      Map<String, dynamic> props,
      String baseProp,
      void Function(YogaEdge, double) setter,
      void Function(YogaEdge, double) percentSetter) {
    // Handle all-sides value
    if (props.containsKey(baseProp)) {
      _applyEdgeValue(props[baseProp], YogaEdge.all, setter, percentSetter);
    }

    // Handle individual sides
    final sides = {
      'Top': YogaEdge.top,
      'Right': YogaEdge.right,
      'Bottom': YogaEdge.bottom,
      'Left': YogaEdge.left,
    };

    sides.forEach((suffix, edge) {
      final prop = '$baseProp$suffix';
      if (props.containsKey(prop)) {
        _applyEdgeValue(props[prop], edge, setter, percentSetter);
      }
    });

    // Handle horizontal (left + right)
    final propH = '${baseProp}Horizontal';
    if (props.containsKey(propH)) {
      _applyEdgeValue(props[propH], YogaEdge.horizontal, setter, percentSetter);
    }

    // Handle vertical (top + bottom)
    final propV = '${baseProp}Vertical';
    if (props.containsKey(propV)) {
      _applyEdgeValue(props[propV], YogaEdge.vertical, setter, percentSetter);
    }
  }

  /// Apply a single edge value (could be percentage)
  void _applyEdgeValue(
      dynamic value,
      YogaEdge edge,
      void Function(YogaEdge, double) setter,
      void Function(YogaEdge, double) percentSetter) {
    if (value is num) {
      setter(edge, value.toDouble());
    } else if (value is String && value.endsWith('%')) {
      final percentValue = _parseNumberProp(value);
      if (percentValue != null) {
        percentSetter(edge, percentValue);
      }
    } else if (value is String) {
      final pointValue = _parseNumberProp(value);
      if (pointValue != null) {
        setter(edge, pointValue);
      }
    }
  }

  /// Mark this node as dirty, needing layout recalculation
  void markDirty() {
    isDirty = true;

    // Mark parent as dirty to propagate changes up the tree
    if (parent != null) {
      parent!.markDirty();
    }
  }

  /// Clean up this node and its children
  void dispose() {
    // Clean up children first
    for (final child in List.from(children)) {
      child.dispose();
    }

    // Clean up this node
    yogaNode.dispose();
    isDeleted = true;
  }
}
