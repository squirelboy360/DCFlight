import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/image.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

/// Style properties for DCImageBackground
class DCImageBackgroundStyle extends DCImageStyle {
  final Color? overlayColor;

  const DCImageBackgroundStyle({
    super.width,
    super.height,
    super.borderRadius,
    super.margin,
    super.opacity,
    super.objectFit,
    super.backgroundColor,
    this.overlayColor,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (overlayColor != null) {
      final colorValue = overlayColor!.value.toRadixString(16).padLeft(8, '0');
      map['overlayColor'] = '#$colorValue';
    }

    return map;
  }

  @override
  DCImageBackgroundStyle copyWith({
    double? width,
    double? height,
    BorderRadius? borderRadius,
    EdgeInsets? margin,
    double? opacity,
    BoxFit? objectFit,
    Color? backgroundColor,
    Color? overlayColor,
  }) {
    return DCImageBackgroundStyle(
      width: width ?? this.width,
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
      margin: margin ?? this.margin,
      opacity: opacity ?? this.opacity,
      objectFit: objectFit ?? this.objectFit,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      overlayColor: overlayColor ?? this.overlayColor,
    );
  }
}

/// Props for DCImageBackground component - extends DCImageProps
class DCImageBackgroundProps extends DCImageProps {
  final List<Control> children;

  const DCImageBackgroundProps({
    super.source,
    super.defaultSource,
    super.resizeMode,
    super.loadingIndicatorEnabled,
    super.onLoad,
    super.onError,
    super.onLoadStart,
    super.onLoadEnd,
    DCImageBackgroundStyle? style,
    super.testID,
    super.additionalProps = const {},
    this.children = const [],
  }) : super(style: style);
}

/// ImageBackground component - displays an image with child elements overlaid
class DCImageBackground extends Control {
  final DCImageBackgroundProps props;

  DCImageBackground({
    DCImageSource? source,
    DCImageSource? defaultSource,
    String? resizeMode,
    bool? loadingIndicatorEnabled,
    Function(Map<String, dynamic>)? onLoad,
    Function(Map<String, dynamic>)? onError,
    Function()? onLoadStart,
    Function()? onLoadEnd,
    DCImageBackgroundStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
    List<Control> children = const [],
  }) : props = DCImageBackgroundProps(
          source: source,
          defaultSource: defaultSource,
          resizeMode: resizeMode,
          loadingIndicatorEnabled: loadingIndicatorEnabled,
          onLoad: onLoad,
          onError: onError,
          onLoadStart: onLoadStart,
          onLoadEnd: onLoadEnd,
          style: style,
          testID: testID,
          additionalProps: additionalProps ?? const {},
          children: children,
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCImageBackground',
      props.toMap(),
      buildChildren(props.children),
    );
  }

  /// Convenience constructor for a background image with overlaid content
  static DCImageBackground network({
    required String url,
    required List<Control> children,
    Map<String, String>? headers,
    String? resizeMode,
    DCImageBackgroundStyle? style,
    Color? overlayColor,
  }) {
    return DCImageBackground(
      source: DCImageSource(
        uri: url,
        headers: headers,
      ),
      resizeMode: resizeMode ?? 'cover',
      style: (style ?? const DCImageBackgroundStyle()).copyWith(
        overlayColor: overlayColor,
      ),
      children: children,
    );
  }

  /// Convenience constructor for a background asset image with overlaid content
  static DCImageBackground asset({
    required String name,
    required List<Control> children,
    String? resizeMode,
    DCImageBackgroundStyle? style,
    Color? overlayColor,
  }) {
    return DCImageBackground(
      source: DCImageSource(
        uri: 'resource:$name',
      ),
      resizeMode: resizeMode ?? 'cover',
      style: (style ?? const DCImageBackgroundStyle()).copyWith(
        overlayColor: overlayColor,
      ),
      children: children,
    );
  }
}
