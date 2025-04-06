import 'dart:developer' as developer;
import 'dart:ffi';
import 'package:dc_test/framework/packages/yoga/yoga_bindings.dart';
import 'package:dc_test/framework/packages/yoga/yoga_enums.dart';
import 'package:dc_test/framework/constants/layout_properties.dart';

/// Node layout information
class NodeLayout {
  final double left;
  final double top;
  final double width;
  final double height;

  NodeLayout({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

/// Shadow tree for layout calculations
class ShadowTree {
  /// Yoga bindings instance
  final YogaBindings _yogaBindings = YogaBindings.instance;

  /// Map of node IDs to their Yoga node pointers
  final Map<String, Pointer<Void>> _nodeMap = {};

  /// Map of node IDs to their parent node IDs
  final Map<String, String> _parentMap = {};

  /// Constructor
  ShadowTree();

  /// Add a node to the shadow tree
  void addNode({
    required String id,
    String? parentId,
    Map<String, dynamic>? layoutProps,
  }) {
    // Create a new Yoga node
    final node = _yogaBindings.nodeNew();
    _nodeMap[id] = node;

    if (parentId != null) {
      _parentMap[id] = parentId;

      // Add as child to parent if parent exists
      if (_nodeMap.containsKey(parentId)) {
        final parentNode = _nodeMap[parentId]!;
        final childCount = _yogaBindings.nodeGetChildCount(parentNode);
        _yogaBindings.nodeInsertChild(parentNode, node, childCount);

        developer.log(
            'Added node $id as child to $parentId (child #$childCount)',
            name: 'ShadowTree');
      } else {
        developer.log('WARNING: Parent $parentId not found for node $id',
            name: 'ShadowTree');
      }
    } else {
      developer.log('Added root node $id', name: 'ShadowTree');
    }

    // Apply layout properties
    if (layoutProps != null) {
      applyLayoutProps(node, layoutProps);
    }
  }

  /// Update a node's properties
  void updateNodeProps(String nodeId, Map<String, dynamic> props) {
    final node = _nodeMap[nodeId];
    if (node != null) {
      applyLayoutProps(node, props);
      developer.log('Updated layout props for node $nodeId',
          name: 'ShadowTree');
    } else {
      developer.log('WARNING: Node $nodeId not found for prop update',
          name: 'ShadowTree');
    }
  }

  /// Remove a node from the shadow tree
  void removeNode(String nodeId) {
    final node = _nodeMap[nodeId];
    if (node != null) {
      // If node has a parent, remove it from parent
      if (_parentMap.containsKey(nodeId)) {
        final parentId = _parentMap[nodeId]!;
        final parentNode = _nodeMap[parentId];

        if (parentNode != null) {
          // Find index of child
          int index = -1;
          final childCount = _yogaBindings.nodeGetChildCount(parentNode);

          for (int i = 0; i < childCount; i++) {
            final childNode = _yogaBindings.nodeGetChild(parentNode, i);
            if (childNode == node) {
              index = i;
              break;
            }
          }

          if (index >= 0) {
            _yogaBindings.nodeRemoveChild(parentNode, node, index);
          }
        }

        _parentMap.remove(nodeId);
      }

      // Free the node
      _yogaBindings.nodeFree(node);
      _nodeMap.remove(nodeId);

      developer.log('Removed node $nodeId from shadow tree',
          name: 'ShadowTree');
    }
  }

  /// Calculate layout for the shadow tree
  void calculateLayout({
    required double width,
    required double height,
    YogaDirection direction = YogaDirection.ltr,
  }) {
    // Find root nodes (nodes with no parent)
    final rootNodes = _nodeMap.keys
        .where((id) => !_parentMap.containsKey(id))
        .map((id) => _nodeMap[id]!)
        .toList();

    if (rootNodes.isEmpty) {
      developer.log('No root nodes found for layout calculation',
          name: 'ShadowTree');
      return;
    }

    developer.log(
        'Calculating layout for ${rootNodes.length} root nodes with dimensions: ${width}x${height}',
        name: 'ShadowTree');

    // Calculate layout for each root node
    for (final rootNode in rootNodes) {
      _yogaBindings.nodeCalculateLayout(rootNode, width, height, direction);
    }

    // Log some layout results for debugging
    for (final entry in _nodeMap.entries) {
      final nodeId = entry.key;
      final node = entry.value;

      final left = _yogaBindings.nodeLayoutGetLeft(node);
      final top = _yogaBindings.nodeLayoutGetTop(node);
      final nodeWidth = _yogaBindings.nodeLayoutGetWidth(node);
      final nodeHeight = _yogaBindings.nodeLayoutGetHeight(node);

      developer.log(
          'Layout for node $nodeId: left=$left, top=$top, width=$nodeWidth, height=$nodeHeight',
          name: 'ShadowTree');
    }
  }

  /// Get layout for a specific node
  NodeLayout? getNodeLayout(String nodeId) {
    final node = _nodeMap[nodeId];
    if (node != null) {
      return NodeLayout(
        left: _yogaBindings.nodeLayoutGetLeft(node),
        top: _yogaBindings.nodeLayoutGetTop(node),
        width: _yogaBindings.nodeLayoutGetWidth(node),
        height: _yogaBindings.nodeLayoutGetHeight(node),
      );
    }
    return null;
  }

  /// Clear the shadow tree
  void clear() {
    // Free all nodes
    for (final node in _nodeMap.values) {
      _yogaBindings.nodeFree(node);
      print ('Freed node: $node');
    }

    _nodeMap.clear();
    _parentMap.clear();
    developer.log('Shadow tree cleared', name: 'ShadowTree');
  }

  /// Apply layout properties to a node
  void applyLayoutProps(Pointer<Void> node, Map<String, dynamic> props) {
    // Apply width and height
    if (props.containsKey('width')) {
      _applyDimension(node, 'width', props['width']);
    }

    if (props.containsKey('height')) {
      _applyDimension(node, 'height', props['height']);
    }

    // Apply margins
    if (props.containsKey('margin')) {
      _applyEdgeValue(node, 'margin', props['margin'], YogaEdge.all);
    }

    if (props.containsKey('marginTop')) {
      _applyEdgeValue(node, 'marginTop', props['marginTop'], YogaEdge.top);
    }

    if (props.containsKey('marginBottom')) {
      _applyEdgeValue(
          node, 'marginBottom', props['marginBottom'], YogaEdge.bottom);
    }

    if (props.containsKey('marginLeft')) {
      _applyEdgeValue(node, 'marginLeft', props['marginLeft'], YogaEdge.left);
    }

    if (props.containsKey('marginRight')) {
      _applyEdgeValue(
          node, 'marginRight', props['marginRight'], YogaEdge.right);
    }

    // Apply paddings
    if (props.containsKey('padding')) {
      _applyEdgeValue(node, 'padding', props['padding'], YogaEdge.all);
    }

    if (props.containsKey('paddingTop')) {
      _applyEdgeValue(node, 'paddingTop', props['paddingTop'], YogaEdge.top);
    }

    if (props.containsKey('paddingBottom')) {
      _applyEdgeValue(
          node, 'paddingBottom', props['paddingBottom'], YogaEdge.bottom);
    }

    if (props.containsKey('paddingLeft')) {
      _applyEdgeValue(node, 'paddingLeft', props['paddingLeft'], YogaEdge.left);
    }

    if (props.containsKey('paddingRight')) {
      _applyEdgeValue(
          node, 'paddingRight', props['paddingRight'], YogaEdge.right);
    }

    // Apply positions
    if (props.containsKey('left')) {
      _applyEdgeValue(node, 'left', props['left'], YogaEdge.left);
    }

    if (props.containsKey('right')) {
      _applyEdgeValue(node, 'right', props['right'], YogaEdge.right);
    }

    if (props.containsKey('top')) {
      _applyEdgeValue(node, 'top', props['top'], YogaEdge.top);
    }

    if (props.containsKey('bottom')) {
      _applyEdgeValue(node, 'bottom', props['bottom'], YogaEdge.bottom);
    }

    // Apply flex properties
    if (props.containsKey('flex')) {
      final flex = props['flex'];
      if (flex is num) {
        _yogaBindings.nodeStyleSetFlex(node, flex.toDouble());
      }
    }

    if (props.containsKey('flexGrow')) {
      final flexGrow = props['flexGrow'];
      if (flexGrow is num) {
        _yogaBindings.nodeStyleSetFlexGrow(node, flexGrow.toDouble());
      }
    }

    if (props.containsKey('flexShrink')) {
      final flexShrink = props['flexShrink'];
      if (flexShrink is num) {
        _yogaBindings.nodeStyleSetFlexShrink(node, flexShrink.toDouble());
      }
    }

    if (props.containsKey('flexBasis')) {
      _applyDimension(node, 'flexBasis', props['flexBasis']);
    }

    if (props.containsKey('flexDirection')) {
      final flexDirection = props['flexDirection'];
      if (flexDirection is String) {
        YogaFlexDirection? direction;

        switch (flexDirection) {
          case 'row':
            direction = YogaFlexDirection.row;
            break;
          case 'rowReverse':
            direction = YogaFlexDirection.rowReverse;
            break;
          case 'column':
            direction = YogaFlexDirection.column;
            break;
          case 'columnReverse':
            direction = YogaFlexDirection.columnReverse;
            break;
        }

        if (direction != null) {
          _yogaBindings.nodeStyleSetFlexDirection(node, direction);
        }
      }
    }

    if (props.containsKey('justifyContent')) {
      final justifyContent = props['justifyContent'];
      if (justifyContent is String) {
        YogaJustifyContent? justify;

        switch (justifyContent) {
          case 'flexStart':
            justify = YogaJustifyContent.flexStart;
            break;
          case 'center':
            justify = YogaJustifyContent.center;
            break;
          case 'flexEnd':
            justify = YogaJustifyContent.flexEnd;
            break;
          case 'spaceBetween':
            justify = YogaJustifyContent.spaceBetween;
            break;
          case 'spaceAround':
            justify = YogaJustifyContent.spaceAround;
            break;
          case 'spaceEvenly':
            justify = YogaJustifyContent.spaceEvenly;
            break;
        }

        if (justify != null) {
          _yogaBindings.nodeStyleSetJustifyContent(node, justify);
        }
      }
    }

    if (props.containsKey('alignItems')) {
      final alignItems = props['alignItems'];
      if (alignItems is String) {
        YogaAlign? align;

        switch (alignItems) {
          case 'flexStart':
            align = YogaAlign.flexStart;
            break;
          case 'center':
            align = YogaAlign.center;
            break;
          case 'flexEnd':
            align = YogaAlign.flexEnd;
            break;
          case 'stretch':
            align = YogaAlign.stretch;
            break;
          case 'baseline':
            align = YogaAlign.baseline;
            break;
        }

        if (align != null) {
          _yogaBindings.nodeStyleSetAlignItems(node, align);
        }
      }
    }

    if (props.containsKey('position')) {
      final position = props['position'];
      if (position is String) {
        YogaPositionType? positionType;

        switch (position) {
          case 'absolute':
            positionType = YogaPositionType.absolute;
            break;
          case 'relative':
            positionType = YogaPositionType.relative;
            break;
        }

        if (positionType != null) {
          _yogaBindings.nodeStyleSetPositionType(node, positionType);
        }
      }
    }
  }

  /// Apply a dimension value (width, height, etc.)
  void _applyDimension(Pointer<Void> node, String property, dynamic value) {
    if (value == null) return;

    if (value is num) {
      // Numeric value - points
      switch (property) {
        case 'width':
          _yogaBindings.nodeStyleSetWidth(node, value.toDouble());
          break;
        case 'height':
          _yogaBindings.nodeStyleSetHeight(node, value.toDouble());
          break;
        case 'minWidth':
          _yogaBindings.nodeStyleSetMinWidth(node, value.toDouble());
          break;
        case 'minHeight':
          _yogaBindings.nodeStyleSetMinHeight(node, value.toDouble());
          break;
        case 'maxWidth':
          _yogaBindings.nodeStyleSetMaxWidth(node, value.toDouble());
          break;
        case 'maxHeight':
          _yogaBindings.nodeStyleSetMaxHeight(node, value.toDouble());
          break;
        case 'flexBasis':
          _yogaBindings.nodeStyleSetFlexBasis(node, value.toDouble());
          break;
      }
    } else if (value is String && value.endsWith('%')) {
      // Percentage value
      final percentValue =
          double.tryParse(value.substring(0, value.length - 1));
      if (percentValue != null) {
        switch (property) {
          case 'width':
            _yogaBindings.nodeStyleSetWidthPercent(node, percentValue);
            break;
          case 'height':
            _yogaBindings.nodeStyleSetHeightPercent(node, percentValue);
            break;
          case 'minWidth':
            _yogaBindings.nodeStyleSetMinWidthPercent(node, percentValue);
            break;
          case 'minHeight':
            _yogaBindings.nodeStyleSetMinHeightPercent(node, percentValue);
            break;
          case 'maxWidth':
            _yogaBindings.nodeStyleSetMaxWidthPercent(node, percentValue);
            break;
          case 'maxHeight':
            _yogaBindings.nodeStyleSetMaxHeightPercent(node, percentValue);
            break;
          case 'flexBasis':
            _yogaBindings.nodeStyleSetFlexBasisPercent(node, percentValue);
            break;
        }
      }
    } else if (value == 'auto') {
      // Auto value
      switch (property) {
        case 'width':
          _yogaBindings.nodeStyleSetWidthAuto(node);
          break;
        case 'height':
          _yogaBindings.nodeStyleSetHeightAuto(node);
          break;
        case 'flexBasis':
          _yogaBindings.nodeStyleSetFlexBasisAuto(node);
          break;
      }
    }
  }

  /// Apply an edge value (margin, padding, position)
  void _applyEdgeValue(
      Pointer<Void> node, String property, dynamic value, YogaEdge edge) {
    if (value == null) return;

    if (value is num) {
      // Numeric value - points
      switch (property) {
        case 'margin':
        case 'marginTop':
        case 'marginBottom':
        case 'marginLeft':
        case 'marginRight':
          _yogaBindings.nodeStyleSetMargin(node, edge, value.toDouble());
          break;
        case 'padding':
        case 'paddingTop':
        case 'paddingBottom':
        case 'paddingLeft':
        case 'paddingRight':
          _yogaBindings.nodeStyleSetPadding(node, edge, value.toDouble());
          break;
        case 'top':
        case 'bottom':
        case 'left':
        case 'right':
          _yogaBindings.nodeStyleSetPosition(node, edge, value.toDouble());
          break;
      }
    } else if (value is String && value.endsWith('%')) {
      // Percentage value
      final percentValue =
          double.tryParse(value.substring(0, value.length - 1));
      if (percentValue != null) {
        switch (property) {
          case 'margin':
          case 'marginTop':
          case 'marginBottom':
          case 'marginLeft':
          case 'marginRight':
            _yogaBindings.nodeStyleSetMarginPercent(node, edge, percentValue);
            break;
          case 'padding':
          case 'paddingTop':
          case 'paddingBottom':
          case 'paddingLeft':
          case 'paddingRight':
            _yogaBindings.nodeStyleSetPaddingPercent(node, edge, percentValue);
            break;
          case 'top':
          case 'bottom':
          case 'left':
          case 'right':
            _yogaBindings.nodeStyleSetPositionPercent(node, edge, percentValue);
            break;
        }
      }
    } else if (value == 'auto' &&
        (property.startsWith('margin') || property == 'margin')) {
      // Auto margin
      _yogaBindings.nodeStyleSetMarginAuto(node, edge);
    }
  }
}
