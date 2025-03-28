import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Style properties for DCCheckbox
class DCCheckboxStyle implements StyleProps {
  final Color? tintColor;
  final Color? checkedColor;
  final double? boxSize;
  final EdgeInsets? margin;

  const DCCheckboxStyle({
    this.tintColor,
    this.checkedColor,
    this.boxSize,
    this.margin,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (tintColor != null) {
      final colorValue = tintColor!.value.toRadixString(16).padLeft(8, '0');
      map['tintColor'] = '#$colorValue';
    }

    if (checkedColor != null) {
      final colorValue = checkedColor!.value.toRadixString(16).padLeft(8, '0');
      map['checkedColor'] = '#$colorValue';
    }

    if (boxSize != null) map['boxSize'] = boxSize;

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

    return map;
  }
}

/// Props for DCCheckbox component
class DCCheckboxProps implements ControlProps {
  final bool value;
  final Function(bool)? onChange;
  final bool? disabled;
  final DCCheckboxStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCCheckboxProps({
    required this.value,
    this.onChange,
    this.disabled,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'value': value,
      ...additionalProps,
    };

    if (onChange != null) map['onChange'] = onChange;
    if (disabled != null) map['disabled'] = disabled;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// DCCheckbox component
class DCCheckbox extends Control {
  final DCCheckboxProps props;

  DCCheckbox({
    required bool value,
    Function(bool)? onChange,
    bool? disabled,
    DCCheckboxStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) : props = DCCheckboxProps(
          value: value,
          onChange: onChange,
          disabled: disabled,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCCheckbox',
      props.toMap(),
      [], // DCCheckbox doesn't have children
    );
  }

  /// Create a styled checkbox with custom colors
  static DCCheckbox styled({
    required bool value,
    required Function(bool) onChange,
    Color? tintColor,
    Color? checkedColor,
    double? boxSize,
    bool? disabled,
  }) {
    return DCCheckbox(
      value: value,
      onChange: onChange,
      disabled: disabled,
      style: DCCheckboxStyle(
        tintColor: tintColor,
        checkedColor: checkedColor,
        boxSize: boxSize,
      ),
    );
  }
}
