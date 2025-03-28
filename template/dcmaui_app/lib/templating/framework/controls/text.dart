import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Style properties for DCText
class DCTextStyle implements StyleProps {
  final Color? color;
  final double? fontSize;
  final String? fontWeight;
  final String? fontFamily;
  final String? fontStyle;
  final double? lineHeight;
  final double? letterSpacing;
  final String? textAlign;
  final String? textDecorationLine;
  final Color? textDecorationColor;
  final String? textDecorationStyle;
  final int? numberOfLines;

  const DCTextStyle({
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.fontStyle,
    this.lineHeight,
    this.letterSpacing,
    this.textAlign,
    this.textDecorationLine,
    this.textDecorationColor,
    this.textDecorationStyle,
    this.numberOfLines,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (color != null) {
      final colorValue = color!.value.toRadixString(16).padLeft(8, '0');
      map['color'] = '#$colorValue';
    }

    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight;
    if (fontFamily != null) map['fontFamily'] = fontFamily;
    if (fontStyle != null) map['fontStyle'] = fontStyle;
    if (lineHeight != null) map['lineHeight'] = lineHeight;
    if (letterSpacing != null) map['letterSpacing'] = letterSpacing;
    if (textAlign != null) map['textAlign'] = textAlign;
    if (textDecorationLine != null) {
      map['textDecorationLine'] = textDecorationLine;
    }

    if (textDecorationColor != null) {
      final colorValue =
          textDecorationColor!.value.toRadixString(16).padLeft(8, '0');
      map['textDecorationColor'] = '#$colorValue';
    }

    if (textDecorationStyle != null) {
      map['textDecorationStyle'] = textDecorationStyle;
    }
    if (numberOfLines != null) map['numberOfLines'] = numberOfLines;

    return map;
  }
}

/// Props for DCText component
class DCTextProps implements ControlProps {
  final String? text;
  final bool? selectable;
  final bool? adjustsFontSizeToFit;
  final double? minimumFontScale;
  final int? numberOfLines;
  final DCTextStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCTextProps({
    this.text,
    this.selectable,
    this.adjustsFontSizeToFit,
    this.minimumFontScale,
    this.numberOfLines,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (text != null) map['text'] = text;
    if (selectable != null) map['selectable'] = selectable;
    if (adjustsFontSizeToFit != null) {
      map['adjustsFontSizeToFit'] = adjustsFontSizeToFit;
    }
    if (minimumFontScale != null) map['minimumFontScale'] = minimumFontScale;
    if (numberOfLines != null) map['numberOfLines'] = numberOfLines;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// Text component
class DCText extends Control {
  final DCTextProps props;

  DCText({
    String? text,
    bool? selectable,
    bool? adjustsFontSizeToFit,
    double? minimumFontScale,
    int? numberOfLines,
    DCTextStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) : props = DCTextProps(
          text: text,
          selectable: selectable,
          adjustsFontSizeToFit: adjustsFontSizeToFit,
          minimumFontScale: minimumFontScale,
          numberOfLines: numberOfLines,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCText',
      props.toMap(),
      [], // No children for text
    );
  }
}
