import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Style properties for DCTextInput
class DCTextInputStyle implements StyleProps {
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? borderWidth;
  final Color? borderColor;
  final int? minHeight;
  final int? maxHeight;

  const DCTextInputStyle({
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontFamily,
    this.textAlign,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.minHeight,
    this.maxHeight,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (color != null) {
      final colorValue = color!.value.toRadixString(16).padLeft(8, '0');
      map['color'] = '#$colorValue';
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

    if (fontFamily != null) map['fontFamily'] = fontFamily;

    if (textAlign != null) {
      switch (textAlign) {
        case TextAlign.left:
          map['textAlign'] = 'left';
          break;
        case TextAlign.right:
          map['textAlign'] = 'right';
          break;
        case TextAlign.center:
          map['textAlign'] = 'center';
          break;
        case TextAlign.justify:
          map['textAlign'] = 'justify';
          break;
        default:
          map['textAlign'] = 'auto';
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

    if (minHeight != null) map['minHeight'] = minHeight;
    if (maxHeight != null) map['maxHeight'] = maxHeight;

    return map;
  }
}

/// Props for DCTextInput component
class DCTextInputProps implements ControlProps {
  final String? value;
  final Function(String)? onChangeText;
  final Function(Map<String, dynamic>)? onChange;
  final Function(Map<String, dynamic>)? onSubmitEditing;
  final Function()? onFocus;
  final Function()? onBlur;
  final Function(Map<String, dynamic>)? onSelectionChange;
  final Function()? onEndEditing;
  final String? placeholder;
  final Color? placeholderTextColor;
  final bool? secureTextEntry;
  final bool? multiline;
  final String? keyboardType;
  final String? returnKeyType;
  final String? autoCapitalize;
  final bool? autoCorrect;
  final bool? editable;
  final bool? autoFocus;
  final int? maxLength;
  final DCTextInputStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCTextInputProps({
    this.value,
    this.onChangeText,
    this.onChange,
    this.onSubmitEditing,
    this.onFocus,
    this.onBlur,
    this.onSelectionChange,
    this.onEndEditing,
    this.placeholder,
    this.placeholderTextColor,
    this.secureTextEntry,
    this.multiline,
    this.keyboardType,
    this.returnKeyType,
    this.autoCapitalize,
    this.autoCorrect,
    this.editable,
    this.autoFocus,
    this.maxLength,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (value != null) map['value'] = value;
    if (onChangeText != null) map['onChangeText'] = onChangeText;
    if (onChange != null) map['onChange'] = onChange;
    if (onSubmitEditing != null) map['onSubmitEditing'] = onSubmitEditing;
    if (onFocus != null) map['onFocus'] = onFocus;
    if (onBlur != null) map['onBlur'] = onBlur;
    if (onSelectionChange != null) map['onSelectionChange'] = onSelectionChange;
    if (onEndEditing != null) map['onEndEditing'] = onEndEditing;
    if (placeholder != null) map['placeholder'] = placeholder;

    if (placeholderTextColor != null) {
      final colorValue =
          placeholderTextColor!.value.toRadixString(16).padLeft(8, '0');
      map['placeholderTextColor'] = '#$colorValue';
    }

    if (secureTextEntry != null) map['secureTextEntry'] = secureTextEntry;
    if (multiline != null) map['multiline'] = multiline;
    if (keyboardType != null) map['keyboardType'] = keyboardType;
    if (returnKeyType != null) map['returnKeyType'] = returnKeyType;
    if (autoCapitalize != null) map['autoCapitalize'] = autoCapitalize;
    if (autoCorrect != null) map['autoCorrect'] = autoCorrect;
    if (editable != null) map['editable'] = editable;
    if (autoFocus != null) map['autoFocus'] = autoFocus;
    if (maxLength != null) map['maxLength'] = maxLength;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// TextInput component
class DCTextInput extends Control {
  final DCTextInputProps props;

  DCTextInput({
    String? value,
    Function(String)? onChangeText,
    Function(Map<String, dynamic>)? onChange,
    Function(Map<String, dynamic>)? onSubmitEditing,
    Function()? onFocus,
    Function()? onBlur,
    Function(Map<String, dynamic>)? onSelectionChange,
    Function()? onEndEditing,
    String? placeholder,
    Color? placeholderTextColor,
    bool? secureTextEntry,
    bool? multiline,
    String? keyboardType,
    String? returnKeyType,
    String? autoCapitalize,
    bool? autoCorrect,
    bool? editable,
    bool? autoFocus,
    int? maxLength,
    DCTextInputStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) : props = DCTextInputProps(
          value: value,
          onChangeText: onChangeText,
          onChange: onChange,
          onSubmitEditing: onSubmitEditing,
          onFocus: onFocus,
          onBlur: onBlur,
          onSelectionChange: onSelectionChange,
          onEndEditing: onEndEditing,
          placeholder: placeholder,
          placeholderTextColor: placeholderTextColor,
          secureTextEntry: secureTextEntry,
          multiline: multiline,
          keyboardType: keyboardType,
          returnKeyType: returnKeyType,
          autoCapitalize: autoCapitalize,
          autoCorrect: autoCorrect,
          editable: editable,
          autoFocus: autoFocus,
          maxLength: maxLength,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCTextInput',
      props.toMap(),
      [],
    );
  }

  /// Convenience constructors
  static DCTextInput field({
    String? value,
    Function(String)? onChangeText,
    String? placeholder,
    DCTextInputStyle? style,
    bool? secureTextEntry,
    String? keyboardType,
  }) {
    return DCTextInput(
      value: value,
      onChangeText: onChangeText,
      placeholder: placeholder,
      style: style,
      secureTextEntry: secureTextEntry,
      keyboardType: keyboardType,
    );
  }

  // Convenience constructor for a multiline text area
  static DCTextInput multiline({
    String? value,
    Function(String)? onChangeText,
    String? placeholder,
    DCTextInputStyle? style,
  }) {
    return DCTextInput(
      value: value,
      onChangeText: onChangeText,
      placeholder: placeholder,
      style: style,
      multiline: true,
      keyboardType: 'default',
    );
  }

  /// Convenience constructor for a password field
  static DCTextInput password({
    String? value,
    Function(String)? onChangeText,
    String? placeholder = "Password",
    DCTextInputStyle? style,
  }) {
    return DCTextInput(
      value: value,
      onChangeText: onChangeText,
      placeholder: placeholder,
      style: style,
      secureTextEntry: true,
      keyboardType: 'default',
    );
  }

  /// Convenience constructor for an email input field
  static DCTextInput email({
    String? value,
    Function(String)? onChangeText,
    String? placeholder = "Email",
    DCTextInputStyle? style,
  }) {
    return DCTextInput(
      value: value,
      onChangeText: onChangeText,
      placeholder: placeholder,
      style: style,
      keyboardType: 'email-address',
      autoCapitalize: 'none',
    );
  }
}
