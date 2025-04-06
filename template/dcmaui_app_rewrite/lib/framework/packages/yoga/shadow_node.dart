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

  /// Set layout properties from a map
  void applyLayoutProps(Map<String, dynamic>? props) {
    if (props == null) return;

    // Handle dimensions
    if (props.containsKey('width')) {
      yogaNode.setWidth(props['width']);
    }

    if (props.containsKey('height')) {
      yogaNode.setHeight(props['height']);
    }

    if (props.containsKey('minWidth')) {
      yogaNode.setMinWidth(props['minWidth']);
    }

    if (props.containsKey('maxWidth')) {
      yogaNode.setMaxWidth(props['maxWidth']);
    }

    if (props.containsKey('minHeight')) {
      yogaNode.setMinHeight(props['minHeight']);
    }

    if (props.containsKey('maxHeight')) {
      yogaNode.setMaxHeight(props['maxHeight']);
    }

    // Handle flex properties
    if (props.containsKey('flex')) {
      yogaNode.flex = props['flex'] as double;
    }

    if (props.containsKey('flexGrow')) {
      yogaNode.flexGrow = props['flexGrow'] as double;
    }

    if (props.containsKey('flexShrink')) {
      yogaNode.flexShrink = props['flexShrink'] as double;
    }

    if (props.containsKey('flexBasis')) {
      yogaNode.setFlexBasis(props['flexBasis']);
    }

    if (props.containsKey('flexDirection')) {
      yogaNode.flexDirection = props['flexDirection'] as YogaFlexDirection;
    }

    if (props.containsKey('flexWrap')) {
      yogaNode.flexWrap = props['flexWrap'] as YogaWrap;
    }

    // Handle alignment
    if (props.containsKey('justifyContent')) {
      yogaNode.justifyContent = props['justifyContent'] as YogaJustifyContent;
    }

    if (props.containsKey('alignItems')) {
      yogaNode.alignItems = props['alignItems'] as YogaAlign;
    }

    if (props.containsKey('alignSelf')) {
      yogaNode.alignSelf = props['alignSelf'] as YogaAlign;
    }

    if (props.containsKey('alignContent')) {
      yogaNode.alignContent = props['alignContent'] as YogaAlign;
    }

    // Handle position
    if (props.containsKey('position')) {
      yogaNode.positionType = props['position'] as YogaPositionType;
    }

    // Handle edges (position, margin, padding, border)
    for (final edge in YogaEdge.values) {
      final edgeName = _getEdgeName(edge);

      // Position
      final positionProp = props['$edgeName'];
      if (positionProp != null) {
        yogaNode.setPosition(edge, positionProp);
      }

      // Margin
      final marginProp = props['margin$edgeName'];
      if (marginProp != null) {
        yogaNode.setMargin(edge, marginProp);
      }

      // Padding
      final paddingProp = props['padding$edgeName'];
      if (paddingProp != null) {
        yogaNode.setPadding(edge, paddingProp);
      }

      // Border
      final borderProp = props['border${edgeName}Width'];
      if (borderProp != null) {
        yogaNode.setBorder(edge, borderProp);
      }
    }

    // Handle special cases for all edges
    if (props.containsKey('margin')) {
      final margin = props['margin'];
      for (final edge in YogaEdge.values) {
        yogaNode.setMargin(edge, margin);
      }
    }

    if (props.containsKey('padding')) {
      final padding = props['padding'];
      for (final edge in YogaEdge.values) {
        yogaNode.setPadding(edge, padding);
      }
    }

    if (props.containsKey('borderWidth')) {
      final borderWidth = props['borderWidth'];
      for (final edge in YogaEdge.values) {
        yogaNode.setBorder(edge, borderWidth);
      }
    }

    // Handle display and overflow
    if (props.containsKey('display')) {
      yogaNode.display = props['display'] as YogaDisplay;
    }

    if (props.containsKey('overflow')) {
      yogaNode.overflow = props['overflow'] as YogaOverflow;
    }

    // Mark as dirty after applying props
    markDirty();

    developer.log('Updated layout props for node $id', name: 'ShadowNode');
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
