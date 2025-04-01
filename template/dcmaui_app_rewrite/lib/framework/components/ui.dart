import 'dart:ui';
import '../packages/vdom/vdom_node.dart';
import '../packages/vdom/vdom_element.dart';
import '../packages/text/text_measurement_service.dart';
import 'view_props.dart';
import 'button_props.dart';
import 'image_props.dart';
import 'scroll_view_props.dart';
import 'text_props.dart';
import 'modifiers/text_content.dart';

/// Factory for creating UI components
class UI {
  /// Create a View component
  static VDomElement View({
    required ViewProps props,
    List<VDomNode> children = const [],
    String? key,
  }) {
    return VDomElement(
      type: 'View',
      key: key,
      props: props.toMap(),
      children: children,
    );
  }

  /// Create a Text component with automatic measurement
  /// New simplified version that takes a direct string and TextProps
  static VDomElement Text({
    required String content,
    TextProps? props,
    String? key,
  }) {
    // Convert props to map or use empty map if null
    final propsMap = props?.toMap() ?? <String, dynamic>{};

    // Add content to props
    propsMap['content'] = content;

    // Get the text content
    final text = content;

    // Initialize measurements with reasonable defaults
    double width = 10.0;
    double height = 20.0;

    // Perform text measurement if we have enough info
    if (propsMap.containsKey('fontSize')) {
      final fontSize = propsMap['fontSize'] as double? ?? 14.0;

      // Create measurement key
      final measurementKey = TextMeasurementKey(
        text: text,
        fontSize: fontSize,
        fontFamily: propsMap['fontFamily'] as String?,
        fontWeight: propsMap['fontWeight'] as String?,
        letterSpacing: propsMap['letterSpacing'] as double?,
        textAlign: propsMap['textAlign'] as String?,
        maxWidth: propsMap['width'] as double?,
      );

      // Try to get cached measurement
      final cachedMeasurement =
          TextMeasurementService.instance.getCachedMeasurement(measurementKey);

      // If we have a cached measurement, use it to set dimensions
      if (cachedMeasurement != null) {
        width = cachedMeasurement.width;
        height = cachedMeasurement.height;
      } else {
        // Schedule measurement for later, but use estimated size now
        final estimate =
            TextMeasurementService.instance.estimateTextSize(text, fontSize);
        width = estimate.width;
        height = estimate.height;

        // Request actual measurement asynchronously
        TextMeasurementService.instance.measureText(
          text,
          fontSize: fontSize,
          fontFamily: propsMap['fontFamily'] as String?,
          fontWeight: propsMap['fontWeight'] as String?,
          letterSpacing: propsMap['letterSpacing'] as double?,
          textAlign: propsMap['textAlign'] as String?,
          maxWidth: propsMap['width'] as double?,
        );
      }
    }

    // Always set width and height to ensure the element has dimensions
    if (!propsMap.containsKey('width') || propsMap['width'] == 0.0) {
      propsMap['width'] = width;
    }

    if (!propsMap.containsKey('height') || propsMap['height'] == 0.0) {
      propsMap['height'] = height;
    }

    // Create the text element
    return VDomElement(
      type: 'Text',
      key: key,
      props: propsMap,
    );
  }

  /// Create a Button component
  static VDomElement Button({
    required ButtonProps props,
    String? key,
    Function? onPress,
  }) {
    final propsMap = props.toMap();

    if (onPress != null) {
      propsMap['onPress'] = onPress;
    }

    return VDomElement(
      type: 'Button',
      key: key,
      props: propsMap,
    );
  }

  /// Create an Image component
  static VDomElement Image({
    required ImageProps props,
    String? key,
  }) {
    return VDomElement(
      type: 'Image',
      key: key,
      props: props.toMap(),
    );
  }

  /// Create a ScrollView component
  static VDomElement ScrollView({
    required ScrollViewProps props,
    List<VDomNode> children = const [],
    String? key,
    Function? onScroll,
  }) {
    final propsMap = props.toMap();

    if (onScroll != null) {
      propsMap['onScroll'] = onScroll;
    }

    return VDomElement(
      type: 'ScrollView',
      key: key,
      props: propsMap,
      children: children,
    );
  }
}
