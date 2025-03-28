import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Props for DCTouchableWithoutFeedback component
class DCTouchableWithoutFeedbackProps implements ControlProps {
  final Function()? onPress;
  final Function()? onPressIn;
  final Function()? onPressOut;
  final Function()? onLongPress;
  final bool? disabled;
  final double? delayPressIn;
  final double? delayPressOut;
  final double? delayLongPress;
  final EdgeInsets? hitSlop;
  final ViewStyle? style;
  final Map<String, dynamic> additionalProps;

  const DCTouchableWithoutFeedbackProps({
    this.onPress,
    this.onPressIn,
    this.onPressOut,
    this.onLongPress,
    this.disabled,
    this.delayPressIn,
    this.delayPressOut,
    this.delayLongPress,
    this.hitSlop,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (onPress != null) map['onPress'] = onPress;
    if (onPressIn != null) map['onPressIn'] = onPressIn;
    if (onPressOut != null) map['onPressOut'] = onPressOut;
    if (onLongPress != null) map['onLongPress'] = onLongPress;
    if (disabled != null) map['disabled'] = disabled;
    if (delayPressIn != null) map['delayPressIn'] = delayPressIn;
    if (delayPressOut != null) map['delayPressOut'] = delayPressOut;
    if (delayLongPress != null) map['delayLongPress'] = delayLongPress;

    // Convert EdgeInsets to a map for hitSlop
    if (hitSlop != null) {
      map['hitSlop'] = {
        'top': hitSlop?.top,
        'left': hitSlop?.left,
        'bottom': hitSlop?.bottom,
        'right': hitSlop?.right,
      };
    }

    if (style != null) map['style'] = style!.toMap();

    return map;
  }
}

/// TouchableWithoutFeedback component - handles touches without visual feedback
class DCTouchableWithoutFeedback extends Control {
  final DCTouchableWithoutFeedbackProps props;
  final List<Control> children;

  DCTouchableWithoutFeedback({
    Function()? onPress,
    Function()? onPressIn,
    Function()? onPressOut,
    Function()? onLongPress,
    bool? disabled,
    double? delayPressIn,
    double? delayPressOut,
    double? delayLongPress,
    EdgeInsets? hitSlop,
    ViewStyle? style,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCTouchableWithoutFeedbackProps(
          onPress: onPress,
          onPressIn: onPressIn,
          onPressOut: onPressOut,
          onLongPress: onLongPress,
          disabled: disabled,
          delayPressIn: delayPressIn,
          delayPressOut: delayPressOut,
          delayLongPress: delayLongPress,
          hitSlop: hitSlop,
          style: style,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCTouchableWithoutFeedback',
      props.toMap(),
      buildChildren(children),
    );
  }
}
