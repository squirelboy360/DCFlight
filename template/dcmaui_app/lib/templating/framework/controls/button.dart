import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Colors;

/// Style properties for DCButton
class DCButtonStyle implements StyleProps {
  final Color? color;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? minWidth;
  final double? minHeight;
  final double? width;
  final double? height;

  const DCButtonStyle({
    this.color,
    this.backgroundColor,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.margin,
    this.minWidth,
    this.minHeight,
    this.width,
    this.height,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (color != null) {
      final colorValue = color!.value.toRadixString(16).padLeft(8, '0');
      map['color'] = '#$colorValue';
    }

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
    }

    if (borderRadius != null) map['borderRadius'] = borderRadius;
    if (borderWidth != null) map['borderWidth'] = borderWidth;

    if (borderColor != null) {
      final colorValue = borderColor!.value.toRadixString(16).padLeft(8, '0');
      map['borderColor'] = '#$colorValue';
    }

    if (fontSize != null) map['fontSize'] = fontSize;

    if (fontWeight != null) {
      switch (fontWeight) {
        case FontWeight.bold:
          map['fontWeight'] = 'bold';
          break;
        case FontWeight.w100:
          map['fontWeight'] = '100';
          break;
        case FontWeight.w200:
          map['fontWeight'] = '200';
          break;
        case FontWeight.w300:
          map['fontWeight'] = '300';
          break;
        case FontWeight.w400:
          map['fontWeight'] = '400';
          break;
        case FontWeight.w500:
          map['fontWeight'] = '500';
          break;
        case FontWeight.w600:
          map['fontWeight'] = '600';
          break;
        case FontWeight.w700:
          map['fontWeight'] = '700';
          break;
        case FontWeight.w800:
          map['fontWeight'] = '800';
          break;
        case FontWeight.w900:
          map['fontWeight'] = '900';
          break;
        default:
          map['fontWeight'] = 'normal';
          break;
      }
    }

    if (padding != null) {
      if (padding!.left == padding!.right &&
          padding!.top == padding!.bottom &&
          padding!.left == padding!.top) {
        map['padding'] = padding!.top;
      } else {
        map['paddingLeft'] = padding!.left;
        map['paddingRight'] = padding!.right;
        map['paddingTop'] = padding!.top;
        map['paddingBottom'] = padding!.bottom;
      }
    }

    if (margin != null) {
      if (margin!.left == margin!.right &&
          margin!.top == margin!.bottom &&
          margin!.left == margin!.top) {
        map['margin'] = margin!.top;
      } else {
        map['marginLeft'] = margin!.left;
        map['marginRight'] = margin!.right;
        map['marginTop'] = margin!.top;
        map['marginBottom'] = margin!.bottom;
      }
    }

    if (minWidth != null) map['minWidth'] = minWidth;
    if (minHeight != null) map['minHeight'] = minHeight;
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;

    return map;
  }
}

/// Props for DCButton component
class DCButtonProps implements ControlProps {
  final String? title;
  final Function()? onPress;
  final bool? disabled;
  final bool? loading;
  final Color? color;
  final String? type; // 'solid', 'outline', 'clear'
  final String? testID;
  final DCButtonStyle? style;
  final Map<String, dynamic> additionalProps;

  const DCButtonProps({
    this.title,
    this.onPress,
    this.disabled,
    this.loading,
    this.color,
    this.type,
    this.testID,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (title != null) map['title'] = title;
    if (onPress != null) map['onPress'] = onPress;
    if (disabled != null) map['disabled'] = disabled;
    if (loading != null) map['loading'] = loading;

    if (color != null) {
      final colorValue = color!.value.toRadixString(16).padLeft(8, '0');
      map['color'] = '#$colorValue';
    }

    if (type != null) map['type'] = type;
    if (testID != null) map['testID'] = testID;
    if (style != null) map['style'] = style!.toMap();

    return map;
  }
}

/// Button component
class DCButton extends Control {
  final DCButtonProps props;

