import 'dart:ui' show Color;

import 'base_props.dart';
import '../constants/layout_enums.dart';
import '../constants/layout_properties.dart';

/// View component properties
class ViewProps extends BaseProps {
  final Overflow? overflow;
  @override
  final bool? pointerEvents;
  @override
  final double? borderRadius;
  @override
  final double? borderTopLeftRadius;
  @override
  final double? borderTopRightRadius;
  @override
  final double? borderBottomLeftRadius;
  @override
  final double? borderBottomRightRadius;
  @override
  final Color? borderColor;
  @override
  final double? borderWidth;
  @override
  final Color? backgroundColor;
  @override
  final double? opacity;
  @override
  final Color? shadowColor;
  @override
  final double? shadowOpacity;
  @override
  final double? shadowRadius;
  @override
  final double? shadowOffsetX;
  @override
  final double? shadowOffsetY;
  @override
  final int? elevation;
  final bool? hitSlop;
  @override
  final Map<String, dynamic>? transform;

  const ViewProps({
    this.overflow,
    this.pointerEvents,
    this.borderRadius,
    this.borderTopLeftRadius,
    this.borderTopRightRadius,
    this.borderBottomLeftRadius,
    this.borderBottomRightRadius,
    this.borderColor,
    this.borderWidth,
    this.backgroundColor,
    this.opacity,
    this.shadowColor,
    this.shadowOpacity,
    this.shadowRadius,
    this.shadowOffsetX,
    this.shadowOffsetY,
    this.elevation,
    this.hitSlop,
    this.transform,

    // Base props
    super.id,
    super.testID,
    super.accessible,
    super.accessibilityLabel,
    super.style,

    // Layout properties
    super.width,
    super.height,
    super.margin,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.marginLeft,
    super.marginHorizontal,
    super.marginVertical,
    super.padding,
    super.paddingTop,
    super.paddingRight,
    super.paddingBottom,
    super.paddingLeft,
    super.paddingHorizontal,
    super.paddingVertical,

    // Flexbox properties
    super.flexDirection,
    super.flexWrap,
    super.justifyContent,
    super.alignItems,
    super.alignContent,
    super.alignSelf,
    super.flex,
    super.flexGrow,
    super.flexShrink,
    super.flexBasis,
    super.aspectRatio,

    // Position
    super.position,
    super.zIndex,
    super.top,
    super.right,
    super.bottom,
    super.left,

    // Min/max dimensions
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    // Add view-specific properties
    if (overflow != null) map['overflow'] = overflow!.value;
    if (hitSlop != null) map['hitSlop'] = hitSlop;

    return map;
  }
}
