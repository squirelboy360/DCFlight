import 'package:collection/collection.dart';
import 'dart:developer' as developer;
import '../../constants/layout_properties.dart';
import 'yoga_node.dart';
import 'yoga_enums.dart';

/// Layout manager that performs flexbox layout in Dart using Yoga
class DartLayoutManager {
  /// Singleton instance
  static final DartLayoutManager instance = DartLayoutManager._();

  /// Node mapping - maps view IDs to Yoga nodes
  final Map<String, YogaNode> _nodeMapping = {};

  /// Layout caching - stores previously calculated layouts
  final Map<String, _LayoutResult> _layoutCache = {};

  /// Track which nodes are dirty and need recalculation
  final Set<String> _dirtyNodes = {};

  /// Cache of props to avoid recalculating layout unnecessarily
  final Map<String, Map<String, dynamic>> _propsCache = {};

  /// Track parent-child relationships
  final Map<String, String> _nodeParents = {};

  /// Track child-parent relationships
  final Map<String, List<String>> _nodeChildren = {};

  /// Private constructor
  DartLayoutManager._();

  /// Create a Yoga node for a view
  YogaNode createNodeForView(String viewId) {
    // Check if already exists
    if (_nodeMapping.containsKey(viewId)) {
      return _nodeMapping[viewId]!;
    }

    // Create new node
    final node = YogaNode();
    _nodeMapping[viewId] = node;
    _dirtyNodes.add(viewId);

    developer.log('Created Yoga node for view: $viewId', name: 'DartLayout');
    return node;
  }

