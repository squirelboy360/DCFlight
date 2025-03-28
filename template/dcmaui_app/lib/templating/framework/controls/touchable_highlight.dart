import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Props for DCTouchableHighlight component
class DCTouchableHighlightProps implements ControlProps {
  final Function()? onPress;
  final Function()? onPressIn;
  final Function()? onPressOut;
  final Function()? onLongPress;
  final Color? underlayColor;
  final bool? disabled;
  final double? delayPressIn;
  final double? delayPressOut;
  final double? delayLongPress;
  final ViewStyle? style;
  final Map<String, dynamic> additionalProps;

  const DCTouchableHighlightProps({
    this.onPress,
    this.onPressIn,
    this.onPressOut,
    this.onLongPress,
    this.underlayColor,
    this.disabled,
    this.delayPressIn,
    this.delayPressOut,
    this.delayLongPress,
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

    if (underlayColor != null) {
      final colorValue = underlayColor!.value.toRadixString(16).padLeft(8, '0');
      map['underlayColor'] = '#$colorValue';
    }

    if (disabled != null) map['disabled'] = disabled;
    if (delayPressIn != null) map['delayPressIn'] = delayPressIn;
    if (delayPressOut != null) map['delayPressOut'] = delayPressOut;
    if (delayLongPress != null) map['delayLongPress'] = delayLongPress;
    if (style != null) map['style'] = style!.toMap();

    return map;
  }
}

/// TouchableHighlight component that shows an underlay color when pressed
class DCTouchableHighlight extends Control {
  final DCTouchableHighlightProps props;
  final List<Control> children;

  DCTouchableHighlight({
    Function()? onPress,
    Function()? onPressIn,
    Function()? onPressOut,
    Function()? onLongPress,
    Color? underlayColor,
    bool? disabled,
    double? delayPressIn,
    double? delayPressOut,
    double? delayLongPress,
    ViewStyle? style,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCTouchableHighlightProps(
          onPress: onPress,
          onPressIn: onPressIn,
          onPressOut: onPressOut,
          onLongPress: onLongPress,
          underlayColor: underlayColor,
          disabled: disabled,
          delayPressIn: delayPressIn,
          delayPressOut: delayPressOut,
          delayLongPress: delayLongPress,
          style: style,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCTouchableHighlight',
      props.toMap(),
      buildChildren(children),
    );
  }
}
