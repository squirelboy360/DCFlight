import 'base_props.dart';

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

    return map;
  }
}
