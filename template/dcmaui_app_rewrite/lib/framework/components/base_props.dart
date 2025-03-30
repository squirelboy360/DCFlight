import 'dart:ui' show Color;

import '../constants/layout_enums.dart';
import '../constants/layout_properties.dart';

/// Base component properties that all components can have
class BaseProps {
  final String? id;
  final String? testID;
  final bool? accessible;
  final String? accessibilityLabel;
  final Map<String, dynamic>? style; // For direct style overrides
  final bool? pointerEvents;

  // Layout properties
  final dynamic width; // Can be double, int, String (e.g., '100%')
  final dynamic height;
  final dynamic margin;
  final dynamic marginTop;
  final dynamic marginRight;
  final dynamic marginBottom;
  final dynamic marginLeft;
  final dynamic marginHorizontal;
  final dynamic marginVertical;
  final dynamic padding;
  final dynamic paddingTop;
  final dynamic paddingRight;
  final dynamic paddingBottom;
  final dynamic paddingLeft;
  final dynamic paddingHorizontal;
  final dynamic paddingVertical;

  // Flexbox properties
  final FlexDirection?
      flexDirection; // 'column', 'row', 'columnReverse', 'rowReverse'
  final FlexWrap? flexWrap; // 'nowrap', 'wrap', 'wrapReverse'
  final JustifyContent?
      justifyContent; // 'flexStart', 'center', 'flexEnd', 'spaceBetween', 'spaceAround', 'spaceEvenly'
  final AlignItems?
      alignItems; // 'flexStart', 'center', 'flexEnd', 'stretch', 'baseline'
  final AlignContent?
      alignContent; // 'flexStart', 'center', 'flexEnd', 'stretch', 'spaceBetween', 'spaceAround'
  final AlignSelf?
      alignSelf; // 'auto', 'flexStart', 'center', 'flexEnd', 'stretch', 'baseline'
  final dynamic flex; // double or int
  final dynamic flexGrow; // double or int
  final dynamic flexShrink; // double or int
  final dynamic flexBasis; // double, int or String
  final dynamic aspectRatio; // double for width/height ratio

  // Position properties (absolute positioning)
  final Position? position; // 'relative', 'absolute'
  final dynamic zIndex; // int for stacking order
  final dynamic top; // Can be double, int, String
  final dynamic right; // Can be double, int, String
  final dynamic bottom; // Can be double, int, String
  final dynamic left; // Can be double, int, String

  // Min/max dimensions
  final dynamic minWidth;
  final dynamic maxWidth;
  final dynamic minHeight;
  final dynamic maxHeight;

  // Appearance properties
  final Color? backgroundColor;
  final double? opacity;
  final double? borderRadius;
  final double? borderTopLeftRadius;
  final double? borderTopRightRadius;
  final double? borderBottomLeftRadius;
  final double? borderBottomRightRadius;
  final Color? borderColor;
  final double? borderWidth;
  final double? shadowRadius;
  final Color? shadowColor;
  final double? shadowOpacity;
  final double? shadowOffsetX;
  final double? shadowOffsetY;
  final int? elevation; // Android-specific but mapped to shadow on iOS

  // Transform properties
  final Map<String, dynamic>? transform;

  const BaseProps({
    this.id,
    this.testID,
    this.accessible,
    this.accessibilityLabel,
    this.style,
    this.pointerEvents,

    // Layout
    this.width,
    this.height,
    this.margin,
    this.marginTop,
    this.marginRight,
    this.marginBottom,
    this.marginLeft,
    this.marginHorizontal,
    this.marginVertical,
    this.padding,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.paddingLeft,
    this.paddingHorizontal,
    this.paddingVertical,

    // Flexbox
    this.flexDirection,
    this.flexWrap,
    this.justifyContent,
    this.alignItems,
    this.alignContent,
    this.alignSelf,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.aspectRatio,

    // Position
    this.position,
    this.zIndex,
    this.top,
    this.right,
    this.bottom,
    this.left,

    // Min/max
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,

    // Appearance
    this.backgroundColor,
    this.opacity,
    this.borderRadius,
    this.borderTopLeftRadius,
    this.borderTopRightRadius,
    this.borderBottomLeftRadius,
    this.borderBottomRightRadius,
    this.borderColor,
    this.borderWidth,
    this.shadowRadius,
    this.shadowColor,
    this.shadowOpacity,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.elevation,

    // Transform
    this.transform,
  });

  /// Convert to a Map representation for serialization
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    // Add properties that are not null
    if (id != null) {
      map['id'] = id;
    }

    if (testID != null) {
      map['testID'] = testID;
    }

    if (accessible != null) {
      map['accessible'] = accessible;
    }

    if (accessibilityLabel != null) {
      map['accessibilityLabel'] = accessibilityLabel;
    }

    if (style != null) {
      map['style'] = style;
    }

    if (pointerEvents != null) {
      map['pointerEvents'] = pointerEvents;
    }

    // Layout properties using constants from LayoutProperties
    if (width != null) {
      map[LayoutProperties.width] = width;
    }

    if (height != null) {
      map[LayoutProperties.height] = height;
    }

    if (margin != null) {
      map[LayoutProperties.margin] = margin;
    }

    if (marginTop != null) {
      map[LayoutProperties.marginTop] = marginTop;
    }

    if (marginRight != null) {
      map[LayoutProperties.marginRight] = marginRight;
    }

