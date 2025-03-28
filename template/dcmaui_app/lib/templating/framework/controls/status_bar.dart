import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:io' show Platform;

/// Props for StatusBar component
class DCStatusBarProps implements ControlProps {
  final String? barStyle;
  final bool? hidden;
  final Color? backgroundColor;
  final bool? translucent;
  final bool? networkActivityIndicatorVisible;
  final bool? animated;
  final Map<String, dynamic> additionalProps;

  const DCStatusBarProps({
    this.barStyle,
    this.hidden,
    this.backgroundColor,
    this.translucent,
    this.networkActivityIndicatorVisible,
    this.animated,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (barStyle != null) map['barStyle'] = barStyle;
    if (hidden != null) map['hidden'] = hidden;

    if (backgroundColor != null) {
      final colorValue =
          backgroundColor!.value.toRadixString(16).padLeft(8, '0');
      map['backgroundColor'] = '#$colorValue';
    }

    if (translucent != null) map['translucent'] = translucent;
    if (networkActivityIndicatorVisible != null) {
      map['networkActivityIndicatorVisible'] = networkActivityIndicatorVisible;
    }
    if (animated != null) map['animated'] = animated;

    return map;
  }
}

/// StatusBar component for controlling the device status bar
class DCStatusBar extends Control {
  final DCStatusBarProps props;

  DCStatusBar({
    String? barStyle,
    bool? hidden,
    Color? backgroundColor,
    bool? translucent,
    bool? networkActivityIndicatorVisible,
    bool? animated,
    Map<String, dynamic>? additionalProps,
  }) : props = DCStatusBarProps(
          barStyle: barStyle,
          hidden: hidden,
          backgroundColor: backgroundColor,
          translucent: translucent,
          networkActivityIndicatorVisible: networkActivityIndicatorVisible,
          animated: animated,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCStatusBar',
      props.toMap(),
      [], // StatusBar doesn't have children
    );
  }

  /// Static method to set status bar style
  static void setBarStyle(String style, {bool animated = false}) {
    DCStatusBar(
      barStyle: style,
      animated: animated,
    ).build();
  }

  /// Static method to hide or show the status bar
  static void setHidden(bool hidden, {bool animated = false}) {
    DCStatusBar(
      hidden: hidden,
      animated: animated,
    ).build();
  }

  /// Static method to set status bar background color
  static void setBackgroundColor(Color color, {bool animated = false}) {
    DCStatusBar(
      backgroundColor: color,
      animated: animated,
    ).build();
  }

  /// Static method to set translucent property
  static void setTranslucent(bool translucent) {
    DCStatusBar(
      translucent: translucent,
    ).build();
  }

  /// Set iOS network activity indicator visibility
  static void setNetworkActivityIndicatorVisible(bool visible) {
    if (!Platform.isIOS) return;

    DCStatusBar(
      networkActivityIndicatorVisible: visible,
    ).build();
  }
}
