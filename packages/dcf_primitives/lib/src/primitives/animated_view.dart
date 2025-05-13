import 'package:dcflight/dcflight.dart';
import 'package:dcf_primitives/src/primitives/animated_view_definition.dart';

/// Animation properties
class AnimationProps {
  /// Duration of the animation in milliseconds
  final int duration;
  
  /// Easing curve for the animation
  final String curve;
  
  /// Delay before starting the animation in milliseconds
  final int delay;
  
  /// Whether to repeat the animation
  final bool repeat;
  
  /// Final scale of the view
  final double? toScale;
  
  /// Final opacity of the view
  final double? toOpacity;
  
  /// Final translation X value
  final double? toTranslateX;
  
  /// Final translation Y value
  final double? toTranslateY;
  
  /// Final rotation value in degrees
  final double? toRotate;
  
  /// Create animation props
  const AnimationProps({
    this.duration = 300,
    this.curve = 'linear',
    this.delay = 0,
    this.repeat = false,
    this.toScale,
    this.toOpacity,
    this.toTranslateX,
    this.toTranslateY,
    this.toRotate,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'animationDuration': duration,
      'animationCurve': curve,
      'animationDelay': delay,
      'animationRepeat': repeat,
      if (toScale != null) 'toScale': toScale,
      if (toOpacity != null) 'toOpacity': toOpacity,
      if (toTranslateX != null) 'toTranslateX': toTranslateX,
      if (toTranslateY != null) 'toTranslateY': toTranslateY,
      if (toRotate != null) 'toRotate': toRotate,
    };
  }
}

/// An animated view component
VDomElement animatedView({
  required List<VDomNode> children,
  AnimationProps animation = const AnimationProps(),
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Function? onAnimationStart,
  Function? onAnimationEnd,
  Function? onViewId,
  Map<String, dynamic>? events,
}) {
  // Create an events map if callbacks are provided
  Map<String, dynamic> eventMap = events ?? {};
  
  if (onAnimationStart != null) {
    eventMap['onAnimationStart'] = onAnimationStart;
  }
  
  if (onAnimationEnd != null) {
    eventMap['onAnimationEnd'] = onAnimationEnd;
  }
  
  if (onViewId != null) {
    eventMap['onViewId'] = onViewId;
  }
  
  return VDomElement(
    type: 'AnimatedView',
    props: {
      ...animation.toMap(),
      ...layout.toMap(),
      ...style.toMap(),
    },
    children: children,
    events: eventMap.isEmpty ? null : eventMap,
  );
}

/// Utility class for calling methods on AnimatedView components
class AnimatedViewMethods {
  /// Trigger animation programmatically
  static Future<void> animate(String viewId, {
    int? duration,
    String? curve,
    double? toScale,
    double? toOpacity,
    double? toTranslateX,
    double? toTranslateY,
    double? toRotate,
  }) async {
    await DCFAnimatedViewDefinition().callMethod(
      viewId,
      'animate',
      {
        if (duration != null) 'duration': duration,
        if (curve != null) 'curve': curve,
        if (toScale != null) 'toScale': toScale,
        if (toOpacity != null) 'toOpacity': toOpacity,
        if (toTranslateX != null) 'toTranslateX': toTranslateX,
        if (toTranslateY != null) 'toTranslateY': toTranslateY,
        if (toRotate != null) 'toRotate': toRotate,
      },
    );
  }
  
  /// Reset animation to initial state
  static Future<void> reset(String viewId) async {
    await DCFAnimatedViewDefinition().callMethod(
      viewId,
      'reset',
      {},
    );
  }
}
