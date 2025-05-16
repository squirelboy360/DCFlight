import 'package:dcflight/dcflight.dart';

/// A component that displays SVG images from assets
VDomElement svg({
  required String asset, 
  double? width,
  double? height,
  Color? tintColor,
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
    type: 'Svg',
    props: {
      'asset': asset,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (tintColor != null) 'tintColor': tintColor,
      ...layout.toMap(),
      ...style.toMap(),
      // direct svgs are relative as the native side will lookup the assets from the app bundle 
      'isRelativePath': true,
        ...eventMap,
    },
    children: [],
  
  );
}