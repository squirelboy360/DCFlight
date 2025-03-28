import 'dart:ui' show Color;

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
  final dynamic padding;
  final dynamic paddingTop;
  final dynamic paddingRight;
  final dynamic paddingBottom;
  final dynamic paddingLeft;

  // Flexbox properties
  final String?
      flexDirection; // 'column', 'row', 'column-reverse', 'row-reverse'
  final String?
      justifyContent; // 'flex-start', 'flex-end', 'center', 'space-between', 'space-around', 'space-evenly'
  final String?
      alignItems; // 'flex-start', 'flex-end', 'center', 'stretch', 'baseline'
  final String?
      alignSelf; // 'auto', 'flex-start', 'flex-end', 'center', 'stretch', 'baseline'
  final dynamic flex; // double or int
  final dynamic flexGrow; // double or int
  final dynamic flexShrink; // double or int
  final dynamic flexBasis; // double, int or String

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

  // Transform properties
  final Map<String, dynamic>? transform;

  // Shadow properties
  final Color? shadowColor;
  final double? shadowOpacity;
  final double? shadowRadius;
  final Map<String, double>? shadowOffset;

  // Other visual properties
  final bool? overflow; // 'visible', 'hidden', 'scroll'
  final double? zIndex;
  final String? position; // 'relative', 'absolute'
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const BaseProps({
    this.id,
    this.testID,
    this.accessible,
    this.accessibilityLabel,
    this.style,
    this.pointerEvents,
    this.width,
    this.height,
    this.margin,
    this.marginTop,
    this.marginRight,
    this.marginBottom,
    this.marginLeft,
    this.padding,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.paddingLeft,
    this.flexDirection,
    this.justifyContent,
    this.alignItems,
    this.alignSelf,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.backgroundColor,
    this.opacity,
    this.borderRadius,
    this.borderTopLeftRadius,
    this.borderTopRightRadius,
    this.borderBottomLeftRadius,
    this.borderBottomRightRadius,
    this.borderColor,
    this.borderWidth,
    this.transform,
    this.shadowColor,
    this.shadowOpacity,
    this.shadowRadius,
    this.shadowOffset,
    this.overflow,
    this.zIndex,
    this.position,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  /// Convert properties to a map that can be passed to native
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

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
    if (style != null) map.addAll(style!);
    if (pointerEvents != null) map['pointerEvents'] = pointerEvents;

    // Layout properties
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    if (margin != null) map['margin'] = margin;
    if (marginTop != null) map['marginTop'] = marginTop;
    if (marginRight != null) map['marginRight'] = marginRight;
    if (marginBottom != null) map['marginBottom'] = marginBottom;
    if (marginLeft != null) map['marginLeft'] = marginLeft;
    if (padding != null) map['padding'] = padding;
    if (paddingTop != null) map['paddingTop'] = paddingTop;
    if (paddingRight != null) map['paddingRight'] = paddingRight;
    if (paddingBottom != null) map['paddingBottom'] = paddingBottom;
    if (paddingLeft != null) map['paddingLeft'] = paddingLeft;

    // Flexbox properties
    if (flexDirection != null) map['flexDirection'] = flexDirection;
    if (justifyContent != null) map['justifyContent'] = justifyContent;
    if (alignItems != null) map['alignItems'] = alignItems;
    if (alignSelf != null) map['alignSelf'] = alignSelf;
    if (flex != null) map['flex'] = flex;
    if (flexGrow != null) map['flexGrow'] = flexGrow;
    if (flexShrink != null) map['flexShrink'] = flexShrink;
    if (flexBasis != null) map['flexBasis'] = flexBasis;

    // Appearance properties
    if (backgroundColor != null) {
      // Convert Flutter Color to hex string
      if (backgroundColor is Color) {
        final hexValue = backgroundColor!.value & 0xFFFFFF;
        map['backgroundColor'] =
            '#${hexValue.toRadixString(16).padLeft(6, '0')}';
      }
    }
    if (opacity != null) map['opacity'] = opacity;
    if (borderRadius != null) map['borderRadius'] = borderRadius;
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
    if (borderColor != null) map['borderColor'] = borderColor;
    if (borderWidth != null) map['borderWidth'] = borderWidth;

    // Transform properties
    if (transform != null) map['transform'] = transform;

    // Shadow properties
    if (shadowColor != null) map['shadowColor'] = shadowColor;
    if (shadowOpacity != null) map['shadowOpacity'] = shadowOpacity;
    if (shadowRadius != null) map['shadowRadius'] = shadowRadius;
    if (shadowOffset != null) map['shadowOffset'] = shadowOffset;

    // Other visual properties
    if (overflow != null) map['overflow'] = overflow;
    if (zIndex != null) map['zIndex'] = zIndex;
    if (position != null) map['position'] = position;
    if (top != null) map['top'] = top;
    if (right != null) map['right'] = right;
    if (bottom != null) map['bottom'] = bottom;
    if (left != null) map['left'] = left;

    return map;
  }
}
