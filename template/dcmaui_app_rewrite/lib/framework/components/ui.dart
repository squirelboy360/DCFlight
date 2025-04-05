import 'dart:ui';
import '../packages/vdom/vdom_node.dart';
import '../packages/vdom/vdom_element.dart';
import '../constants/layout_properties.dart';
import '../constants/style_properties.dart';


/// Factory for creating UI components with unified styling approach
class UI {
  /// Create a View component
  static VDomElement View({
    required LayoutProps layout,
    StyleSheet? style,
    dynamic viewProps, // Component-specific props placeholder
    List<VDomNode> children = const [],
    String? key,
    Map<String, dynamic>? events,
  }) {
    // Merge props from both layout and style
    final propsMap = <String, dynamic>{};

    // Add layout props
    propsMap.addAll(layout.toMap());

    // Add style props if available
    if (style != null) {
      propsMap.addAll(style.toMap());
    }

    // Add component-specific props
    // This would be handled by the component-specific props class later

    // Add event handlers
    if (events != null) {
      propsMap.addAll(events);
    }

    return VDomElement(
      type: 'View',
      key: key,
      props: propsMap,
      children: children,
    );
  }

  /// Create a Text component
  static VDomElement Text({
    required String content,
    LayoutProps? layout,
    StyleSheet? style,
    dynamic textProps, // Component-specific props placeholder
    String? key,
    Map<String, dynamic>? events,
  }) {
    // Merge props from layout, style, and text-specific props
    final propsMap = <String, dynamic>{};

    // Add content
    propsMap['content'] = content;

    // Add layout props if available
    if (layout != null) {
      propsMap.addAll(layout.toMap());
    }

    // Add style props if available
    if (style != null) {
      propsMap.addAll(style.toMap());
    }

    // Add component-specific props
    // This would be handled by the component-specific props class later

    // Add event handlers
    if (events != null) {
      propsMap.addAll(events);
    }

    return VDomElement(
      type: 'Text',
      key: key,
      props: propsMap,
    );
  }

  /// Create a Button component
  static VDomElement Button({
    required LayoutProps layout,
    StyleSheet? style,
    dynamic buttonProps, // Component-specific props placeholder
    String? key,
    Function? onPress,
    Map<String, dynamic>? events,
  }) {
    // Merge props from both layout and style
    final propsMap = <String, dynamic>{};

    // Add layout props
    propsMap.addAll(layout.toMap());

    // Add style props if available
    if (style != null) {
      propsMap.addAll(style.toMap());
    }

    // Add component-specific props
    // This would be handled by the component-specific props class later

    // Add onPress handler
    if (onPress != null) {
      propsMap['onPress'] = onPress;
    }

    // Add additional event handlers
    if (events != null) {
      propsMap.addAll(events);
    }

    return VDomElement(
      type: 'Button',
      key: key,
      props: propsMap,
    );
  }

  /// Create an Image component
  static VDomElement Image({
    required LayoutProps layout,
    StyleSheet? style,
    dynamic imageProps, // Component-specific props placeholder
    String? key,
    Function? onLoad,
    Function? onError,
    Map<String, dynamic>? events,
  }) {
    // Merge props from both layout and style
    final propsMap = <String, dynamic>{};

    // Add layout props
    propsMap.addAll(layout.toMap());

    // Add style props if available
    if (style != null) {
      propsMap.addAll(style.toMap());
    }

    // Add component-specific props
    // This would be handled by the component-specific props class later

    // Add image-specific event handlers
    if (onLoad != null) {
      propsMap['onLoad'] = onLoad;
    }

    if (onError != null) {
      propsMap['onError'] = onError;
    }

    // Add additional event handlers
    if (events != null) {
      propsMap.addAll(events);
    }

    return VDomElement(
      type: 'Image',
      key: key,
      props: propsMap,
    );
  }

  /// Create a ScrollView component
  static VDomElement ScrollView({
    required LayoutProps layout,
    StyleSheet? style,
    dynamic scrollViewProps, // Component-specific props placeholder
    List<VDomNode> children = const [],
    String? key,
    Function? onScroll,
    Map<String, dynamic>? events,
  }) {
    // Merge props from both layout and style
    final propsMap = <String, dynamic>{};

    // Add layout props
    propsMap.addAll(layout.toMap());

    // Add style props if available
    if (style != null) {
      propsMap.addAll(style.toMap());
    }

    // Add component-specific props
    // This would be handled by the component-specific props class later

    // Add scroll event handler
    if (onScroll != null) {
      propsMap['onScroll'] = onScroll;
    }

    // Add additional event handlers
    if (events != null) {
      propsMap.addAll(events);
    }

    return VDomElement(
      type: 'ScrollView',
      key: key,
      props: propsMap,
      children: children,
    );
  }
}
