import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Props for ActivityIndicator component
class DCActivityIndicatorProps implements ControlProps {
  final bool? animating;
  final Color? color;
  final String? size;
  final bool? hidesWhenStopped;
  final ViewStyle? style;
  final String? testID;
  final Map<String, dynamic> additionalProps;

  const DCActivityIndicatorProps({
    this.animating,
    this.color,
    this.size,
    this.hidesWhenStopped,
    this.style,
    this.testID,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (animating != null) map['animating'] = animating;

    if (color != null) {
      final colorValue = color!.value.toRadixString(16).padLeft(8, '0');
      map['color'] = '#$colorValue';
    }

    if (size != null) map['size'] = size;
    if (hidesWhenStopped != null) map['hidesWhenStopped'] = hidesWhenStopped;
    if (style != null) map['style'] = style!.toMap();
    if (testID != null) map['testID'] = testID;

    return map;
  }
}

/// ActivityIndicator component
class DCActivityIndicator extends Control {
  final DCActivityIndicatorProps props;

  DCActivityIndicator({
    bool? animating,
    Color? color,
    String? size,
    bool? hidesWhenStopped,
    ViewStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
  }) : props = DCActivityIndicatorProps(
          animating: animating,
          color: color,
          size: size,
          hidesWhenStopped: hidesWhenStopped,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCActivityIndicator',
      props.toMap(),
      [],
    );
  }

  /// Create a large activity indicator
  static DCActivityIndicator large({
    Color? color,
    bool? animating,
    ViewStyle? style,
  }) {
    return DCActivityIndicator(
      size: 'large',
      color: color,
      animating: animating ?? true,
      style: style,
    );
  }

  /// Create a small activity indicator
  static DCActivityIndicator small({
    Color? color,
    bool? animating,
    ViewStyle? style,
  }) {
    return DCActivityIndicator(
      size: 'small',
      color: color,
      animating: animating ?? true,
      style: style,
    );
  }
}
