import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';
import 'dart:io' show Platform;

/// Props for InputAccessoryView component
class DCInputAccessoryViewProps implements ControlProps {
  final String nativeID;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final Map<String, dynamic> additionalProps;

  const DCInputAccessoryViewProps({
    required this.nativeID,
    this.backgroundColor,
    this.padding,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nativeID': nativeID,
      ...additionalProps,
    };

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
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

    return map;
  }
}

/// InputAccessoryView component for iOS text input customization
class DCInputAccessoryView extends Control {
  final DCInputAccessoryViewProps props;
  final List<Control> children;

  DCInputAccessoryView({
    required String nativeID,
    Color? backgroundColor,
    EdgeInsets? padding,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCInputAccessoryViewProps(
          nativeID: nativeID,
          backgroundColor: backgroundColor,
          padding: padding,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    // This component only works on iOS
    if (!Platform.isIOS) {
      return ElementFactory.createElement('DCView', {'display': 'none'}, []);
    }

    return ElementFactory.createElement(
      'DCInputAccessoryView',
      props.toMap(),
      buildChildren(children),
    );
  }
}
