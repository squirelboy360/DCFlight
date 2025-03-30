import 'view_props.dart';
import '../constants/layout_properties.dart';

/// Scroll view component properties
class ScrollViewProps extends ViewProps {
  final bool? horizontal;
  final bool? showsHorizontalScrollIndicator;
  final bool? showsVerticalScrollIndicator;
  final bool? pagingEnabled;
  final bool? bounces;
  final double? contentInsetTop;
  final double? contentInsetBottom;
  final double? contentInsetLeft;
  final double? contentInsetRight;
  final bool? scrollEnabled;
  final double? scrollEventThrottle;
  final bool? directionalLockEnabled;
  final double? snapToInterval;
  final bool? snapToAlignment;

  const ScrollViewProps({
    this.horizontal,
    this.showsHorizontalScrollIndicator,
    this.showsVerticalScrollIndicator,
    this.pagingEnabled,
    this.bounces,
    this.contentInsetTop,
    this.contentInsetBottom,
    this.contentInsetLeft,
    this.contentInsetRight,
    this.scrollEnabled,
    this.scrollEventThrottle,
    this.directionalLockEnabled,
    this.snapToInterval,
    this.snapToAlignment,

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

    // Add ScrollView-specific properties
    if (horizontal != null) map['horizontal'] = horizontal;
    if (showsHorizontalScrollIndicator != null) {
      map['showsHorizontalScrollIndicator'] = showsHorizontalScrollIndicator;
    }
    if (showsVerticalScrollIndicator != null) {
      map['showsVerticalScrollIndicator'] = showsVerticalScrollIndicator;
    }
    if (pagingEnabled != null) map['pagingEnabled'] = pagingEnabled;
    if (bounces != null) map['bounces'] = bounces;
    if (contentInsetTop != null) map['contentInsetTop'] = contentInsetTop;
    if (contentInsetBottom != null) {
      map['contentInsetBottom'] = contentInsetBottom;
    }
    if (contentInsetLeft != null) map['contentInsetLeft'] = contentInsetLeft;
    if (contentInsetRight != null) {
      map['contentInsetRight'] = contentInsetRight;
    }
    if (scrollEnabled != null) map['scrollEnabled'] = scrollEnabled;
    if (scrollEventThrottle != null) {
      map['scrollEventThrottle'] = scrollEventThrottle;
    }
    if (directionalLockEnabled != null) {
      map['directionalLockEnabled'] = directionalLockEnabled;
    }
    if (snapToInterval != null) map['snapToInterval'] = snapToInterval;
    if (snapToAlignment != null) map['snapToAlignment'] = snapToAlignment;

    return map;
  }
}
