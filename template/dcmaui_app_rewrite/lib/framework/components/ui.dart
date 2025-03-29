import 'dart:ui' show Color;
import '../packages/vdom/vdom_element.dart';
import '../packages/vdom/vdom_node.dart';
import 'view_props.dart';
import 'text_props.dart';
import 'button_props.dart';
import 'image_props.dart';
import 'scroll_view_props.dart';
import 'modifiers/text_content.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/foundation.dart';

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

  /// Create a Text component - STRICT version that ONLY accepts TextContent
  static VDomElement Text({
    String? key,
    required TextContent content,
  }) {
    // Generate React Native style text nodes from TextContent
    final textNodes = content.generateTextNodes(null);

    // If only one node, return it directly with the correct key
    if (textNodes.length == 1) {
      // Instead of modifying the existing element's key (which is final)
      // Create a new element with the key we want
      final node = textNodes.first;
      if (key != null) {
        // Create a new element with the same props but with our key
        return VDomElement(
          type: node.type,
          key: key,
          props: node.props,
          children: node.children,
        );
      }
      return node;
    }

    // For multiple segments, create a row of text nodes
    return VDomElement(
      type: 'View',
      key: key, // Pass key to the container view
      props: {'flexDirection': 'row', 'flexWrap': 'wrap'},
      children: textNodes,
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
    ImageProps? props,
  }) {
    final propsMap = props?.toMap() ?? {};

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
