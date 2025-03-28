import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Style properties for View component
class ViewStyle implements StyleProps {
  const ViewStyle({
    this.shadowRadius,
    this.shadowOffset,
    this.constraints,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.alignSelf,
    this.position,
    this.top,
    this.right,
    this.bottom,
    this.left,
    this.display,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? shadowRadius;
  final Offset? shadowOffset;
  final BoxConstraints? constraints;
  final int? flex;
  final int? flexGrow;
  final int? flexShrink;
  final dynamic flexBasis;
  final String? alignSelf;
  final String? position;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;
  final String? display;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final double? borderRadius;

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (backgroundColor != null) {
      final colorValue = backgroundColor!.toHexString();
      map['backgroundColor'] = colorValue;
    }

    // Handle padding
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

    // Handle margin
    if (margin != null) {
      if (margin!.left == margin!.right &&
          margin!.top == margin!.bottom &&
          margin!.left == margin!.top) {
        map['margin'] = margin!.top;
      } else {
        map['marginLeft'] = margin!.left;
        map['marginRight'] = margin!.right;
        map['marginTop'] = margin!.top;
        map['marginBottom'] = margin!.bottom;
      }
    }

    // Add explicit width, height and other layout properties
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    if (borderRadius != null) map['borderRadius'] = borderRadius;

    // Add position properties
    if (position != null) map['position'] = position;
    if (top != null) map['top'] = top;
    if (right != null) map['right'] = right;
    if (bottom != null) map['bottom'] = bottom;
    if (left != null) map['left'] = left;

    // Add flex properties
    if (flex != null) map['flex'] = flex;
    if (flexGrow != null) map['flexGrow'] = flexGrow;
    if (flexShrink != null) map['flexShrink'] = flexShrink;
    if (flexBasis != null) map['flexBasis'] = flexBasis;
    if (alignSelf != null) map['alignSelf'] = alignSelf;
    if (display != null) map['display'] = display;

    return map;
  }
}

/// Props for View component
class DCViewProps implements ControlProps {
  final bool? pointerEvents;
  final bool? accessible;
  final String? accessibilityLabel;
  final bool? accessibilityLiveRegion;
  final String? importantForAccessibility;
  final String? testID;
  final Function()? onClick;
  final Function()? onLayout;
  final ViewStyle? style;
  final Map<String, dynamic> additionalProps;

  const DCViewProps({
    this.pointerEvents,
    this.accessible,
    this.accessibilityLabel,
    this.accessibilityLiveRegion,
    this.importantForAccessibility,
    this.testID,
    this.onClick,
    this.onLayout,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

    if (pointerEvents != null) map['pointerEvents'] = pointerEvents;
    if (accessible != null) map['accessible'] = accessible;
    if (accessibilityLabel != null) {
      map['accessibilityLabel'] = accessibilityLabel;
    }
    if (accessibilityLiveRegion != null) {
      map['accessibilityLiveRegion'] = accessibilityLiveRegion;
    }
    if (importantForAccessibility != null) {
      map['importantForAccessibility'] = importantForAccessibility;
    }
    if (testID != null) map['testID'] = testID;
    if (onClick != null) map['onClick'] = onClick;
    if (onLayout != null) map['onLayout'] = onLayout;
    if (style != null) map['style'] = style!.toMap();

    return map;
  }
}

/// View component that matches React Native's View
class DCView extends Control {
  final DCViewProps props;
  final List<Control> children;

  DCView({
    bool? pointerEvents,
    bool? accessible,
    String? accessibilityLabel,
    bool? accessibilityLiveRegion,
    String? importantForAccessibility,
    String? testID,
    Function()? onClick,
    Function()? onLayout,
    ViewStyle? style,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCViewProps(
          pointerEvents: pointerEvents,
          accessible: accessible,
          accessibilityLabel: accessibilityLabel,
          accessibilityLiveRegion: accessibilityLiveRegion,
          importantForAccessibility: importantForAccessibility,
          testID: testID,
          onClick: onClick,
          onLayout: onLayout,
          style: style,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCView',
      props.toMap(),
      buildChildren(children),
    );
  }
}

// Add this extension method to handle color conversion consistently
extension ColorExtension on Color {
  String toHexString() =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