    if (marginBottom != null) {
      map[LayoutProperties.marginBottom] = marginBottom;
    }

    if (marginLeft != null) {
      map[LayoutProperties.marginLeft] = marginLeft;
    }

    if (marginHorizontal != null) {
      map[LayoutProperties.marginHorizontal] = marginHorizontal;
    }

    if (marginVertical != null) {
      map[LayoutProperties.marginVertical] = marginVertical;
    }

    if (padding != null) {
      map[LayoutProperties.padding] = padding;
    }

    if (paddingTop != null) {
      map[LayoutProperties.paddingTop] = paddingTop;
    }

    if (paddingRight != null) {
      map[LayoutProperties.paddingRight] = paddingRight;
    }

    if (paddingBottom != null) {
      map[LayoutProperties.paddingBottom] = paddingBottom;
    }

    if (paddingLeft != null) {
      map[LayoutProperties.paddingLeft] = paddingLeft;
    }

    if (paddingHorizontal != null) {
      map[LayoutProperties.paddingHorizontal] = paddingHorizontal;
    }

    if (paddingVertical != null) {
      map[LayoutProperties.paddingVertical] = paddingVertical;
    }

    // Flexbox properties using constants
    if (flexDirection != null) {
      map[LayoutProperties.flexDirection] = flexDirection!.value;
    }

    if (flexWrap != null) {
      map[LayoutProperties.flexWrap] = flexWrap!.value;
    }

    if (justifyContent != null) {
      map[LayoutProperties.justifyContent] = justifyContent!.value;
    }

    if (alignItems != null) {
      map[LayoutProperties.alignItems] = alignItems!.value;
    }

    if (alignContent != null) {
      map[LayoutProperties.alignContent] = alignContent!.value;
    }

    if (alignSelf != null) {
      map[LayoutProperties.alignSelf] = alignSelf!.value;
    }

    if (flex != null) {
      map[LayoutProperties.flex] = flex;
    }

    if (flexGrow != null) {
      map[LayoutProperties.flexGrow] = flexGrow;
    }

    if (flexShrink != null) {
      map[LayoutProperties.flexShrink] = flexShrink;
    }

    if (flexBasis != null) {
      map[LayoutProperties.flexBasis] = flexBasis;
    }

    if (aspectRatio != null) {
      map[LayoutProperties.aspectRatio] = aspectRatio;
    }

    // Position properties using constants
    if (position != null) {
      map[LayoutProperties.position] = position!.value;
    }

    if (zIndex != null) {
      map[LayoutProperties.zIndex] = zIndex;
    }

    if (top != null) {
      map[LayoutProperties.top] = top;
    }

    if (right != null) {
      map[LayoutProperties.right] = right;
    }

    if (bottom != null) {
      map[LayoutProperties.bottom] = bottom;
    }

    if (left != null) {
      map[LayoutProperties.left] = left;
    }

    // Min/max dimensions using constants
    if (minWidth != null) {
      map[LayoutProperties.minWidth] = minWidth;
    }

    if (maxWidth != null) {
      map[LayoutProperties.maxWidth] = maxWidth;
    }

    if (minHeight != null) {
      map[LayoutProperties.minHeight] = minHeight;
    }

    if (maxHeight != null) {
      map[LayoutProperties.maxHeight] = maxHeight;
    }

    // Appearance properties
    if (backgroundColor != null) {
      final color = backgroundColor!;
      // Use toRadixString instead of direct value access
      final hexValue = color.value & 0xFFFFFF;
      map['backgroundColor'] = '#${hexValue.toRadixString(16).padLeft(6, '0')}';
    }

    if (opacity != null) {
      map['opacity'] = opacity;
    }

    if (borderRadius != null) {
      map['borderRadius'] = borderRadius;
    }

    if (borderTopLeftRadius != null) {
      map['borderTopLeftRadius'] = borderTopLeftRadius;
    }

    if (borderTopRightRadius != null) {
      map['borderTopRightRadius'] = borderTopRightRadius;
    }

    if (borderBottomLeftRadius != null) {
      map['borderBottomLeftRadius'] = borderBottomLeftRadius;
    }

    if (borderBottomRightRadius != null) {
      map['borderBottomRightRadius'] = borderBottomRightRadius;
    }

    if (borderColor != null) {
      final color = borderColor!;
      // Use toRadixString instead of direct value access
      final hexValue = color.value & 0xFFFFFF;
      map['borderColor'] = '#${hexValue.toRadixString(16).padLeft(6, '0')}';
    }

    if (borderWidth != null) {
      map['borderWidth'] = borderWidth;
    }

    if (shadowRadius != null) {
      map['shadowRadius'] = shadowRadius;
    }

    if (shadowColor != null) {
      final color = shadowColor!;
      // Use toRadixString instead of direct value access
      final hexValue = color.value & 0xFFFFFF;
      map['shadowColor'] = '#${hexValue.toRadixString(16).padLeft(6, '0')}';
    }

    if (shadowOpacity != null) {
      map['shadowOpacity'] = shadowOpacity;
    }

    if (shadowOffsetX != null) {
      map['shadowOffsetX'] = shadowOffsetX;
    }

    if (shadowOffsetY != null) {
      map['shadowOffsetY'] = shadowOffsetY;
    }

    if (elevation != null) {
      map['elevation'] = elevation;
    }

    // Transform properties
    if (transform != null) {
      map['transform'] = transform;
    }

    return map;
  }
}
