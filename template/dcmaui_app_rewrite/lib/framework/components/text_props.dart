import 'dart:ui' show Color;
import 'base_props.dart';

/// Text component properties
class TextProps extends BaseProps {
  final String? fontFamily;
  final double? fontSize;
  final String? fontWeight; // 'normal', 'bold', '100'...'900'
  final String? fontStyle; // 'normal', 'italic'
  final double? letterSpacing;
  final double? lineHeight;
  final String? textAlign; // 'left', 'center', 'right', 'justify'
  final String? textDecorationLine; // 'none', 'underline', 'line-through'
  final String? textTransform; // 'none', 'uppercase', 'lowercase', 'capitalize'
  final Color? color;
  final int? numberOfLines;
  final bool? selectable;
  final bool? adjustsFontSizeToFit;
  final double? minimumFontSize;

  const TextProps({
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.lineHeight,
    this.textAlign,
    this.textDecorationLine,
    this.textTransform,
    this.color,
    this.numberOfLines,
    this.selectable,
    this.adjustsFontSizeToFit,
    this.minimumFontSize,
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
    super.flexDirection,
    super.justifyContent,
    super.alignItems,
    super.alignSelf,
    super.flex,
    super.opacity,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (fontFamily != null) map['fontFamily'] = fontFamily;
    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight;
    if (fontStyle != null) map['fontStyle'] = fontStyle;
    if (letterSpacing != null) map['letterSpacing'] = letterSpacing;
    if (lineHeight != null) map['lineHeight'] = lineHeight;
    if (textAlign != null) map['textAlign'] = textAlign;
    if (textDecorationLine != null) {
      map['textDecorationLine'] = textDecorationLine;
    }
    if (textTransform != null) map['textTransform'] = textTransform;
    if (color != null) map['color'] = color;
    if (numberOfLines != null) map['numberOfLines'] = numberOfLines;
    if (selectable != null) map['selectable'] = selectable;
    if (adjustsFontSizeToFit != null) {
      map['adjustsFontSizeToFit'] = adjustsFontSizeToFit;
    }
    if (minimumFontSize != null) map['minimumFontSize'] = minimumFontSize;

    return map;
  }
}
