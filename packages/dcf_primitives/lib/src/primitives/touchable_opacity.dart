import 'package:dcflight/dcflight.dart';

/// A touchable component that changes opacity on press
VDomElement touchableOpacity({
  required List<VDomNode> children,
  double activeOpacity = 0.2,
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Function? onPress,
  Function? onPressIn,
  Function? onPressOut,
  Function? onLongPress,
  int longPressDelay = 500,
  bool disabled = false,
  Map<String, dynamic>? events,
}) {
  // Create an events map if callbacks are provided
  Map<String, dynamic> eventMap = events ?? {};
  
  if (onPress != null) {
    eventMap['onPress'] = onPress;
  }
  
  if (onPressIn != null) {
    eventMap['onPressIn'] = onPressIn;
  }
  
  if (onPressOut != null) {
    eventMap['onPressOut'] = onPressOut;
  }
  
  if (onLongPress != null) {
    eventMap['onLongPress'] = onLongPress;
  }
  
  return VDomElement(
    type: 'TouchableOpacity',
    props: {
      'activeOpacity': activeOpacity,
      'disabled': disabled,
      'longPressDelay': longPressDelay,
      ...layout.toMap(),
      ...style.toMap(),
    },
    children: children,
    events: eventMap.isEmpty ? null : eventMap,
  );
}
