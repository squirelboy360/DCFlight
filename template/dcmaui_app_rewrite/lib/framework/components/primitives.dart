
/// Base component properties that all components can have
class BaseProps {
  final String? id;
  final String? testID;
  final bool? accessible;
  final String? accessibilityLabel;
  final Map<String, dynamic>? style; // For direct style overrides
  final bool? pointerEvents;

  // Layout properties
  final dynamic width; // Can be double, int, String (e.g., '100%')
  final dynamic height;
  final dynamic margin;
  final dynamic marginTop;
  final dynamic marginRight;
  final dynamic marginBottom;
  final dynamic marginLeft;
  final dynamic padding;
  final dynamic paddingTop;
  final dynamic paddingRight;
  final dynamic paddingBottom;
  final dynamic paddingLeft;

  // Flexbox properties
  final String?
      flexDirection; // 'column', 'row', 'column-reverse', 'row-reverse'
  final String?
      justifyContent; // 'flex-start', 'flex-end', 'center', 'space-between', 'space-around', 'space-evenly'
  final String?
      alignItems; // 'flex-start', 'flex-end', 'center', 'stretch', 'baseline'
  final String?
      alignSelf; // 'auto', 'flex-start', 'flex-end', 'center', 'stretch', 'baseline'
  final dynamic flex; // double or int
  final dynamic flexGrow; // double or int
  final dynamic flexShrink; // double or int
  final dynamic flexBasis; // double, int or String

  // Appearance properties
  final String? backgroundColor;
  final double? opacity;
  final double? borderRadius;
  final double? borderTopLeftRadius;
  final double? borderTopRightRadius;
  final double? borderBottomLeftRadius;
  final double? borderBottomRightRadius;
  final String? borderColor;
  final double? borderWidth;

  // Transform properties
  final Map<String, dynamic>? transform;

  // Shadow properties
  final String? shadowColor;
  final double? shadowOpacity;
  final double? shadowRadius;
  final Map<String, double>? shadowOffset;