  /// Apply flexbox properties to a node - exact React Native approach
  void applyFlexboxProps(String viewId, Map<String, dynamic> props) {
    final node = _nodeMapping[viewId];
    if (node == null) {
      developer.log('No Yoga node found for view: $viewId', name: 'DartLayout');
      return;
    }

    // Check if props changed to avoid unnecessary updates
    if (_propsCache.containsKey(viewId)) {
      final oldProps = _propsCache[viewId]!;
      bool hasChanges = !const DeepCollectionEquality().equals(props, oldProps);
      if (!hasChanges) return; // No changes, skip update
    }

    // Cache the props
    _propsCache[viewId] = Map<String, dynamic>.from(props);
    _markNodeDirty(viewId);

    // Apply flex direction
    if (props.containsKey(LayoutProperties.flexDirection)) {
      final direction = props[LayoutProperties.flexDirection] as String;
      switch (direction) {
        case 'row':
          node.setFlexDirection(YogaFlexDirection.row);
          break;
        case 'rowReverse':
          node.setFlexDirection(YogaFlexDirection.rowReverse);
          break;
        case 'column':
          node.setFlexDirection(YogaFlexDirection.column);
          break;
        case 'columnReverse':
          node.setFlexDirection(YogaFlexDirection.columnReverse);
          break;
      }
    }

    // Justify content
    if (props.containsKey(LayoutProperties.justifyContent)) {
      final justifyContent = props[LayoutProperties.justifyContent] as String;
      switch (justifyContent) {
        case 'flexStart':
          node.setJustifyContent(YogaJustifyContent.flexStart);
          break;
        case 'center':
          node.setJustifyContent(YogaJustifyContent.center);
          break;
        case 'flexEnd':
          node.setJustifyContent(YogaJustifyContent.flexEnd);
          break;
        case 'spaceBetween':
          node.setJustifyContent(YogaJustifyContent.spaceBetween);
          break;
        case 'spaceAround':
          node.setJustifyContent(YogaJustifyContent.spaceAround);
          break;
        case 'spaceEvenly':
          node.setJustifyContent(YogaJustifyContent.spaceEvenly);
          break;
      }
    }

    // Align items
    if (props.containsKey(LayoutProperties.alignItems)) {
      final alignItems = props[LayoutProperties.alignItems] as String;
      switch (alignItems) {
        case 'flexStart':
          node.setAlignItems(YogaAlign.flexStart);
          break;
        case 'center':
          node.setAlignItems(YogaAlign.center);
          break;
        case 'flexEnd':
          node.setAlignItems(YogaAlign.flexEnd);
          break;
        case 'stretch':
          node.setAlignItems(YogaAlign.stretch);
          break;
        case 'baseline':
          node.setAlignItems(YogaAlign.baseline);
          break;
      }
    }

    // Align self
    if (props.containsKey(LayoutProperties.alignSelf)) {
      final alignSelf = props[LayoutProperties.alignSelf] as String;
      switch (alignSelf) {
        case 'auto':
          node.setAlignSelf(YogaAlign.auto);
          break;
        case 'flexStart':
          node.setAlignSelf(YogaAlign.flexStart);
          break;
        case 'center':
          node.setAlignSelf(YogaAlign.center);
          break;
        case 'flexEnd':
          node.setAlignSelf(YogaAlign.flexEnd);
          break;
        case 'stretch':
          node.setAlignSelf(YogaAlign.stretch);
          break;
        case 'baseline':
          node.setAlignSelf(YogaAlign.baseline);
          break;
      }
    }

    // Flex wrap
    if (props.containsKey(LayoutProperties.flexWrap)) {
      final flexWrap = props[LayoutProperties.flexWrap] as String;
      switch (flexWrap) {
        case 'nowrap':
          node.setFlexWrap(YogaWrap.nowrap);
          break;
        case 'wrap':
          node.setFlexWrap(YogaWrap.wrap);
          break;
        case 'wrapReverse':
          node.setFlexWrap(YogaWrap.wrapReverse);
          break;
      }
    }

    // Flex properties
    if (props.containsKey(LayoutProperties.flex)) {
      final flex = _parseNumberProp(props[LayoutProperties.flex]);
      if (flex != null) {
        node.setFlex(flex);
      }
    }

    if (props.containsKey(LayoutProperties.flexGrow)) {
      final flexGrow = _parseNumberProp(props[LayoutProperties.flexGrow]);
      if (flexGrow != null) {
        node.setFlexGrow(flexGrow);
      }
    }

    if (props.containsKey(LayoutProperties.flexShrink)) {
      final flexShrink = _parseNumberProp(props[LayoutProperties.flexShrink]);
      if (flexShrink != null) {
        node.setFlexShrink(flexShrink);
      }
    }

    if (props.containsKey(LayoutProperties.flexBasis)) {
      if (props[LayoutProperties.flexBasis] is String &&
          props[LayoutProperties.flexBasis] == 'auto') {
        node.setFlexBasisAuto();
      } else {
        final flexBasis = _parseNumberProp(props[LayoutProperties.flexBasis]);
        if (flexBasis != null) {
          node.setFlexBasis(flexBasis);
        }
      }
    }

    // Width and height - with proper percentage handling
    if (props.containsKey(LayoutProperties.width)) {
      final width = _parseNumberProp(props[LayoutProperties.width]);
      _applyDimensionProp(node, width, true);
    }

    if (props.containsKey(LayoutProperties.height)) {
      final height = _parseNumberProp(props[LayoutProperties.height]);
      _applyDimensionProp(node, height, false);
    }

    // Min/max dimensions
    if (props.containsKey(LayoutProperties.minWidth)) {
      final minWidth = _parseNumberProp(props[LayoutProperties.minWidth]);
      if (minWidth != null) {
        node.setMinWidth(minWidth);
      }
    }

    if (props.containsKey(LayoutProperties.minHeight)) {
      final minHeight = _parseNumberProp(props[LayoutProperties.minHeight]);
      if (minHeight != null) {
        node.setMinHeight(minHeight);
      }
    }

    if (props.containsKey(LayoutProperties.maxWidth)) {
      final maxWidth = _parseNumberProp(props[LayoutProperties.maxWidth]);
      if (maxWidth != null) {
        node.setMaxWidth(maxWidth);
      }
    }

    if (props.containsKey(LayoutProperties.maxHeight)) {
      final maxHeight = _parseNumberProp(props[LayoutProperties.maxHeight]);
      if (maxHeight != null) {
        node.setMaxHeight(maxHeight);
      }
    }

    // Margins
    if (props.containsKey(LayoutProperties.margin)) {
      final margin = _parseNumberProp(props[LayoutProperties.margin]);
      if (margin != null) {
        node.setMargin(YogaEdge.all, margin);
      }
    }

    if (props.containsKey(LayoutProperties.marginTop)) {
      final marginTop = _parseNumberProp(props[LayoutProperties.marginTop]);
      if (marginTop != null) {
        node.setMargin(YogaEdge.top, marginTop);
      }
    }

    if (props.containsKey(LayoutProperties.marginRight)) {
      final marginRight = _parseNumberProp(props[LayoutProperties.marginRight]);
      if (marginRight != null) {
        node.setMargin(YogaEdge.right, marginRight);
      }
    }

    if (props.containsKey(LayoutProperties.marginBottom)) {
      final marginBottom =
          _parseNumberProp(props[LayoutProperties.marginBottom]);
      if (marginBottom != null) {
        node.setMargin(YogaEdge.bottom, marginBottom);
      }
    }

    if (props.containsKey(LayoutProperties.marginLeft)) {
      final marginLeft = _parseNumberProp(props[LayoutProperties.marginLeft]);
      if (marginLeft != null) {
        node.setMargin(YogaEdge.left, marginLeft);
      }
    }

    // Padding
    if (props.containsKey(LayoutProperties.padding)) {
      final padding = _parseNumberProp(props[LayoutProperties.padding]);
      if (padding != null) {
        node.setPadding(YogaEdge.all, padding);
      }
    }

    if (props.containsKey(LayoutProperties.paddingTop)) {
      final paddingTop = _parseNumberProp(props[LayoutProperties.paddingTop]);
      if (paddingTop != null) {
        node.setPadding(YogaEdge.top, paddingTop);
      }
    }

    if (props.containsKey(LayoutProperties.paddingRight)) {
      final paddingRight =
          _parseNumberProp(props[LayoutProperties.paddingRight]);
      if (paddingRight != null) {
        node.setPadding(YogaEdge.right, paddingRight);
      }
    }

    if (props.containsKey(LayoutProperties.paddingBottom)) {
      final paddingBottom =
          _parseNumberProp(props[LayoutProperties.paddingBottom]);
      if (paddingBottom != null) {
        node.setPadding(YogaEdge.bottom, paddingBottom);
      }
    }

    if (props.containsKey(LayoutProperties.paddingLeft)) {
      final paddingLeft = _parseNumberProp(props[LayoutProperties.paddingLeft]);
      if (paddingLeft != null) {
        node.setPadding(YogaEdge.left, paddingLeft);
      }
    }
  }

