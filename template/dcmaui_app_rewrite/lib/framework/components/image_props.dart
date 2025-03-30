import 'dart:ui' show Color;

import 'view_props.dart';
import '../constants/layout_enums.dart';
import '../constants/layout_properties.dart';

/// Resize mode for images
enum ResizeMode {
  cover('cover'),
  contain('contain'),
  stretch('stretch'),
  center('center');

  final String value;
  const ResizeMode(this.value);
}

/// Image component properties
class ImageProps extends ViewProps {
  final String? source;
  final ResizeMode? resizeMode;
  final bool? cache;
  final String? placeholder;
  @override
  final double? aspectRatio;

  const ImageProps({
    this.source,
    this.resizeMode,
    this.cache,
    this.placeholder,
    this.aspectRatio,

    // View props
    super.overflow,
    super.pointerEvents,
    super.borderRadius,
    super.borderTopLeftRadius,
    super.borderTopRightRadius,
    super.borderBottomLeftRadius,
    super.borderBottomRightRadius,
    super.borderColor,
    super.borderWidth,
    super.backgroundColor,
    super.opacity,
    super.shadowColor,
    super.shadowOpacity,
    super.shadowRadius,
    super.shadowOffsetX,
    super.shadowOffsetY,
    super.elevation,
    super.hitSlop,
    super.transform,

    // Base props
    super.id,
    super.testID,
    super.accessible,
    super.accessibilityLabel,
    super.style,

    // Layout properties using layout property constants
    super.width,
    super.height,
    super.margin,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.marginLeft,
    super.marginHorizontal,
    super.marginVertical,
    super.padding,
    super.paddingTop,
    super.paddingRight,
    super.paddingBottom,
    super.paddingLeft,
    super.paddingHorizontal,
    super.paddingVertical,

    // Flexbox properties
    super.flexDirection,
    super.flexWrap,
    super.justifyContent,
    super.alignItems,
    super.alignContent,
    super.alignSelf,
    super.flex,
    super.flexGrow,
    super.flexShrink,
    super.flexBasis,

    // Position properties
    super.position,
    super.zIndex,
    super.top,
    super.right,
    super.bottom,
    super.left,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    // Add image-specific properties
    if (source != null) map['source'] = source;
    if (resizeMode != null) map['resizeMode'] = resizeMode!.value;
    if (cache != null) map['cache'] = cache;
    if (placeholder != null) map['placeholder'] = placeholder;

    // No need to explicitly set aspectRatio here as it's handled by BaseProps

    return map;
  }
}
