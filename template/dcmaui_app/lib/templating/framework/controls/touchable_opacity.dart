import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

/// Props for DCTouchableOpacity component
class DCTouchableOpacityProps implements ControlProps {
  final Function()? onPress;
  final Function()? onPressIn;
  final Function()? onPressOut;
  final Function()? onLongPress;
  final bool? disabled;
  final double? activeOpacity;
  final double? delayPressIn;
  final double? delayPressOut;
  final double? delayLongPress;
  final ViewStyle? style;
  final Map<String, dynamic> additionalProps;

  const DCTouchableOpacityProps({
    this.onPress,
    this.onPressIn,
    this.onPressOut,
    this.onLongPress,
    this.disabled,
    this.activeOpacity,
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
    if (disabled != null) map['disabled'] = disabled;
    if (activeOpacity != null) map['activeOpacity'] = activeOpacity;
    if (delayPressIn != null) map['delayPressIn'] = delayPressIn;
    if (delayPressOut != null) map['delayPressOut'] = delayPressOut;
    if (delayLongPress != null) map['delayLongPress'] = delayLongPress;
    if (style != null) map['style'] = style!.toMap();

    return map;
  }
}

/// TouchableOpacity component that changes opacity when pressed
class DCTouchableOpacity extends Control {
  final DCTouchableOpacityProps props;
  final List<Control> children;

  DCTouchableOpacity({
    Function()? onPress,
    Function()? onPressIn,
    Function()? onPressOut,
    Function()? onLongPress,
    bool? disabled,
    double? activeOpacity,
    double? delayPressIn,
    double? delayPressOut,
    double? delayLongPress,
    ViewStyle? style,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCTouchableOpacityProps(
          onPress: onPress,
          onPressIn: onPressIn,
          onPressOut: onPressOut,
          onLongPress: onLongPress,
          disabled: disabled,
          activeOpacity: activeOpacity,
          delayPressIn: delayPressIn,
          delayPressOut: delayPressOut,
          delayLongPress: delayLongPress,
          style: style,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCTouchableOpacity',
      props.toMap(),
      buildChildren(children),
    );
  }
}
