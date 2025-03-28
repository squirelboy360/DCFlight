import 'dart:ui' show Color;
import '../packages/vdom/vdom_element.dart';
import '../packages/vdom/vdom_node.dart';
import 'view_props.dart';
import 'text_props.dart';
import 'button_props.dart';
import 'image_props.dart';
import 'scroll_view_props.dart';
import 'package:flutter/material.dart' show Colors;

/// Helper class with factory methods to create UI components
class UI {
  /// Create a View component
  static VDomElement View({
    String? key,
    required ViewProps props,
    List<VDomNode>? children,
  }) {
    return VDomElement(
      type: 'View',
      key: key,
      props: props.toMap(),
      children: children ?? [],
    );
  }

  /// Create a Text component
  static VDomElement Text({
    String? key,
    required String content,
    TextProps? props,
  }) {
    final propsMap = props?.toMap() ?? {};
    propsMap['content'] = content;

    return VDomElement(
      type: 'Text',
      key: key,
      props: propsMap,
    );
  }

  /// Create a Button component
  static VDomElement Button({
    String? key,
    required String title,
    required Function(Map<String, dynamic>) onPress,
    ButtonProps? props,
  }) {
    final propsMap = props?.toMap() ?? {};
    propsMap['title'] = title;
    propsMap['onPress'] = onPress;

    return VDomElement(
      type: 'Button',
      key: key,
      props: propsMap,
    );
  }

  /// Create an Image component
  static VDomElement Image({
    String? key,
    required String source,
    ImageProps? props,
  }) {
    final propsMap = props?.toMap() ?? {};
    propsMap['source'] = source;

    return VDomElement(
      type: 'Image',
      key: key,
      props: propsMap,
    );
  }

  /// Create a ScrollView component
  static VDomElement ScrollView({
    String? key,
    ScrollViewProps? props,
    List<VDomNode>? children,
  }) {
    return VDomElement(
      type: 'ScrollView',
      key: key,
      props: props?.toMap() ?? {},
      children: children ?? [],
    );
  }

  /// Helper function to create transform object
  static Map<String, dynamic> transform({
    double? scale,
    double? scaleX,
    double? scaleY,
    double? rotate,
    double? rotateX,
    double? rotateY,
    double? rotateZ,
    double? translateX,
    double? translateY,
  }) {
    final Map<String, dynamic> result = {};
    if (scale != null) result['scale'] = scale;
    if (scaleX != null) result['scaleX'] = scaleX;
    if (scaleY != null) result['scaleY'] = scaleY;
    if (rotate != null) result['rotate'] = rotate;
    if (rotateX != null) result['rotateX'] = rotateX;
    if (rotateY != null) result['rotateY'] = rotateY;
    if (rotateZ != null) result['rotateZ'] = rotateZ;
    if (translateX != null) result['translateX'] = translateX;
    if (translateY != null) result['translateY'] = translateY;
    return result;
  }

  /// Helper function to create shadow offset
  static Map<String, double> shadowOffset({
    required double width,
    required double height,
  }) {
    return {'width': width, 'height': height};
  }

  /// Helper function to generate a color string from a Color object
  static String colorToHex(Color color) {
    int hexValue = color.value & 0xFFFFFF;
    return '#${hexValue.toRadixString(16).padLeft(6, '0')}';
  }

  // Direct reference to Flutter Colors
  static final colors = Colors;
}