  /// Parse number property that could be a number or a percent string
  dynamic _parseNumberProp(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    } else if (value is String && value.endsWith('%')) {
      try {
        // For percentage values, keep the raw percentage without converting to a fractional value
        // This is crucial for correct rendering on different screen sizes
        final percentValue = double.parse(value.substring(0, value.length - 1));
        developer.log('Processing percentage value: $value as $percentValue%',
            name: 'DartLayout');

        // Simply return the raw percentage value - Yoga expects percentages as-is
        return {
          'isPercent': true,
          'value':
              percentValue // Don't divide by 100 - Yoga expects the actual percentage
        };
      } catch (e) {
        developer.log('Failed to parse percentage: $value, error: $e',
            name: 'DartLayout');
        return null;
      }
    } else if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        developer.log('Failed to parse numeric string: $value, error: $e',
            name: 'DartLayout');
        return null;
      }
    }
    return null;
  }

  /// Apply width/height properties handling percentages properly
  void _applyDimensionProp(YogaNode node, dynamic value, bool isWidth) {
    if (value == null) return;

    if (value is Map && value['isPercent'] == true) {
      // Handle percentage value - pass the raw percentage to Yoga
      final percentValue = value['value'] as double;
      if (isWidth) {
        developer.log('Setting width as percentage: $percentValue%',
            name: 'DartLayout');
        node.setWidthPercent(percentValue);
      } else {
        developer.log('Setting height as percentage: $percentValue%',
            name: 'DartLayout');
        node.setHeightPercent(percentValue);
      }
    } else if (value is String && value == 'auto') {
      // Handle auto value
      if (isWidth) {
        node.setWidthAuto();
      } else {
        node.setHeightAuto();
      }
    } else if (value is double) {
      // Handle point value
      if (isWidth) {
        node.setWidth(value);
      } else {
        node.setHeight(value);
      }
    }
  }

  /// Mark a node as dirty, requiring layout recalculation
  void _markNodeDirty(String viewId) {
    _dirtyNodes.add(viewId);
    _layoutCache.remove(viewId);

    // Also mark parent as dirty to propagate changes up the tree
    final parentId = _findParentId(viewId);
    if (parentId != null) {
      _markNodeDirty(parentId);
    }
  }

  /// Find parent ID of a node
  String? _findParentId(String viewId) {
    return _nodeParents[viewId];
  }

  /// Register a parent-child relationship
  void registerParentChild(String parentId, String childId) {
    _nodeParents[childId] = parentId;

    // Add to child list
    _nodeChildren.putIfAbsent(parentId, () => []).add(childId);

    // Mark parent as dirty since it has a new child
    _markNodeDirty(parentId);
  }

  /// Remove a parent-child relationship
  void unregisterParentChild(String parentId, String childId) {
    _nodeParents.remove(childId);

    // Remove from child list
    if (_nodeChildren.containsKey(parentId)) {
      _nodeChildren[parentId]?.remove(childId);
    }

    // Mark parent as dirty since it lost a child
    _markNodeDirty(parentId);
  }

  /// Calculate layout for a view hierarchy
  Map<String, _LayoutResult> calculateLayout(
      String rootId, double width, double height) {
    final rootNode = _nodeMapping[rootId];
    if (rootNode == null) {
      developer.log('Root node not found: $rootId', name: 'DartLayout');
      return {};
    }

    // First build the node hierarchy to match the view hierarchy
    _buildNodeHierarchyFor(rootId);

    // Set root dimensions - this is necessary for the root only
    // For proper percentage calculation, the container must have explicit dimensions
    rootNode.setWidth(width);
    rootNode.setHeight(height);

    // Reset any padding and margin at the root, but keep all other props
    rootNode.setPadding(YogaEdge.all, 0);
    rootNode.setMargin(YogaEdge.all, 0);

    // Set position to relative to ensure proper positioning
    rootNode.setPositionType(YogaPositionType.relative);

    developer.log(
        'Starting layout calculation with container size: ${width}x${height}',
        name: 'DartLayout');

    // Calculate layout
    rootNode.calculateLayout(width: width, height: height);

    // Extract layout results
    final results = <String, _LayoutResult>{};
    _extractLayoutResults(rootId, results, isRoot: true);

    // Clear dirty nodes
    _dirtyNodes.clear();

    return results;
  }

  /// Build Yoga node hierarchy to match view hierarchy
  void _buildNodeHierarchyFor(String viewId) {
    // Get all children registered for this view ID
    final children = _nodeChildren[viewId] ?? [];

    // Get the yoga node for the parent
    final parentNode = _nodeMapping[viewId];
    if (parentNode == null) {
      developer.log('Parent Yoga node not found for ID: $viewId',
          name: 'DartLayout');
      return;
    }

    // Remove all existing children from Yoga node
    parentNode.removeAllChildren();

    // Add each child's Yoga node to the parent Yoga node in order
    for (int i = 0; i < children.length; i++) {
      final childId = children[i];
      final childNode = _nodeMapping[childId];

      if (childNode != null) {
        parentNode.addChild(childNode);

        // Recursively build hierarchy for this child
        _buildNodeHierarchyFor(childId);
      }
    }
  }

  /// Extract layout results from calculated Yoga nodes
  void _extractLayoutResults(String viewId, Map<String, _LayoutResult> results,
      {bool isRoot = false}) {
    final node = _nodeMapping[viewId];
    if (node == null) return;

    // Extract layout values directly from the yoga node
    double left = node.getLayoutLeft();
    double top = node.getLayoutTop();
    final width = node.getLayoutWidth();
    final height = node.getLayoutHeight();

    // If this is the root node, ensure it starts at 0,0 with no padding
    // This helps eliminate the edge spacing
    if (isRoot) {
      left = 0;
      top = 0;
    }

    developer.log(
        'Layout for $viewId: left=$left, top=$top, width=$width, height=$height',
        name: 'DartLayout');

    // Store results without any modification
    final layout = _LayoutResult(
      left: left,
      top: top,
      width: width,
      height: height,
    );

    results[viewId] = layout;
    _layoutCache[viewId] = layout;

    // Process children
    final children = _nodeChildren[viewId] ?? [];
    for (final childId in children) {
      _extractLayoutResults(childId, results);
    }
  }

  /// Get cached layout for a view, or null if not cached
  _LayoutResult? getCachedLayout(String viewId) {
    return _layoutCache[viewId];
  }

  /// Check if a node needs layout
  bool needsLayout(String viewId) {
    return _dirtyNodes.contains(viewId);
  }

  /// Dispose a node by view ID
  void disposeNode(String viewId) {
    final node = _nodeMapping[viewId];
    if (node != null) {
      node.dispose();
      _nodeMapping.remove(viewId);
      _layoutCache.remove(viewId);
      _dirtyNodes.remove(viewId);
      _propsCache.remove(viewId);
    }
  }
}

/// Represents the layout result for a view
class _LayoutResult {
  final double left;
  final double top;
  final double width;
  final double height;

  _LayoutResult({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  @override
  String toString() {
    return '_LayoutResult(left: $left, top: $top, width: $width, height: $height)';
  }
}
