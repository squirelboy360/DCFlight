import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';
import 'package:dcf_primitives/src/primitives/animated_text_definition.dart';

/// Animation properties specific to text
class TextAnimationProps {
  /// Duration of the animation in milliseconds
  final int duration;
  
  /// Easing curve for the animation
  final String curve;
  
  /// Delay before starting the animation in milliseconds
  final int delay;
  
  /// Whether to repeat the animation
  final bool repeat;
  
  /// Final scale of the text
  final double? toScale;
  
  /// Final opacity of the text
  final double? toOpacity;
  
  /// Final translation X value
  final double? toTranslateX;
  
  /// Final translation Y value
  final double? toTranslateY;
  
  /// Create text animation props
  const TextAnimationProps({
    this.duration = 300,
    this.curve = 'linear',
    this.delay = 0,
    this.repeat = false,
    this.toScale,
    this.toOpacity,
    this.toTranslateX,
    this.toTranslateY,
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
    };
  }
}

/// An animated text component
VDomElement animatedText({
  required String content,
  TextProps textProps = const TextProps(),
  TextAnimationProps animation = const TextAnimationProps(),
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
    type: 'AnimatedText',
    props: {
      'content': content,
      ...textProps.toMap(),
      ...animation.toMap(),
      ...layout.toMap(),
      ...style.toMap(),
    },
    children: [],
    events: eventMap.isEmpty ? null : eventMap,
  );
}

/// Utility class for calling methods on AnimatedText components
class AnimatedTextMethods {
  /// Set text with animation
  static Future<void> setText(String viewId, String text, {
    int? duration,
    String? curve,
  }) async {
    await DCFAnimatedTextDefinition().callMethod(
      viewId,
      'setText',
      {
        'text': text,
        if (duration != null) 'duration': duration,
        if (curve != null) 'curve': curve,
      },
    );
  }
  
  /// Trigger animation programmatically
  static Future<void> animate(String viewId, {
    int? duration,
    String? curve,
    double? toScale,
    double? toOpacity,
    double? toTranslateX,
    double? toTranslateY,
  }) async {
    await DCFAnimatedTextDefinition().callMethod(
      viewId,
      'animate',
      {
        if (duration != null) 'duration': duration,
        if (curve != null) 'curve': curve,
        if (toScale != null) 'toScale': toScale,
        if (toOpacity != null) 'toOpacity': toOpacity,
        if (toTranslateX != null) 'toTranslateX': toTranslateX,
        if (toTranslateY != null) 'toTranslateY': toTranslateY,
      },
    );
  }
}
