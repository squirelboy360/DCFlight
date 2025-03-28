import 'dart:ui';

import 'base_props.dart';

/// Button component properties
class ButtonProps extends BaseProps {
  final String? title;
  final Color? color; // Text color
  final double? fontSize;
  final String? fontWeight;
  final bool? disabled;
  final String? disabledColor;

  const ButtonProps({
    this.title,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.disabled,
    this.disabledColor,
    super.id,
    super.testID,
    super.accessible,
    super.accessibilityLabel,
    super.style,
    super.width,
    super.height,
    super.margin,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.marginLeft,
    super.padding,
    super.paddingTop,
    super.paddingRight,
    super.paddingBottom,
    super.paddingLeft,
    super.backgroundColor,
    super.opacity,
    super.borderRadius,
    super.borderColor,
    super.borderWidth,
    super.shadowColor,
    super.shadowOpacity,
    super.shadowRadius,
    super.shadowOffset,
    super.alignItems,
    super.justifyContent,
    super.flexDirection,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (title != null) map['title'] = title;
    if (color != null) map['color'] = color;
    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight;
    if (disabled != null) map['disabled'] = disabled;
    if (disabledColor != null) map['disabledColor'] = disabledColor;

    return map;
  }
}
