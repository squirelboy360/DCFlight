import 'dart:ui';

import 'base_props.dart';
import '../constants/layout_enums.dart';

/// Button component properties
class ButtonProps extends BaseProps {
  final String? title;
  final Color? color; // Text color
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool? disabled;
  final String? disabledColor;

  // Convenience properties now handled through BaseProps parameters
  const ButtonProps({
    this.title,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.disabled,
    this.disabledColor,

    // BaseProps
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

    // Styling
    super.backgroundColor,
    super.opacity,
    super.borderRadius,
    super.borderColor,
    super.borderWidth,
    super.shadowColor,
    super.shadowOpacity,
    super.shadowRadius,
    super.shadowOffset,

    // Flexbox properties
    super.alignItems,
    super.justifyContent,
    super.flexDirection,
    super.flex,
    super.flexWrap,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (title != null) map['title'] = title;
    if (color != null) {
      final hexValue = color!.value & 0xFFFFFF;
      map['color'] = '#${hexValue.toRadixString(16).padLeft(6, '0')}';
    }
    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight!.value;
    if (disabled != null) map['disabled'] = disabled;
    if (disabledColor != null) map['disabledColor'] = disabledColor;

    return map;
  }
}
