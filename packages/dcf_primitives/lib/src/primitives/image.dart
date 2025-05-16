import 'package:dcflight/dcflight.dart';
/// Image properties
class ImageProps {
  /// The image source URI (can be a network URL or local resource)
  final String source;
  
  /// Resize mode for the image
  final String? resizeMode;
  
  /// Whether to fade in the image when loaded
  final bool? fadeDuration;
  
  /// Placeholder image to show while loading
  final String? placeholder;
  
  
  /// Create image props
  const ImageProps({
    required this.source,
    this.resizeMode,
    this.fadeDuration,
    this.placeholder,

  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'source': source,
      'isRelativePath': false,
      if (resizeMode != null) 'resizeMode': resizeMode,
      if (fadeDuration != null) 'fadeDuration': fadeDuration,
      if (placeholder != null) 'placeholder': placeholder,
    };
  }
}

/// A component that displays images
VDomElement image({
  required ImageProps imageProps,
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
    type: 'Image',
    props: {
      ...imageProps.toMap(),
      ...layout.toMap(),
      ...style.toMap(),
      ...eventMap, // Add event handlers directly to props
    },
    children: [],
  );
}

/// Create an image with just a source URL
VDomElement networkImage({
  required String url,
  String resizeMode = 'cover',
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Function? onLoad,
  Function? onError,
  Map<String, dynamic>? events,
}) {
  return image(
    imageProps: ImageProps(
      source: url,
      resizeMode: resizeMode,

    ),
    layout: layout,
    style: style,
    onLoad: onLoad,
    onError: onError,
    events: events,
  );
}

/// Create an image from a local asset
VDomElement assetImage({
  required String asset,
  String resizeMode = 'contain',
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Function? onLoad,
  Function? onError,
  Map<String, dynamic>? events,
}) {
  return image(
    imageProps: ImageProps(
      source: asset,
      resizeMode: resizeMode,
    
    ),
    layout: layout,
    style: style,
    onLoad: onLoad,
    onError: onError,
    events: events,
  );
}