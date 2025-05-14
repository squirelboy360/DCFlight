import 'package:dcflight/dcflight.dart';
export 'package:dcf_primitives/src/primitives/dictionary/dcf_icons_dict.dart';
/// DCFIcon - Similar to React Native's Ionicons
/// Provides a simple way to use built-in icons by name
// / module or packages that want to add more icons can do so by cloning the dcfIcon and changing the package prop to the name of your package and dont't forget to clone the native side of dcfPrimitives
VDomElement dcfIcon({
  required String name,
  double size = 24.0,
  Color? color,
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Function? onLoad,
  Function? onError,
  Map<String, dynamic>? events,
}) {
  // Create an events map if callbacks are provided
  Map<String, dynamic> eventMap = events ?? {};

  if (onLoad != null) {
    eventMap['onLoad'] = onLoad;
  }

  if (onError != null) {
    eventMap['onError'] = onError;
  }

  return VDomElement(
    type: 'DCFIcon',
    props: {
      'name': name,
      'package': 'dcf_primitives',
      'size': size,
      if (color != null) 'color': color,
      ...layout.toMap(),
      ...style.toMap(),
      // non-direct svgs, where the icons are in packages like scf_icon for example are not relative as the native side will lookup the assets from the package being used in the app bundle
      'isRelativePath': false,
      ...eventMap,
    },
    children: [],
  );
}
