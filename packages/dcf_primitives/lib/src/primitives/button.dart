import 'package:dcflight/dcflight.dart';

/// Button properties
class ButtonProps {
  /// The title text of the button
  final String title;
  
  /// Title color of the button
  final Color? color;
  
  /// Button's background color
  final Color? backgroundColor;
  
  /// Disabled state
  final bool disabled;
  
  /// Create button props
  const ButtonProps({
    required this.title,
    this.color,
    this.backgroundColor,
    this.disabled = false,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      if (color != null) 'color': color,
      if (backgroundColor != null) 'backgroundColor': backgroundColor,
      'disabled': disabled,
    };
  }
}

/// A button component
VDomElement button({
  required ButtonProps buttonProps,
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Function? onPress,
  Map<String, dynamic>? events,
}) {
  // Create an events map if onPress is provided and events is not
  Map<String, dynamic> eventMap = events ?? {};
  
  if (onPress != null) {
    eventMap['onPress'] = onPress;
  }
  
  return VDomElement(
    type: 'Button',
    props: {
      ...buttonProps.toMap(),
      ...layout.toMap(),
      ...style.toMap(),
      ...eventMap, // Add event handlers directly to props
    },
    children: [],
  );
}

/// Create a button with just a title
VDomElement simpleButton({
  required String title,
  Color color = Colors.white,
  Color backgroundColor = Colors.blue,
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Function? onPress,
  Map<String, dynamic>? events,
}) {
  return button(
    buttonProps: ButtonProps(
      title: title,
      color: color,
      backgroundColor: backgroundColor
    ),
    layout: layout,
    style: style,
    onPress: onPress,
    events: events,
  );
}