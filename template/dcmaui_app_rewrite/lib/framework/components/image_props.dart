import 'base_props.dart';

/// Image component properties
class ImageProps extends BaseProps {
  final String? source;
  final String? resizeMode; // 'cover', 'contain', 'stretch', 'repeat', 'center'
  final double? aspectRatio;
  final bool? fadeDuration;
  final String? defaultSource;
  final bool? loadingIndicatorSource;

  const ImageProps({
    this.source,
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

    if (source != null) map['source'] = source;
    if (resizeMode != null) map['resizeMode'] = resizeMode;
    if (aspectRatio != null) map['aspectRatio'] = aspectRatio;
    if (fadeDuration != null) map['fadeDuration'] = fadeDuration;
    if (defaultSource != null) map['defaultSource'] = defaultSource;
    if (loadingIndicatorSource != null) {
      map['loadingIndicatorSource'] = loadingIndicatorSource;
    }

    return map;
  }
}
