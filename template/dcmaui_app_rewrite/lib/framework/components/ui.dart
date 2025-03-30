import 'dart:ui';
import '../packages/vdom/vdom_node.dart';
import '../packages/vdom/vdom_element.dart';
import '../packages/text/text_measurement_service.dart';
import 'view_props.dart';
import 'button_props.dart';
import 'image_props.dart';
import 'scroll_view_props.dart';
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
  static VDomElement Text({
    required TextContent content,
    String? key,
  }) {
    // Extract the text props from the content
    final textNodes = content.generateTextNodes(null);

    // For now, just return the first text node
    if (textNodes.isEmpty) {
      return VDomElement(
        type: 'Text',
        key: key,
        props: {'content': ''},
      );
    }

    final textNode = textNodes.first;
    final props = Map<String, dynamic>.from(textNode.props);

    // Get the text content
    final text = props['content'] as String? ?? '';

    // Perform text measurement if we have enough info
    if (props.containsKey('fontSize')) {
      final fontSize = props['fontSize'] as double? ?? 14.0;

      // Create measurement key
      final measurementKey = TextMeasurementKey(
        text: text,
        fontSize: fontSize,
        fontFamily: props['fontFamily'] as String?,
        fontWeight: props['fontWeight'] as String?,
        letterSpacing: props['letterSpacing'] as double?,
        textAlign: props['textAlign'] as String?,
        maxWidth: null, // Could get from parent container in future
      );

      // Try to get cached measurement
      final cachedMeasurement =
          TextMeasurementService.instance.getCachedMeasurement(measurementKey);

      // If we have a cached measurement, use it to set initial dimensions
      if (cachedMeasurement != null) {
        if (!props.containsKey('width')) {
          props['width'] = cachedMeasurement.width;
        }

        if (!props.containsKey('height')) {
          props['height'] = cachedMeasurement.height;
        }
      } else {
        // Schedule measurement for later - this is a non-blocking operation
        TextMeasurementService.instance
            .measureText(
          text,
          fontSize: fontSize,
          fontFamily: props['fontFamily'] as String?,
          fontWeight: props['fontWeight'] as String?,
          letterSpacing: props['letterSpacing'] as double?,
          textAlign: props['textAlign'] as String?,
        )
            .then((measurement) {
          // The measurement result will be used next time
        });
      }
    }

    // Create a new VDomElement with the given key instead of modifying the textNode
    return VDomElement(
      type: textNode.type,
      key: key,
      props: props,
      children: textNode.children,
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
