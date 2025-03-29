import 'base_props.dart';

/// Image resize mode options
enum ResizeMode {
  cover,
  contain,
  stretch,
  repeat,
  center;

  String get value {
    switch (this) {
      case ResizeMode.cover:
        return 'cover';
      case ResizeMode.contain:
        return 'contain';
      case ResizeMode.stretch:
        return 'stretch';
      case ResizeMode.repeat:
        return 'repeat';
      case ResizeMode.center:
        return 'center';
    }
  }
}

/// Image component properties
class ImageProps extends BaseProps {
  final String source;
  final ResizeMode? resizeMode;
  final double? aspectRatio;
  final bool? fadeDuration;
  final String? defaultSource;
  final bool? loadingIndicatorSource;

  const ImageProps({
    required this.source,
    this.resizeMode,
    this.aspectRatio,
    this.fadeDuration,
    this.defaultSource,
    this.loadingIndicatorSource,
    super.id,
    super.testID,
    super.accessible,
    super.accessibilityLabel,
    super.style,
    super.width,
    super.height,
    super.margin,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.marginLeft,
    super.padding,
    super.paddingTop,
    super.paddingRight,
    super.paddingBottom,
    super.paddingLeft,
    super.backgroundColor,
    super.opacity,
    super.borderRadius,
    super.borderColor,
    super.borderWidth,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    map['source'] = source;
    if (resizeMode != null) map['resizeMode'] = resizeMode?.value;
    if (aspectRatio != null) map['aspectRatio'] = aspectRatio;
    if (fadeDuration != null) map['fadeDuration'] = fadeDuration;
    if (defaultSource != null) map['defaultSource'] = defaultSource;
    if (loadingIndicatorSource != null) {
      map['loadingIndicatorSource'] = loadingIndicatorSource;
    }

    return map;
  }
}
