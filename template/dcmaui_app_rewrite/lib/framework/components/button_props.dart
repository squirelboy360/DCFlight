import 'dart:ui' show Color;

import 'view_props.dart';
import 'text_props.dart';
import '../constants/layout_properties.dart';

/// Button component properties
class ButtonProps extends ViewProps {
  final String? title;
  final Color? titleColor;
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? disabledColor;
  final bool? disabled;
  final double? activeOpacity;

  const ButtonProps({
    this.title,
    this.titleColor,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.disabledColor,
    this.disabled,
    this.activeOpacity,

    // View props
    super.overflow,
    super.pointerEvents,
    super.borderRadius,
    super.borderTopLeftRadius,
    super.borderTopRightRadius,
    super.borderBottomLeftRadius,
    super.borderBottomRightRadius,
    super.borderColor,
    super.borderWidth,
    super.backgroundColor,
    super.opacity,
    super.shadowColor,
    super.shadowOpacity,
    super.shadowRadius,
    super.shadowOffsetX,
    super.shadowOffsetY,
    super.elevation,
    super.hitSlop,
    super.transform,

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
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    // Add button-specific properties
    if (title != null) map['title'] = title;
    if (titleColor != null) {
      final hexValue = titleColor!.value & 0xFFFFFF;
      map['titleColor'] = '#${hexValue.toRadixString(16).padLeft(6, '0')}';
    }
    if (fontFamily != null) map['fontFamily'] = fontFamily;
    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight?.value;
    if (disabledColor != null) {
      final hexValue = disabledColor!.value & 0xFFFFFF;
      map['disabledColor'] = '#${hexValue.toRadixString(16).padLeft(6, '0')}';
    }
    if (disabled != null) map['disabled'] = disabled;
    if (activeOpacity != null) map['activeOpacity'] = activeOpacity;

    return map;
  }
}
