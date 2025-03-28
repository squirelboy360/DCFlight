import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Props for DCPressable component
class DCPressableProps implements ControlProps {
  // Core event handlers
  final Function(Map<String, dynamic>)? onPress;
  final Function(Map<String, dynamic>)? onPressIn;
  final Function(Map<String, dynamic>)? onPressOut;
  final Function(Map<String, dynamic>)? onPressMove;
  final Function(Map<String, dynamic>)? onLongPress;

  // Styling functions
  final Function(Map<String, dynamic>)? style;
  final Function(bool)? android_ripple;

  // Configuration options
  final bool? disabled;
  final EdgeInsets? hitSlop;
  final EdgeInsets? pressRetentionOffset;
  final double? delayLongPress;
  final double? minPressDuration;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCPressableProps({
    this.onPress,
    this.onPressIn,
    this.onPressOut,
    this.onPressMove,
    this.onLongPress,
    this.style,
    this.android_ripple,
    this.disabled,
    this.hitSlop,
    this.pressRetentionOffset,
    this.delayLongPress,
    this.minPressDuration,
    this.testID,
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
    if (onPressMove != null) map['onPressMove'] = onPressMove;
    if (onLongPress != null) map['onLongPress'] = onLongPress;

    // Style functions need to be handled specially
    if (style != null) map['style'] = style;
    if (android_ripple != null) map['android_ripple'] = android_ripple;

    if (disabled != null) map['disabled'] = disabled;

    // Convert EdgeInsets to maps
    if (hitSlop != null) {
      map['hitSlop'] = {
        'top': hitSlop!.top,
        'left': hitSlop!.left,
        'bottom': hitSlop!.bottom,
        'right': hitSlop!.right,
      };
    }

    if (pressRetentionOffset != null) {
      map['pressRetentionOffset'] = {
        'top': pressRetentionOffset!.top,
        'left': pressRetentionOffset!.left,
        'bottom': pressRetentionOffset!.bottom,
        'right': pressRetentionOffset!.right,
      };
    }

    if (delayLongPress != null) map['delayLongPress'] = delayLongPress;
    if (minPressDuration != null) map['minPressDuration'] = minPressDuration;
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// Pressable component - a more flexible touchable component
class DCPressable extends Control {
  final DCPressableProps props;
  final List<Control> children;

  DCPressable({
    Function(Map<String, dynamic>)? onPress,
    Function(Map<String, dynamic>)? onPressIn,
    Function(Map<String, dynamic>)? onPressOut,
    Function(Map<String, dynamic>)? onPressMove,
    Function(Map<String, dynamic>)? onLongPress,
    Function(Map<String, dynamic>)? style,
    Function(bool)? android_ripple,
    bool? disabled,
    EdgeInsets? hitSlop,
    EdgeInsets? pressRetentionOffset,
    double? delayLongPress,
    double? minPressDuration,
    String? testID,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCPressableProps(
          onPress: onPress,
          onPressIn: onPressIn,
          onPressOut: onPressOut,
          onPressMove: onPressMove,
          onLongPress: onLongPress,
          style: style,
          android_ripple: android_ripple,
          disabled: disabled,
          hitSlop: hitSlop,
          pressRetentionOffset: pressRetentionOffset,
          delayLongPress: delayLongPress,
          minPressDuration: minPressDuration,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCPressable',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Create a basic pressable with default touch feedback behavior
  static DCPressable basic({
    required Function(Map<String, dynamic>) onPress,
    required List<Control> children,
    ViewStyle? normalStyle,
    ViewStyle? pressedStyle,
    bool? disabled,
  }) {
    return DCPressable(
      onPress: onPress,
      disabled: disabled,
      style: (state) {
        // Determine if pressed
        bool isPressed = state['pressed'] == true;

        // Return the appropriate style based on state
        if (isPressed && pressedStyle != null) {
          return pressedStyle.toMap();
        } else if (normalStyle != null) {
          return normalStyle.toMap();
        }
        return {};
      },
      children: children,
    );
  }

  /// Create a pressable that changes opacity when pressed
  static DCPressable withOpacity({
    required Function(Map<String, dynamic>) onPress,
    required List<Control> children,
    ViewStyle? style,
    double activeOpacity = 0.2,
    bool? disabled,
  }) {
    return DCPressable(
      onPress: onPress,
      disabled: disabled,
      style: (state) {
        // Get base style
        final baseStyle = style?.toMap() ?? {};

        // Apply opacity if pressed
        if (state['pressed'] == true) {
          baseStyle['opacity'] = activeOpacity;
        }

        return baseStyle;
      },
      children: children,
    );
  }
}
