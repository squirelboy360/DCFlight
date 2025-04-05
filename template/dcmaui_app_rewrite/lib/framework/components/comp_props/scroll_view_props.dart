/// Properties specific to ScrollView components
class ScrollViewProps {
  /// Whether the scroll view scrolls horizontally
  final bool? horizontal;

  /// Content width for the scroll view
  final double? contentWidth;

  /// Content height for the scroll view
  final double? contentHeight;

  /// Whether to show horizontal scroll indicator
  final bool? showsHorizontalScrollIndicator;

  /// Whether to show vertical scroll indicator
  final bool? showsVerticalScrollIndicator;

  /// Whether the scroll view bounces when it reaches the end
  final bool? bounces;

  /// Whether paging is enabled
  final bool? pagingEnabled;

  /// Throttle interval for scroll events in ms
  final double? scrollEventThrottle;

  /// Content inset for top edge
  final double? contentInsetTop;

  /// Content inset for bottom edge
  final double? contentInsetBottom;

  /// Content inset for left edge
  final double? contentInsetLeft;

  /// Content inset for right edge
  final double? contentInsetRight;

  /// Whether scrolling is enabled
  final bool? scrollEnabled;

  /// Create scroll view component-specific props
  const ScrollViewProps({
    this.horizontal,
    this.contentWidth,
    this.contentHeight,
    this.showsHorizontalScrollIndicator,
    this.showsVerticalScrollIndicator,
    this.bounces,
    this.pagingEnabled,
    this.scrollEventThrottle,
    this.contentInsetTop,
    this.contentInsetBottom,
    this.contentInsetLeft,
    this.contentInsetRight,
    this.scrollEnabled,
  });

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    if (horizontal != null) map['horizontal'] = horizontal;
    if (contentWidth != null) map['contentWidth'] = contentWidth;
    if (contentHeight != null) map['contentHeight'] = contentHeight;
    if (showsHorizontalScrollIndicator != null)
      map['showsHorizontalScrollIndicator'] = showsHorizontalScrollIndicator;
    if (showsVerticalScrollIndicator != null)
      map['showsVerticalScrollIndicator'] = showsVerticalScrollIndicator;
    if (bounces != null) map['bounces'] = bounces;
    if (pagingEnabled != null) map['pagingEnabled'] = pagingEnabled;
    if (scrollEventThrottle != null)
      map['scrollEventThrottle'] = scrollEventThrottle;
    if (contentInsetTop != null) map['contentInsetTop'] = contentInsetTop;
    if (contentInsetBottom != null)
      map['contentInsetBottom'] = contentInsetBottom;
    if (contentInsetLeft != null) map['contentInsetLeft'] = contentInsetLeft;
    if (contentInsetRight != null) map['contentInsetRight'] = contentInsetRight;
    if (scrollEnabled != null) map['scrollEnabled'] = scrollEnabled;

    return map;
  }

  /// Create new ScrollViewProps by merging with another
  ScrollViewProps merge(ScrollViewProps other) {
    return ScrollViewProps(
      horizontal: other.horizontal ?? horizontal,
      contentWidth: other.contentWidth ?? contentWidth,
      contentHeight: other.contentHeight ?? contentHeight,
      showsHorizontalScrollIndicator: other.showsHorizontalScrollIndicator ??
          showsHorizontalScrollIndicator,
      showsVerticalScrollIndicator:
          other.showsVerticalScrollIndicator ?? showsVerticalScrollIndicator,
      bounces: other.bounces ?? bounces,
      pagingEnabled: other.pagingEnabled ?? pagingEnabled,
      scrollEventThrottle: other.scrollEventThrottle ?? scrollEventThrottle,
      contentInsetTop: other.contentInsetTop ?? contentInsetTop,
      contentInsetBottom: other.contentInsetBottom ?? contentInsetBottom,
      contentInsetLeft: other.contentInsetLeft ?? contentInsetLeft,
      contentInsetRight: other.contentInsetRight ?? contentInsetRight,
      scrollEnabled: other.scrollEnabled ?? scrollEnabled,
    );
  }

  /// Create a copy with certain properties modified
  ScrollViewProps copyWith({
    bool? horizontal,
    double? contentWidth,
    double? contentHeight,
    bool? showsHorizontalScrollIndicator,
    bool? showsVerticalScrollIndicator,
    bool? bounces,
    bool? pagingEnabled,
    double? scrollEventThrottle,
    double? contentInsetTop,
    double? contentInsetBottom,
    double? contentInsetLeft,
    double? contentInsetRight,
    bool? scrollEnabled,
  }) {
    return ScrollViewProps(
      horizontal: horizontal ?? this.horizontal,
      contentWidth: contentWidth ?? this.contentWidth,
      contentHeight: contentHeight ?? this.contentHeight,
      showsHorizontalScrollIndicator:
          showsHorizontalScrollIndicator ?? this.showsHorizontalScrollIndicator,
      showsVerticalScrollIndicator:
          showsVerticalScrollIndicator ?? this.showsVerticalScrollIndicator,
      bounces: bounces ?? this.bounces,
      pagingEnabled: pagingEnabled ?? this.pagingEnabled,
      scrollEventThrottle: scrollEventThrottle ?? this.scrollEventThrottle,
      contentInsetTop: contentInsetTop ?? this.contentInsetTop,
      contentInsetBottom: contentInsetBottom ?? this.contentInsetBottom,
      contentInsetLeft: contentInsetLeft ?? this.contentInsetLeft,
      contentInsetRight: contentInsetRight ?? this.contentInsetRight,
      scrollEnabled: scrollEnabled ?? this.scrollEnabled,
    );
  }
}
