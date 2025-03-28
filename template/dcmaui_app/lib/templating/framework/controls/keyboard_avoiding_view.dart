import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';


/// Props for KeyboardAvoidingView component
class DCKeyboardAvoidingViewProps implements ControlProps {
  final String? behavior; // "height", "position", "padding"
  final double? keyboardVerticalOffset;
  final bool? enabled;
  final Function(Map<String, dynamic>)? onKeyboardShow;
  final Function()? onKeyboardHide;
  final ViewStyle? style;
  final ViewStyle? contentContainerStyle;
  final Map<String, dynamic> additionalProps;

  const DCKeyboardAvoidingViewProps({
    this.behavior,
    this.keyboardVerticalOffset,
    this.enabled,
    this.onKeyboardShow,
    this.onKeyboardHide,
    this.style,
    this.contentContainerStyle,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (behavior != null) map['behavior'] = behavior;
    if (keyboardVerticalOffset != null) {
      map['keyboardVerticalOffset'] = keyboardVerticalOffset;
    }
    if (enabled != null) map['enabled'] = enabled;
    if (onKeyboardShow != null) map['onKeyboardShow'] = onKeyboardShow;
    if (onKeyboardHide != null) map['onKeyboardHide'] = onKeyboardHide;
    if (style != null) map['style'] = style!.toMap();
    if (contentContainerStyle != null) {
      map['contentContainerStyle'] = contentContainerStyle!.toMap();
    }

    return map;
  }
}

/// KeyboardAvoidingView component that automatically adjusts its height or position to avoid the keyboard
class DCKeyboardAvoidingView extends Control {
  final DCKeyboardAvoidingViewProps props;
  final List<Control> children;

  DCKeyboardAvoidingView({
    String? behavior,
    double? keyboardVerticalOffset,
    bool? enabled,
    Function(Map<String, dynamic>)? onKeyboardShow,
    Function()? onKeyboardHide,
    ViewStyle? style,
    ViewStyle? contentContainerStyle,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCKeyboardAvoidingViewProps(
          behavior: behavior,
          keyboardVerticalOffset: keyboardVerticalOffset,
          enabled: enabled,
          onKeyboardShow: onKeyboardShow,
          onKeyboardHide: onKeyboardHide,
          style: style,
          contentContainerStyle: contentContainerStyle,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCKeyboardAvoidingView',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Create a KeyboardAvoidingView that uses padding behavior (default)
  static DCKeyboardAvoidingView padding({
    required List<Control> children,
    double? keyboardVerticalOffset,
    ViewStyle? style,
    ViewStyle? contentContainerStyle,
  }) {
    return DCKeyboardAvoidingView(
      behavior: 'padding',
      keyboardVerticalOffset: keyboardVerticalOffset,
      style: style,
      contentContainerStyle: contentContainerStyle,
      children: children,
    );
  }

  /// Create a KeyboardAvoidingView that uses height behavior
  static DCKeyboardAvoidingView height({
    required List<Control> children,
    double? keyboardVerticalOffset,
    ViewStyle? style,
    ViewStyle? contentContainerStyle,
  }) {
    return DCKeyboardAvoidingView(
      behavior: 'height',
      keyboardVerticalOffset: keyboardVerticalOffset,
      style: style,
      contentContainerStyle: contentContainerStyle,
      children: children,
    );
  }

  /// Create a KeyboardAvoidingView that uses position behavior
  static DCKeyboardAvoidingView position({
    required List<Control> children,
    double? keyboardVerticalOffset,
    ViewStyle? style,
    ViewStyle? contentContainerStyle,
  }) {
    return DCKeyboardAvoidingView(
      behavior: 'position',
      keyboardVerticalOffset: keyboardVerticalOffset,
      style: style,
      contentContainerStyle: contentContainerStyle,
      children: children,
    );
  }
}
