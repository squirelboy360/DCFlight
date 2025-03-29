import 'base_props.dart';

/// ScrollView component properties
class ScrollViewProps extends BaseProps {
  final bool? showsVerticalScrollIndicator;
  final bool? showsHorizontalScrollIndicator;
  final bool? bounces;
  final bool? pagingEnabled;
  final double? scrollEventThrottle;
  final bool? directionalLockEnabled;
  final bool? alwaysBounceVertical;
  final bool? alwaysBounceHorizontal;
  final bool? horizontal;

  const ScrollViewProps({
    this.showsVerticalScrollIndicator,
    this.showsHorizontalScrollIndicator,
    this.bounces,
    this.pagingEnabled,
    this.scrollEventThrottle,
    this.directionalLockEnabled,
    this.alwaysBounceVertical,
    this.alwaysBounceHorizontal,
    this.horizontal,
    super.id,
    super.testID,
    super.accessible,
    super.accessibilityLabel,
    super.style,

    // Layout properties
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
    super.flex,
    super.flexDirection,
    super.flexWrap,
    super.flexGrow,
    super.flexShrink,
    super.flexBasis,
    super.justifyContent,
    super.alignItems,
    super.alignContent,
    super.alignSelf,

    // Additional layout properties
    super.aspectRatio,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,

    // Styling properties
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

    // Positioning properties
    super.overflow,
    super.zIndex,
    super.position,
    super.top,
    super.right,
    super.bottom,
    super.left,
    super.start,
    super.end,
  });

  @override
  Map<String, dynamic> toMap() {
    final map = super.toMap();

    if (showsVerticalScrollIndicator != null) {
      map['showsVerticalScrollIndicator'] = showsVerticalScrollIndicator;
    }
    if (showsHorizontalScrollIndicator != null) {
      map['showsHorizontalScrollIndicator'] = showsHorizontalScrollIndicator;
    }
    if (bounces != null) map['bounces'] = bounces;
    if (pagingEnabled != null) map['pagingEnabled'] = pagingEnabled;
    if (scrollEventThrottle != null) {
      map['scrollEventThrottle'] = scrollEventThrottle;
    }
    if (directionalLockEnabled != null) {
      map['directionalLockEnabled'] = directionalLockEnabled;
    }
    if (alwaysBounceVertical != null) {
      map['alwaysBounceVertical'] = alwaysBounceVertical;
    }
    if (alwaysBounceHorizontal != null) {
      map['alwaysBounceHorizontal'] = alwaysBounceHorizontal;
    }
    if (horizontal != null) {
      map['horizontal'] = horizontal;
    }

    return map;
  }
}
