import 'dart:ui' show Color;
import 'base_props.dart';
import '../constants/layout_enums.dart';

/// Text component properties
class TextProps extends BaseProps {
  final String? fontFamily;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? lineHeight;
  final TextAlign? textAlign;
  final TextDecorationLine? textDecorationLine;
  final TextTransform? textTransform;
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

    // Flexbox properties
    super.flexDirection,
    super.justifyContent,
    super.alignItems,
    super.alignContent,
    super.alignSelf,
    super.flex,
    super.flexGrow,
    super.flexShrink,
    super.flexBasis,
    super.flexWrap,

    // Additional layout properties
    super.position,
    super.zIndex,
    super.top,
    super.right,
    super.bottom,
    super.left,

    // Styling
    super.opacity,
    super.backgroundColor,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (fontFamily != null) map['fontFamily'] = fontFamily;
    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight?.value;
    if (fontStyle != null) map['fontStyle'] = fontStyle?.value;
    if (letterSpacing != null) map['letterSpacing'] = letterSpacing;
    if (lineHeight != null) map['lineHeight'] = lineHeight;
    if (textAlign != null) map['textAlign'] = textAlign?.value;
    if (textDecorationLine != null) {
      map['textDecorationLine'] = textDecorationLine?.value;
    }
    if (textTransform != null) map['textTransform'] = textTransform?.value;
    if (color != null) {
      final hexValue = color!.value & 0xFFFFFF;
      map['color'] = '#${hexValue.toRadixString(16).padLeft(6, '0')}';
    }
    if (numberOfLines != null) map['numberOfLines'] = numberOfLines;
    if (selectable != null) map['selectable'] = selectable;
    if (adjustsFontSizeToFit != null) {
      map['adjustsFontSizeToFit'] = adjustsFontSizeToFit;
    }
    if (minimumFontSize != null) map['minimumFontSize'] = minimumFontSize;

    return map;
  }
}
