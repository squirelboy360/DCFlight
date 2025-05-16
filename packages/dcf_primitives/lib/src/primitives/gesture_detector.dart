import 'package:dcflight/dcflight.dart';

/// Gesture Detector properties
class GestureProps {
  /// Whether the gesture detector is enabled
  final bool enabled;
  
  /// Minimum duration in milliseconds for long press
  final int longPressMinDuration;
  
  /// Whether to cancel touches on drag
  final bool cancelsTouchesInView;
  
  /// Create gesture props
  const GestureProps({
    this.enabled = true,
    this.longPressMinDuration = 500,
    this.cancelsTouchesInView = true,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'longPressMinDuration': longPressMinDuration,
      'cancelsTouchesInView': cancelsTouchesInView,
    };
  }
}

/// A component that detects various gestures on its children
VDomElement gestureDetector({
  required List<VDomNode> children,
  GestureProps gestureProps = const GestureProps(),
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Function? onTap,
  Function? onDoubleTap,
  Function? onLongPress,
  Function? onPressIn,
  Function? onPressOut,
  Function? onSwipeLeft,
  Function? onSwipeRight,
  Function? onSwipeUp,
  Function? onSwipeDown,
  Function? onPan,
  Function? onPanStart,
  Function? onPanEnd,
  Function? onPanUpdate,
  Map<String, dynamic>? events,
}) {
  // Create an events map if callbacks are provided
  Map<String, dynamic> eventMap = events ?? {};
  
  if (onTap != null) {
    eventMap['onTap'] = onTap;
  }
  
  if (onDoubleTap != null) {
    eventMap['onDoubleTap'] = onDoubleTap;
  }
  
  if (onLongPress != null) {
    eventMap['onLongPress'] = onLongPress;
  }
  
  if (onPressIn != null) {
    eventMap['onPressIn'] = onPressIn;
  }
  
  if (onPressOut != null) {
    eventMap['onPressOut'] = onPressOut;
  }
  
  if (onSwipeLeft != null) {
    eventMap['onSwipeLeft'] = onSwipeLeft;
  }
  
  if (onSwipeRight != null) {
    eventMap['onSwipeRight'] = onSwipeRight;
  }
  
  if (onSwipeUp != null) {
    eventMap['onSwipeUp'] = onSwipeUp;
  }
  
  if (onSwipeDown != null) {
    eventMap['onSwipeDown'] = onSwipeDown;
  }
  
  if (onPan != null) {
    eventMap['onPan'] = onPan;
  }
  
  if (onPanStart != null) {
    eventMap['onPanStart'] = onPanStart;
  }
  
  if (onPanEnd != null) {
    eventMap['onPanEnd'] = onPanEnd;
  }
  
  if (onPanUpdate != null) {
    eventMap['onPanUpdate'] = onPanUpdate;
  }
  
  return VDomElement(
    type: 'GestureDetector',
    props: {
      ...gestureProps.toMap(),
      ...layout.toMap(),
      ...style.toMap(),
      ...eventMap, // Add event handlers directly to props
    },
    children: children,
  );
}
