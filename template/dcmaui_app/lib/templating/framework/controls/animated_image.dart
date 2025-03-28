import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/animated_view.dart';
import 'package:dc_test/templating/framework/controls/image.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

/// Props for AnimatedImage component
class DCAnimatedImageProps extends DCImageProps {
  final Map<String, AnimatedValue>? animatedStyles;
  final Function(Map<String, dynamic>)? onAnimationStart;
  final Function(Map<String, dynamic>)? onAnimationComplete;

  const DCAnimatedImageProps({
    super.source,
    super.defaultSource,
    super.resizeMode,
    super.loadingIndicatorEnabled,
    super.onLoad,
    super.onError,
    super.onLoadStart,
    super.onLoadEnd,
    super.style,
    super.testID,
    Map<String, dynamic>? additionalProps,
    this.animatedStyles,
    this.onAnimationStart,
    this.onAnimationComplete,
  }) : super(
          additionalProps: additionalProps ?? const {},
        );

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (animatedStyles != null) {
      map['animatedStyles'] = {};
      animatedStyles!.forEach((key, value) {
        map['animatedStyles']![key] = value.toMap();
      });
    }

    if (onAnimationStart != null) map['onAnimationStart'] = onAnimationStart;
    if (onAnimationComplete != null) {
      map['onAnimationComplete'] = onAnimationComplete;
    }

    return map;
  }
}

/// AnimatedImage component
class DCAnimatedImage extends Control {
  final DCAnimatedImageProps props;

  DCAnimatedImage({
    DCImageSource? source,
    DCImageSource? defaultSource,
    String? resizeMode,
    bool? loadingIndicatorEnabled,
    Function(Map<String, dynamic>)? onLoad,
    Function(Map<String, dynamic>)? onError,
    Function()? onLoadStart,
    Function()? onLoadEnd,
    DCImageStyle? style,
    String? testID,
    Map<String, dynamic>? additionalProps,
    Map<String, AnimatedValue>? animatedStyles,
    Function(Map<String, dynamic>)? onAnimationStart,
    Function(Map<String, dynamic>)? onAnimationComplete,
  }) : props = DCAnimatedImageProps(
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
          animatedStyles: animatedStyles,
          onAnimationStart: onAnimationStart,
          onAnimationComplete: onAnimationComplete,
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCAnimatedImage',
      props.toMap(),
      [],
    );
  }

  /// Create an image with fade animation
  static DCAnimatedImage fade({
    required DCImageSource source,
    required double opacity,
    required String animationId,
    DCImageStyle? style,
    String? resizeMode,
    double? duration,
    double? delay,
    String? easing,
    Function(Map<String, dynamic>)? onLoad,
    Function(Map<String, dynamic>)? onAnimationComplete,
  }) {
    return DCAnimatedImage(
      source: source,
      resizeMode: resizeMode ?? 'cover',
      style: style,
      onLoad: onLoad,
      animatedStyles: {
        'opacity': AnimatedValue(
          value: opacity,
          animationId: animationId,
          config: AnimationConfig(
            duration: duration ?? 300,
            delay: delay ?? 0,
            easing: easing ?? 'easeInOut',
          ),
        ),
      },
      onAnimationComplete: onAnimationComplete,
    );
  }
}
