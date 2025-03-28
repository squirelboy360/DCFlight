import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/controls/animated_view.dart';
import 'package:dc_test/templating/framework/controls/text.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/widgets.dart';

// Define the missing TextDecorationLineType enum
enum DCTextDecorationLineType {
  none,
  underline,
  lineThrough,
  underlineLineThrough,
}

/// Props for AnimatedText component
class DCAnimatedTextProps extends DCTextProps {
  final Map<String, AnimatedValue>? animatedStyles;
  final Function(Map<String, dynamic>)? onAnimationStart;
  final Function(Map<String, dynamic>)? onAnimationComplete;

  DCAnimatedTextProps({
    super.text,
    super.style,
    super.numberOfLines,
    TextAlign? textAlign,
    super.selectable,
    Color? selectionColor,
    DCTextDecorationLineType? textDecorationLine,
    super.adjustsFontSizeToFit,
    super.minimumFontScale,
    Function(Map<String, dynamic>)? onPress,
    super.testID,
    Map<String, dynamic>? additionalProps,
    this.animatedStyles,
    this.onAnimationStart,
    this.onAnimationComplete,
  }) : super(
          additionalProps: additionalProps ?? {},
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

/// AnimatedText component
class DCAnimatedText extends Control {
  final DCAnimatedTextProps props;

  DCAnimatedText({
    String? text,
    DCTextStyle? style,
    int? numberOfLines,
    TextAlign? textAlign,
    bool? selectable,
    Color? selectionColor,
    DCTextDecorationLineType? textDecorationLine,
    bool? adjustsFontSizeToFit,
    double? minimumFontScale,
    Function(Map<String, dynamic>)? onPress,
    String? testID,
    Map<String, dynamic>? additionalProps,
    Map<String, AnimatedValue>? animatedStyles,
    Function(Map<String, dynamic>)? onAnimationStart,
    Function(Map<String, dynamic>)? onAnimationComplete,
  }) : props = DCAnimatedTextProps(
          text: text,
          style: style,
          numberOfLines: numberOfLines,
          selectable: selectable,
          adjustsFontSizeToFit: adjustsFontSizeToFit,
          minimumFontScale: minimumFontScale,
          testID: testID,
          additionalProps: additionalProps ?? const {},
          animatedStyles: animatedStyles,
          onAnimationStart: onAnimationStart,
          onAnimationComplete: onAnimationComplete,
        );

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCAnimatedText',
      props.toMap(),
      [],
    );
  }

  /// Create a text with fade animation
  static DCAnimatedText fade({
    required String text,
    required double opacity,
    required String animationId,
    DCTextStyle? style,
    double? duration,
    double? delay,
    String? easing,
    Function(Map<String, dynamic>)? onAnimationComplete,
  }) {
    return DCAnimatedText(
      text: text,
      style: style,
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
