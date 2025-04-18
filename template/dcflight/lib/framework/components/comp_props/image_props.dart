/// Properties specific to Image components
class ImageProps {
  /// Image source URL or asset path
  final String? source;

  /// Resize mode for the image (cover, contain, stretch, center)
  final String? resizeMode;

  /// Tint color for the image (for icons)
  final String? tintColor;

  /// Whether the image is currently loading
  final bool? loading;

  /// Create image component-specific props
  const ImageProps({
    this.source,
    this.resizeMode,
    this.tintColor,
    this.loading,
  });

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (source != null) map['source'] = source;
    if (resizeMode != null) map['resizeMode'] = resizeMode;
    if (tintColor != null) map['tintColor'] = tintColor;
    if (loading != null) map['loading'] = loading;

    return map;
  }

  /// Create new ImageProps by merging with another
  ImageProps merge(ImageProps other) {
    return ImageProps(
      source: other.source ?? source,
      resizeMode: other.resizeMode ?? resizeMode,
      tintColor: other.tintColor ?? tintColor,
      loading: other.loading ?? loading,
    );
  }

  /// Create a copy with certain properties modified
  ImageProps copyWith({
    String? source,
    String? resizeMode,
    String? tintColor,
    bool? loading,
  }) {
    return ImageProps(
      source: source ?? this.source,
      resizeMode: resizeMode ?? this.resizeMode,
      tintColor: tintColor ?? this.tintColor,
      loading: loading ?? this.loading,
    );
  }
}