  DCButton({
    String? title,
    Function()? onPress,
    bool? disabled,
    bool? loading,
    Color? color,
    String? type,
    String? testID,
    DCButtonStyle? style,
    Map<String, dynamic>? additionalProps,
  }) : props = DCButtonProps(
          title: title,
          onPress: onPress,
          disabled: disabled,
          loading: loading,
          color: color,
          type: type,
          testID: testID,
          style: style,
          additionalProps: additionalProps ?? const {},
        );

  // CRITICAL FIX: Ensure onPress handler is properly called
  @override
  VNode build() {
    // CRITICAL FIX: Make sure onPress is directly in the props map, not nested
    final buttonProps = props.toMap();

    // CRITICAL FIX: Make sure the handler doesn't receive any args if it doesn't want them
    if (props.onPress != null) {
      buttonProps['onPress'] = () {
        debugPrint('DCButton: Calling onPress handler directly');
        props.onPress!();
      };
    }

    return ElementFactory.createElement(
      'DCButton',
      buttonProps,
      [], // Button doesn't have children in React Native style
    );
  }

  /// Create a solid button with custom color
  static DCButton solid({
    required String title,
    required Function() onPress,
    Color? backgroundColor,
    Color? textColor,
    bool? disabled,
    bool? loading,
    double? borderRadius,
    DCButtonStyle? style,
  }) {
    return DCButton(
      title: title,
      onPress: onPress,
      disabled: disabled,
      loading: loading,
      type: 'solid',
      color: textColor ?? Colors.white,
      style: DCButtonStyle(
        backgroundColor: backgroundColor ?? Colors.blue,
        borderRadius: borderRadius ?? 8.0,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        fontWeight: FontWeight.bold,
      ).withCustomStyle(style),
    );
  }

  /// Create an outline button
  static DCButton outline({
    required String title,
    required Function() onPress,
    Color? borderColor,
    Color? textColor,
    bool? disabled,
    bool? loading,
    double? borderRadius,
    DCButtonStyle? style,
  }) {
    final baseColor = textColor ?? Colors.blue;

    return DCButton(
      title: title,
      onPress: onPress,
      disabled: disabled,
      loading: loading,
      type: 'outline',
      color: baseColor,
      style: DCButtonStyle(
        backgroundColor: Colors.transparent,
        borderRadius: borderRadius ?? 8.0,
        borderWidth: 1.0,
        borderColor: borderColor ?? baseColor,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      ).withCustomStyle(style),
    );
  }

  /// Create a text button with no background
  static DCButton text({
    required String title,
    required Function() onPress,
    Color? textColor,
    bool? disabled,
    bool? loading,
    DCButtonStyle? style,
  }) {
    return DCButton(
      title: title,
      onPress: onPress,
      disabled: disabled,
      loading: loading,
      type: 'clear',
      color: textColor ?? Colors.blue,
      style: DCButtonStyle(
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      ).withCustomStyle(style),
    );
  }
}

/// Extension to allow merging styles
extension ButtonStyleExtension on DCButtonStyle {
  DCButtonStyle withCustomStyle(DCButtonStyle? customStyle) {
    if (customStyle == null) return this;

    return DCButtonStyle(
      color: customStyle.color ?? color,
      backgroundColor: customStyle.backgroundColor ?? backgroundColor,
      borderRadius: customStyle.borderRadius ?? borderRadius,
      borderWidth: customStyle.borderWidth ?? borderWidth,
      borderColor: customStyle.borderColor ?? borderColor,
      fontSize: customStyle.fontSize ?? fontSize,
      fontWeight: customStyle.fontWeight ?? fontWeight,
      padding: customStyle.padding ?? padding,
      margin: customStyle.margin ?? margin,
      minWidth: customStyle.minWidth ?? minWidth,
      minHeight: customStyle.minHeight ?? minHeight,
      width: customStyle.width ?? width,
      height: customStyle.height ?? height,
    );
  }
}
