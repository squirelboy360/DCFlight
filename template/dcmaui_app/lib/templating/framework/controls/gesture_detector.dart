import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

/// Props for DCGestureDetector component
class DCGestureDetectorProps implements ControlProps {
  // Tap handlers
  final Function()? onTap;
  final Function()? onDoubleTap;
  final Function()? onLongPress;

  // Pan (drag) handlers
  final Function(Map<String, dynamic>)? onPanStart;
  final Function(Map<String, dynamic>)? onPanUpdate;
  final Function(Map<String, dynamic>)? onPanEnd;

  // Pinch handlers
  final Function(Map<String, dynamic>)? onPinchStart;
  final Function(Map<String, dynamic>)? onPinchUpdate;
  final Function(Map<String, dynamic>)? onPinchEnd;

  // Rotation handlers
  final Function(Map<String, dynamic>)? onRotateStart;
  final Function(Map<String, dynamic>)? onRotateUpdate;
  final Function(Map<String, dynamic>)? onRotateEnd;

  // Touch events for direct handling
  final Function(Map<String, dynamic>)? onTouchStart;
  final Function(Map<String, dynamic>)? onTouchMove;
  final Function(Map<String, dynamic>)? onTouchEnd;
  final Function(Map<String, dynamic>)? onTouchCancel;

  // React Native responder system compatibility
  final Function(Map<String, dynamic>)? onStartShouldSetResponder;
  final Function(Map<String, dynamic>)? onMoveShouldSetResponder;

  // Configuration
  final double? touchMovementThreshold;
  final bool? enabled;
  final double? longPressDuration;

  const DCGestureDetectorProps({
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPinchStart,
    this.onPinchUpdate,
    this.onPinchEnd,
    this.onRotateStart,
    this.onRotateUpdate,
    this.onRotateEnd,
    this.onTouchStart,
    this.onTouchMove,
    this.onTouchEnd,
    this.onTouchCancel,
    this.onStartShouldSetResponder,
    this.onMoveShouldSetResponder,
    this.touchMovementThreshold,
    this.enabled,
    this.longPressDuration,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (onTap != null) map['onTap'] = onTap;
    if (onDoubleTap != null) map['onDoubleTap'] = onDoubleTap;
    if (onLongPress != null) map['onLongPress'] = onLongPress;

    if (onPanStart != null) map['onPanStart'] = onPanStart;
    if (onPanUpdate != null) map['onPanUpdate'] = onPanUpdate;
    if (onPanEnd != null) map['onPanEnd'] = onPanEnd;

    if (onPinchStart != null) map['onPinchStart'] = onPinchStart;
    if (onPinchUpdate != null) map['onPinchUpdate'] = onPinchUpdate;
    if (onPinchEnd != null) map['onPinchEnd'] = onPinchEnd;

    if (onRotateStart != null) map['onRotateStart'] = onRotateStart;
    if (onRotateUpdate != null) map['onRotateUpdate'] = onRotateUpdate;
    if (onRotateEnd != null) map['onRotateEnd'] = onRotateEnd;

    if (onTouchStart != null) map['onTouchStart'] = onTouchStart;
    if (onTouchMove != null) map['onTouchMove'] = onTouchMove;
    if (onTouchEnd != null) map['onTouchEnd'] = onTouchEnd;
    if (onTouchCancel != null) map['onTouchCancel'] = onTouchCancel;

    if (onStartShouldSetResponder != null) {
      map['onStartShouldSetResponder'] = onStartShouldSetResponder;
    }
    if (onMoveShouldSetResponder != null) {
      map['onMoveShouldSetResponder'] = onMoveShouldSetResponder;
    }

    if (touchMovementThreshold != null) {
      map['touchMovementThreshold'] = touchMovementThreshold;
    }
    if (enabled != null) map['enabled'] = enabled;
    if (longPressDuration != null) map['longPressDuration'] = longPressDuration;

    return map;
  }
}

/// Gesture detector component for handling various touch interactions
class DCGestureDetector extends Control {
  final DCGestureDetectorProps props;
  final List<Control> children;

  DCGestureDetector({
    required this.props,
    this.children = const [],
  });

  @override
  VNode build() {
    return ElementFactory.createElement(
      'DCGestureDetector',
      props.toMap(),
      buildChildren(children),
    );
  }

  /// Convenience factory for tap handling
  static DCGestureDetector withTap({
    required Function() onTap,
    List<Control> children = const [],
    bool? enabled,
  }) {
    return DCGestureDetector(
      props: DCGestureDetectorProps(
        onTap: onTap,
        enabled: enabled,
      ),
      children: children,
    );
  }

  /// Convenience factory for pan/drag handling
  static DCGestureDetector withPan({
    Function(Map<String, dynamic>)? onPanStart,
    Function(Map<String, dynamic>)? onPanUpdate,
    Function(Map<String, dynamic>)? onPanEnd,
    List<Control> children = const [],
    bool? enabled,
  }) {
    return DCGestureDetector(
      props: DCGestureDetectorProps(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        enabled: enabled,
      ),
      children: children,
    );
  }
}