  // Other visual properties
  final bool? overflow; // 'visible', 'hidden', 'scroll'
  final double? zIndex;
  final String? position; // 'relative', 'absolute'
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  const BaseProps({
    this.id,
    this.testID,
    this.accessible,
    this.accessibilityLabel,
    this.style,
    this.pointerEvents,
    this.width,
    this.height,
    this.margin,
    this.marginTop,
    this.marginRight,
    this.marginBottom,
    this.marginLeft,
    this.padding,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.paddingLeft,
    this.flexDirection,
    this.justifyContent,
    this.alignItems,
    this.alignSelf,
    this.flex,
    this.flexGrow,
    this.flexShrink,
    this.flexBasis,
    this.backgroundColor,
    this.opacity,
    this.borderRadius,
    this.borderTopLeftRadius,
    this.borderTopRightRadius,
    this.borderBottomLeftRadius,
    this.borderBottomRightRadius,
    this.borderColor,
    this.borderWidth,
    this.transform,
    this.shadowColor,
    this.shadowOpacity,
    this.shadowRadius,
    this.shadowOffset,
    this.overflow,
    this.zIndex,
    this.position,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  /// Convert properties to a map that can be passed to native
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (id != null) map['id'] = id;
    if (testID != null) map['testID'] = testID;
    if (accessible != null) map['accessible'] = accessible;
    if (accessibilityLabel != null)
      map['accessibilityLabel'] = accessibilityLabel;
    if (style != null) map.addAll(style!);
    if (pointerEvents != null) map['pointerEvents'] = pointerEvents;

    // Layout properties
    if (width != null) map['width'] = width;
    if (height != null) map['height'] = height;
    if (margin != null) map['margin'] = margin;
    if (marginTop != null) map['marginTop'] = marginTop;
    if (marginRight != null) map['marginRight'] = marginRight;
    if (marginBottom != null) map['marginBottom'] = marginBottom;
    if (marginLeft != null) map['marginLeft'] = marginLeft;
    if (padding != null) map['padding'] = padding;
    if (paddingTop != null) map['paddingTop'] = paddingTop;
    if (paddingRight != null) map['paddingRight'] = paddingRight;
    if (paddingBottom != null) map['paddingBottom'] = paddingBottom;
    if (paddingLeft != null) map['paddingLeft'] = paddingLeft;

    // Flexbox properties
    if (flexDirection != null) map['flexDirection'] = flexDirection;
    if (justifyContent != null) map['justifyContent'] = justifyContent;
    if (alignItems != null) map['alignItems'] = alignItems;
    if (alignSelf != null) map['alignSelf'] = alignSelf;
    if (flex != null) map['flex'] = flex;
    if (flexGrow != null) map['flexGrow'] = flexGrow;
    if (flexShrink != null) map['flexShrink'] = flexShrink;
    if (flexBasis != null) map['flexBasis'] = flexBasis;

    // Appearance properties
    if (backgroundColor != null) map['backgroundColor'] = backgroundColor;
    if (opacity != null) map['opacity'] = opacity;
    if (borderRadius != null) map['borderRadius'] = borderRadius;
    if (borderTopLeftRadius != null)
      map['borderTopLeftRadius'] = borderTopLeftRadius;
    if (borderTopRightRadius != null)
      map['borderTopRightRadius'] = borderTopRightRadius;
    if (borderBottomLeftRadius != null)
      map['borderBottomLeftRadius'] = borderBottomLeftRadius;
    if (borderBottomRightRadius != null)
      map['borderBottomRightRadius'] = borderBottomRightRadius;
    if (borderColor != null) map['borderColor'] = borderColor;
    if (borderWidth != null) map['borderWidth'] = borderWidth;

    // Transform properties
    if (transform != null) map['transform'] = transform;

    // Shadow properties
    if (shadowColor != null) map['shadowColor'] = shadowColor;
    if (shadowOpacity != null) map['shadowOpacity'] = shadowOpacity;
    if (shadowRadius != null) map['shadowRadius'] = shadowRadius;
    if (shadowOffset != null) map['shadowOffset'] = shadowOffset;

    // Other visual properties
    if (overflow != null) map['overflow'] = overflow;
    if (zIndex != null) map['zIndex'] = zIndex;
    if (position != null) map['position'] = position;
    if (top != null) map['top'] = top;
    if (right != null) map['right'] = right;
    if (bottom != null) map['bottom'] = bottom;
    if (left != null) map['left'] = left;

    return map;
  }
}

/// View component properties
class ViewProps extends BaseProps {
  const ViewProps({
    super.id,
    super.testID,
    super.accessible,
    super.accessibilityLabel,
    super.style,
    super.pointerEvents,
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
    super.flexDirection,
    super.justifyContent,
    super.alignItems,
    super.alignSelf,
    super.flex,
    super.flexGrow,
    super.flexShrink,
    super.flexBasis,
    super.backgroundColor,
    super.opacity,
    super.borderRadius,
    super.borderTopLeftRadius,
    super.borderTopRightRadius,
    super.borderBottomLeftRadius,
    super.borderBottomRightRadius,
    super.borderColor,
    super.borderWidth,
    super.transform,
    super.shadowColor,
    super.shadowOpacity,
    super.shadowRadius,
    super.shadowOffset,
    super.overflow,
    super.zIndex,
    super.position,
    super.top,
    super.right,
    super.bottom,
    super.left,
  });
}

/// Text component properties
class TextProps extends BaseProps {
  final String? fontFamily;
  final double? fontSize;
  final String? fontWeight; // 'normal', 'bold', '100'...'900'
  final String? fontStyle; // 'normal', 'italic'
  final double? letterSpacing;
  final double? lineHeight;
  final String? textAlign; // 'left', 'center', 'right', 'justify'
  final String? textDecorationLine; // 'none', 'underline', 'line-through'
  final String? textTransform; // 'none', 'uppercase', 'lowercase', 'capitalize'
  final String? color;
  final int? numberOfLines;
  final bool? selectable;
  final bool? adjustsFontSizeToFit;
  final double? minimumFontSize;

