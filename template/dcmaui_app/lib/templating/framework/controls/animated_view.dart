import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/view.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

/// Animation configuration
class AnimationConfig {
  final double? duration;
  final double? delay;
  final String? easing;

  const AnimationConfig({
    this.duration,
    this.delay,
    this.easing,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (duration != null) map['duration'] = duration;
    if (delay != null) map['delay'] = delay;
    if (easing != null) map['easing'] = easing;

    return map;
  }
}

/// Animated value
class AnimatedValue {
  final double value;
  final String animationId;
  final AnimationConfig? config;

  const AnimatedValue({
    required this.value,
    required this.animationId,
    this.config,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'animatedValue': value,
      'animationId': animationId,
    };

    if (config != null) map['config'] = config!.toMap();

    return map;
  }
}

/// Props for AnimatedView component
class DCAnimatedViewProps implements ControlProps {
  final Map<String, AnimatedValue>? animatedStyles;
  final Function(Map<String, dynamic>)? onAnimationStart;
  final Function(Map<String, dynamic>)? onAnimationComplete;
  final ViewStyle? style;
  final Map<String, dynamic> additionalProps;

  const DCAnimatedViewProps({
    this.animatedStyles,
    this.onAnimationStart,
    this.onAnimationComplete,
    this.style,
    this.additionalProps = const {},
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      ...additionalProps,
    };

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
    if (style != null) map['style'] = style!.toMap();

    return map;
  }
}

/// AnimatedView component
class DCAnimatedView extends Control {
  final DCAnimatedViewProps props;
  final List<Control> children;

  DCAnimatedView({
    Map<String, AnimatedValue>? animatedStyles,
    Function(Map<String, dynamic>)? onAnimationStart,
    Function(Map<String, dynamic>)? onAnimationComplete,
    ViewStyle? style,
    Map<String, dynamic>? additionalProps,
    this.children = const [],
  }) : props = DCAnimatedViewProps(
          animatedStyles: animatedStyles,
          onAnimationStart: onAnimationStart,
          onAnimationComplete: onAnimationComplete,
          style: style,
          additionalProps: additionalProps ?? const {},
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCAnimatedView',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Create a fade animation
  static DCAnimatedView fade({
    required double opacity,
    required String animationId,
    required List<Control> children,
    double? duration,
    double? delay,
    String? easing,
    ViewStyle? style,
    Function(Map<String, dynamic>)? onAnimationComplete,
  }) {
    return DCAnimatedView(
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
      style: style,
      onAnimationComplete: onAnimationComplete,
      children: children,
    );
  }

  /// Create a translation animation
  static DCAnimatedView translate({
    required double translateX,
    required double translateY,
    required String animationId,
    required List<Control> children,
    double? duration,
    double? delay,
    String? easing,
    ViewStyle? style,
    Function(Map<String, dynamic>)? onAnimationComplete,
  }) {
    return DCAnimatedView(
      animatedStyles: {
        'translateX': AnimatedValue(
          value: translateX,
          animationId: animationId,
          config: AnimationConfig(
            duration: duration ?? 300,
            delay: delay ?? 0,
            easing: easing ?? 'easeInOut',
          ),
        ),
        'translateY': AnimatedValue(
          value: translateY,
          animationId: animationId,
          config: AnimationConfig(
            duration: duration ?? 300,
            delay: delay ?? 0,
            easing: easing ?? 'easeInOut',
          ),
        ),
      },
      style: style,
      onAnimationComplete: onAnimationComplete,
      children: children,
    );
  }

  /// Create a scale animation
  static DCAnimatedView scale({
    required double scale,
    required String animationId,
    required List<Control> children,
    double? duration,
    double? delay,
    String? easing,
    ViewStyle? style,
    Function(Map<String, dynamic>)? onAnimationComplete,
  }) {
    return DCAnimatedView(
      animatedStyles: {
        'scale': AnimatedValue(
          value: scale,
          animationId: animationId,
          config: AnimationConfig(
            duration: duration ?? 300,
            delay: delay ?? 0,
            easing: easing ?? 'easeInOut',
          ),
        ),
      },
      style: style,
      onAnimationComplete: onAnimationComplete,
      children: children,
    );
  }
}