  const TextProps({
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.lineHeight,
    this.textAlign,
    this.textDecorationLine,
    this.textTransform,
    this.color,
    this.numberOfLines,
    this.selectable,
    this.adjustsFontSizeToFit,
    this.minimumFontSize,
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
    super.flexDirection,
    super.justifyContent,
    super.alignItems,
    super.alignSelf,
    super.flex,
    super.opacity,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (fontFamily != null) map['fontFamily'] = fontFamily;
    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight;
    if (fontStyle != null) map['fontStyle'] = fontStyle;
    if (letterSpacing != null) map['letterSpacing'] = letterSpacing;
    if (lineHeight != null) map['lineHeight'] = lineHeight;
    if (textAlign != null) map['textAlign'] = textAlign;
    if (textDecorationLine != null)
      map['textDecorationLine'] = textDecorationLine;
    if (textTransform != null) map['textTransform'] = textTransform;
    if (color != null) map['color'] = color;
    if (numberOfLines != null) map['numberOfLines'] = numberOfLines;
    if (selectable != null) map['selectable'] = selectable;
    if (adjustsFontSizeToFit != null)
      map['adjustsFontSizeToFit'] = adjustsFontSizeToFit;
    if (minimumFontSize != null) map['minimumFontSize'] = minimumFontSize;

    return map;
  }
}

/// Button component properties
class ButtonProps extends BaseProps {
  final String? title;
  final String? color; // Text color
  final double? fontSize;
  final String? fontWeight;
  final bool? disabled;
  final String? disabledColor;

  const ButtonProps({
    this.title,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.disabled,
    this.disabledColor,
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
    super.shadowColor,
    super.shadowOpacity,
    super.shadowRadius,
    super.shadowOffset,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (title != null) map['title'] = title;
    if (color != null) map['color'] = color;
    if (fontSize != null) map['fontSize'] = fontSize;
    if (fontWeight != null) map['fontWeight'] = fontWeight;
    if (disabled != null) map['disabled'] = disabled;
    if (disabledColor != null) map['disabledColor'] = disabledColor;

    return map;
  }
}

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
    if (loadingIndicatorSource != null)
      map['loadingIndicatorSource'] = loadingIndicatorSource;

    return map;
  }
}

/// ScrollView component properties
class ScrollViewProps extends BaseProps {
  final bool? showsVerticalScrollIndicator;
  final bool? showsHorizontalScrollIndicator;
  final bool? bounces;
  final bool? pagingEnabled;
  final String? scrollEventThrottle;
  final bool? directionalLockEnabled;
  final bool? alwaysBounceVertical;
  final bool? alwaysBounceHorizontal;

  const ScrollViewProps({
    this.showsVerticalScrollIndicator,
    this.showsHorizontalScrollIndicator,
    this.bounces,
    this.pagingEnabled,
    this.scrollEventThrottle,
    this.directionalLockEnabled,
    this.alwaysBounceVertical,
    this.alwaysBounceHorizontal,
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

    if (showsVerticalScrollIndicator != null)
      map['showsVerticalScrollIndicator'] = showsVerticalScrollIndicator;
    if (showsHorizontalScrollIndicator != null)
      map['showsHorizontalScrollIndicator'] = showsHorizontalScrollIndicator;
    if (bounces != null) map['bounces'] = bounces;
    if (pagingEnabled != null) map['pagingEnabled'] = pagingEnabled;
    if (scrollEventThrottle != null)
      map['scrollEventThrottle'] = scrollEventThrottle;
    if (directionalLockEnabled != null)
      map['directionalLockEnabled'] = directionalLockEnabled;
    if (alwaysBounceVertical != null)
      map['alwaysBounceVertical'] = alwaysBounceVertical;
    if (alwaysBounceHorizontal != null)
      map['alwaysBounceHorizontal'] = alwaysBounceHorizontal;

    return map;
  }
}
