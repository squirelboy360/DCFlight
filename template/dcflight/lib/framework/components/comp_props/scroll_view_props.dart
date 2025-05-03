import '../refs/scrollview_ref.dart';

/// Properties specific to ScrollView components
class ScrollViewProps {
  /// Reference to control the ScrollView imperatively
  final ScrollViewRef? ref;

  /// Whether the scroll view scrolls horizontally
  final bool? horizontal;

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
  
  // === Serious Native Style ScrollView Props ===

  /// When true, the scroll view bounces horizontally when it reaches the end
  final bool? alwaysBounceHorizontal;
  
  /// When true, the scroll view bounces vertically when it reaches the end
  final bool? alwaysBounceVertical;
  
  /// Controls whether iOS should automatically adjust the content inset
  final bool? automaticallyAdjustContentInsets;
  
  /// Controls whether the ScrollView should adjust for keyboard
  final bool? automaticallyAdjustKeyboardInsets;
  
  /// Controls iOS scroll indicator inset adjustments
  final bool? automaticallyAdjustsScrollIndicatorInsets;
  
  /// When true, gestures can drive zoom past min/max values
  final bool? bouncesZoom;
  
  /// Whether to cancel content touches when dragging starts
  final bool? canCancelContentTouches;
  
  /// Auto-centers content smaller than the ScrollView
  final bool? centerContent;
  
  /// Full content inset object as a map
  final Map<String, double>? contentInset;
  
  /// How safe area insets modify the content area
  /// Values: 'automatic', 'scrollableAxes', 'never', 'always'
  final String? contentInsetAdjustmentBehavior;
  
  /// Starting scroll position
  final Map<String, double>? contentOffset;
  
  /// How quickly scroll view decelerates after user lifts finger
  /// Values: 'normal', 'fast', or a custom number
  final dynamic decelerationRate;
  
  /// Lock scrolling to one direction at a time
  final bool? directionalLockEnabled;
  
  /// Stop on next index regardless of gesture speed
  final bool? disableIntervalMomentum;
  
  /// Disables default pan responder
  final bool? disableScrollViewPanResponder;
  
  /// Android fill color for empty space
  final String? endFillColor;
  
  /// Android edge fade length
  final double? fadingEdgeLength;
  
  /// Style of scroll indicators (iOS)
  /// Values: 'default', 'black', 'white'
  final String? indicatorStyle;
  
  /// Stick headers at bottom instead of top
  final bool? invertStickyHeaders;
  
  /// Keyboard dismiss behavior
  /// Values: 'none', 'on-drag', 'interactive' (iOS only)
  final String? keyboardDismissMode;
  
  /// Keyboard persistence after taps
  /// Values: 'always', 'never', 'handled'
  final String? keyboardShouldPersistTaps;
  
  /// Maximum zoom scale (iOS)
  final double? maximumZoomScale;
  
  /// Minimum zoom scale (iOS)
  final double? minimumZoomScale;
  
  /// Enable nested scrolling (Android)
  final bool? nestedScrollEnabled;
  
  /// Android overscroll mode
  /// Values: 'auto', 'always', 'never'
  final String? overScrollMode;
  
  /// Make scrollbars always visible (Android)
  final bool? persistentScrollbar;
  
  /// Allow pinch gestures to zoom (iOS)
  final bool? pinchGestureEnabled;
  
  /// Remove clipped subviews when offscreen
  final bool? removeClippedSubviews;
  
  /// Scroll indicator insets
  final Map<String, double>? scrollIndicatorInsets;
  
  /// Android scroll performance tag
  final String? scrollPerfTag;
  
  /// Allow programmatic scrolling beyond content (iOS)
  final bool? scrollToOverflowEnabled;
  
  /// Scroll to top on status bar tap (iOS)
  final bool? scrollsToTop;
  
  /// Snap alignment when using snapToInterval
  /// Values: 'start', 'center', 'end'
  final String? snapToAlignment;
  
  /// Disable snapping to end of list
  final bool? snapToEnd;
  
  /// Stop at multiples of this value when scrolling
  final double? snapToInterval;
  
  /// Custom snap offsets for variable sized children
  final List<double>? snapToOffsets;
  
  /// Disable snapping to start of list
  final bool? snapToStart;
  
  /// Hide sticky header when scrolling down
  final bool? stickyHeaderHiddenOnScroll;
  
  /// Indices of children to stick to top when scrolling
  final List<int>? stickyHeaderIndices;
  
  /// Current zoom scale (iOS)
  final double? zoomScale;
  
  /// Content container style
  final Map<String, dynamic>? contentContainerStyle;

  // === Event Callbacks ===
  
  /// Called when the content view's size changes
  final Function(double, double)? onContentSizeChange;
  
  /// Scroll event callback
  final Function(Map<String, dynamic>)? onScroll;

  /// Scroll begin drag event callback
  final Function(Map<String, dynamic>)? onScrollBeginDrag;

  /// Scroll end drag event callback
  final Function(Map<String, dynamic>)? onScrollEndDrag;

  /// Momentum scroll begin event callback
  final Function(Map<String, dynamic>)? onMomentumScrollBegin;

  /// Momentum scroll end event callback
  final Function(Map<String, dynamic>)? onMomentumScrollEnd;
  
  /// iOS scroll to top event (status bar tap)
  final Function()? onScrollToTop;

  ScrollViewProps({
    this.ref,
    this.horizontal,
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
    this.onScroll,
    this.onScrollBeginDrag,
    this.onScrollEndDrag,
    this.onMomentumScrollBegin,
    this.onMomentumScrollEnd,
    // Additional React Native properties
    this.alwaysBounceHorizontal,
    this.alwaysBounceVertical,
    this.automaticallyAdjustContentInsets,
    this.automaticallyAdjustKeyboardInsets,
    this.automaticallyAdjustsScrollIndicatorInsets,
    this.bouncesZoom,
    this.canCancelContentTouches,
    this.centerContent,
    this.contentInset,
    this.contentInsetAdjustmentBehavior,
    this.contentOffset,
    this.decelerationRate,
    this.directionalLockEnabled,
    this.disableIntervalMomentum,
    this.disableScrollViewPanResponder,
    this.endFillColor,
    this.fadingEdgeLength,
    this.indicatorStyle,
    this.invertStickyHeaders,
    this.keyboardDismissMode,
    this.keyboardShouldPersistTaps,
    this.maximumZoomScale,
    this.minimumZoomScale,
    this.nestedScrollEnabled,
    this.onContentSizeChange,
    this.onScrollToTop,
    this.overScrollMode,
    this.persistentScrollbar,
    this.pinchGestureEnabled,
    this.removeClippedSubviews,
    this.scrollIndicatorInsets,
    this.scrollPerfTag,
    this.scrollToOverflowEnabled,
    this.scrollsToTop,
    this.snapToAlignment,
    this.snapToEnd,
    this.snapToInterval,
    this.snapToOffsets,
    this.snapToStart,
    this.stickyHeaderHiddenOnScroll,
    this.stickyHeaderIndices,
    this.zoomScale,
    this.contentContainerStyle,
  });

  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};

    // ref is not sent to native, it's used on the Dart side
    if (horizontal != null) map['horizontal'] = horizontal;
    if (showsHorizontalScrollIndicator != null) {
      map['showsHorizontalScrollIndicator'] = showsHorizontalScrollIndicator;
    }
    if (showsVerticalScrollIndicator != null) {
      map['showsVerticalScrollIndicator'] = showsVerticalScrollIndicator;
    }
    if (bounces != null) map['bounces'] = bounces;
    if (pagingEnabled != null) map['pagingEnabled'] = pagingEnabled;
    if (scrollEventThrottle != null) {
      map['scrollEventThrottle'] = scrollEventThrottle;
    }
    
    // Content insets can be specified as individual props or as a map
    if (contentInset != null) {
      map['contentInset'] = contentInset;
    } else {
      if (contentInsetTop != null) map['contentInsetTop'] = contentInsetTop;
      if (contentInsetBottom != null) map['contentInsetBottom'] = contentInsetBottom;
      if (contentInsetLeft != null) map['contentInsetLeft'] = contentInsetLeft;
      if (contentInsetRight != null) map['contentInsetRight'] = contentInsetRight;
    }
    
    if (scrollEnabled != null) map['scrollEnabled'] = scrollEnabled;
    
    // Add all React Native properties
    if (alwaysBounceHorizontal != null) map['alwaysBounceHorizontal'] = alwaysBounceHorizontal;
    if (alwaysBounceVertical != null) map['alwaysBounceVertical'] = alwaysBounceVertical;
    if (automaticallyAdjustContentInsets != null) map['automaticallyAdjustContentInsets'] = automaticallyAdjustContentInsets;
    if (automaticallyAdjustKeyboardInsets != null) map['automaticallyAdjustKeyboardInsets'] = automaticallyAdjustKeyboardInsets;
    if (automaticallyAdjustsScrollIndicatorInsets != null) map['automaticallyAdjustsScrollIndicatorInsets'] = automaticallyAdjustsScrollIndicatorInsets;
    if (bouncesZoom != null) map['bouncesZoom'] = bouncesZoom;
    if (canCancelContentTouches != null) map['canCancelContentTouches'] = canCancelContentTouches;
    if (centerContent != null) map['centerContent'] = centerContent;
    if (contentInsetAdjustmentBehavior != null) map['contentInsetAdjustmentBehavior'] = contentInsetAdjustmentBehavior;
    if (contentOffset != null) map['contentOffset'] = contentOffset;
    if (decelerationRate != null) map['decelerationRate'] = decelerationRate;
    if (directionalLockEnabled != null) map['directionalLockEnabled'] = directionalLockEnabled;
    if (disableIntervalMomentum != null) map['disableIntervalMomentum'] = disableIntervalMomentum;
    if (disableScrollViewPanResponder != null) map['disableScrollViewPanResponder'] = disableScrollViewPanResponder;
    if (endFillColor != null) map['endFillColor'] = endFillColor;
    if (fadingEdgeLength != null) map['fadingEdgeLength'] = fadingEdgeLength;
    if (indicatorStyle != null) map['indicatorStyle'] = indicatorStyle;
    if (invertStickyHeaders != null) map['invertStickyHeaders'] = invertStickyHeaders;
    if (keyboardDismissMode != null) map['keyboardDismissMode'] = keyboardDismissMode;
    if (keyboardShouldPersistTaps != null) map['keyboardShouldPersistTaps'] = keyboardShouldPersistTaps;
    if (maximumZoomScale != null) map['maximumZoomScale'] = maximumZoomScale;
    if (minimumZoomScale != null) map['minimumZoomScale'] = minimumZoomScale;
    if (nestedScrollEnabled != null) map['nestedScrollEnabled'] = nestedScrollEnabled;
    if (overScrollMode != null) map['overScrollMode'] = overScrollMode;
    if (persistentScrollbar != null) map['persistentScrollbar'] = persistentScrollbar;
    if (pinchGestureEnabled != null) map['pinchGestureEnabled'] = pinchGestureEnabled;
    if (removeClippedSubviews != null) map['removeClippedSubviews'] = removeClippedSubviews;
    if (scrollIndicatorInsets != null) map['scrollIndicatorInsets'] = scrollIndicatorInsets;
    if (scrollPerfTag != null) map['scrollPerfTag'] = scrollPerfTag;
    if (scrollToOverflowEnabled != null) map['scrollToOverflowEnabled'] = scrollToOverflowEnabled;
    if (scrollsToTop != null) map['scrollsToTop'] = scrollsToTop;
    if (snapToAlignment != null) map['snapToAlignment'] = snapToAlignment;
    if (snapToEnd != null) map['snapToEnd'] = snapToEnd;
    if (snapToInterval != null) map['snapToInterval'] = snapToInterval;
    if (snapToOffsets != null) map['snapToOffsets'] = snapToOffsets;
    if (snapToStart != null) map['snapToStart'] = snapToStart;
    if (stickyHeaderHiddenOnScroll != null) map['stickyHeaderHiddenOnScroll'] = stickyHeaderHiddenOnScroll;
    if (stickyHeaderIndices != null) map['stickyHeaderIndices'] = stickyHeaderIndices;
    if (zoomScale != null) map['zoomScale'] = zoomScale;
    if (contentContainerStyle != null) map['contentContainerStyle'] = contentContainerStyle;

    // Add boolean flags to indicate event registration
    if (onScroll != null) map['onScroll'] = true;
    if (onScrollBeginDrag != null) map['onScrollBeginDrag'] = true;
    if (onScrollEndDrag != null) map['onScrollEndDrag'] = true;
    if (onMomentumScrollBegin != null) map['onMomentumScrollBegin'] = true;
    if (onMomentumScrollEnd != null) map['onMomentumScrollEnd'] = true;
    if (onContentSizeChange != null) map['onContentSizeChange'] = true;
    if (onScrollToTop != null) map['onScrollToTop'] = true;

    return map;
  }

  /// Create new ScrollViewProps by merging with another
  ScrollViewProps merge(ScrollViewProps other) {
    return ScrollViewProps(
      ref: other.ref ?? ref,
      horizontal: other.horizontal ?? horizontal,
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
      onScroll: other.onScroll ?? onScroll,
      onScrollBeginDrag: other.onScrollBeginDrag ?? onScrollBeginDrag,
      onScrollEndDrag: other.onScrollEndDrag ?? onScrollEndDrag,
      onMomentumScrollBegin: other.onMomentumScrollBegin ?? onMomentumScrollBegin,
      onMomentumScrollEnd: other.onMomentumScrollEnd ?? onMomentumScrollEnd,
      
      // Merge all Serious(complex) Native props
      alwaysBounceHorizontal: other.alwaysBounceHorizontal ?? alwaysBounceHorizontal,
      alwaysBounceVertical: other.alwaysBounceVertical ?? alwaysBounceVertical,
      automaticallyAdjustContentInsets: other.automaticallyAdjustContentInsets ?? automaticallyAdjustContentInsets,
      automaticallyAdjustKeyboardInsets: other.automaticallyAdjustKeyboardInsets ?? automaticallyAdjustKeyboardInsets,
      automaticallyAdjustsScrollIndicatorInsets: other.automaticallyAdjustsScrollIndicatorInsets ?? automaticallyAdjustsScrollIndicatorInsets,
      bouncesZoom: other.bouncesZoom ?? bouncesZoom,
      canCancelContentTouches: other.canCancelContentTouches ?? canCancelContentTouches,
      centerContent: other.centerContent ?? centerContent,
      contentInset: other.contentInset ?? contentInset,
      contentInsetAdjustmentBehavior: other.contentInsetAdjustmentBehavior ?? contentInsetAdjustmentBehavior,
      contentOffset: other.contentOffset ?? contentOffset,
      decelerationRate: other.decelerationRate ?? decelerationRate,
      directionalLockEnabled: other.directionalLockEnabled ?? directionalLockEnabled,
      disableIntervalMomentum: other.disableIntervalMomentum ?? disableIntervalMomentum,
      disableScrollViewPanResponder: other.disableScrollViewPanResponder ?? disableScrollViewPanResponder,
      endFillColor: other.endFillColor ?? endFillColor,
      fadingEdgeLength: other.fadingEdgeLength ?? fadingEdgeLength,
      indicatorStyle: other.indicatorStyle ?? indicatorStyle,
      invertStickyHeaders: other.invertStickyHeaders ?? invertStickyHeaders,
      keyboardDismissMode: other.keyboardDismissMode ?? keyboardDismissMode,
      keyboardShouldPersistTaps: other.keyboardShouldPersistTaps ?? keyboardShouldPersistTaps,
      maximumZoomScale: other.maximumZoomScale ?? maximumZoomScale,
      minimumZoomScale: other.minimumZoomScale ?? minimumZoomScale,
      nestedScrollEnabled: other.nestedScrollEnabled ?? nestedScrollEnabled,
      onContentSizeChange: other.onContentSizeChange ?? onContentSizeChange,
      onScrollToTop: other.onScrollToTop ?? onScrollToTop,
      overScrollMode: other.overScrollMode ?? overScrollMode,
      persistentScrollbar: other.persistentScrollbar ?? persistentScrollbar,
      pinchGestureEnabled: other.pinchGestureEnabled ?? pinchGestureEnabled,
      removeClippedSubviews: other.removeClippedSubviews ?? removeClippedSubviews,
      scrollIndicatorInsets: other.scrollIndicatorInsets ?? scrollIndicatorInsets,
      scrollPerfTag: other.scrollPerfTag ?? scrollPerfTag,
      scrollToOverflowEnabled: other.scrollToOverflowEnabled ?? scrollToOverflowEnabled,
      scrollsToTop: other.scrollsToTop ?? scrollsToTop,
      snapToAlignment: other.snapToAlignment ?? snapToAlignment,
      snapToEnd: other.snapToEnd ?? snapToEnd,
      snapToInterval: other.snapToInterval ?? snapToInterval,
      snapToOffsets: other.snapToOffsets ?? snapToOffsets,
      snapToStart: other.snapToStart ?? snapToStart,
      stickyHeaderHiddenOnScroll: other.stickyHeaderHiddenOnScroll ?? stickyHeaderHiddenOnScroll,
      stickyHeaderIndices: other.stickyHeaderIndices ?? stickyHeaderIndices,
      zoomScale: other.zoomScale ?? zoomScale,
      contentContainerStyle: other.contentContainerStyle ?? contentContainerStyle,
    );
  }

  /// Create a copy with certain properties modified
  ScrollViewProps copyWith({
    ScrollViewRef? ref,
    bool? horizontal,
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
    Function(Map<String, dynamic>)? onScroll,
    Function(Map<String, dynamic>)? onScrollBeginDrag,
    Function(Map<String, dynamic>)? onScrollEndDrag,
    Function(Map<String, dynamic>)? onMomentumScrollBegin,
    Function(Map<String, dynamic>)? onMomentumScrollEnd,
    
    // React Native properties
    bool? alwaysBounceHorizontal,
    bool? alwaysBounceVertical,
    bool? automaticallyAdjustContentInsets,
    bool? automaticallyAdjustKeyboardInsets,
    bool? automaticallyAdjustsScrollIndicatorInsets,
    bool? bouncesZoom,
    bool? canCancelContentTouches,
    bool? centerContent,
    Map<String, double>? contentInset,
    String? contentInsetAdjustmentBehavior,
    Map<String, double>? contentOffset,
    dynamic decelerationRate,
    bool? directionalLockEnabled,
    bool? disableIntervalMomentum,
    bool? disableScrollViewPanResponder,
    String? endFillColor,
    double? fadingEdgeLength,
    String? indicatorStyle,
    bool? invertStickyHeaders,
    String? keyboardDismissMode,
    String? keyboardShouldPersistTaps,
    double? maximumZoomScale,
    double? minimumZoomScale,
    bool? nestedScrollEnabled,
    Function(double, double)? onContentSizeChange,
    Function()? onScrollToTop,
    String? overScrollMode,
    bool? persistentScrollbar,
    bool? pinchGestureEnabled,
    bool? removeClippedSubviews,
    Map<String, double>? scrollIndicatorInsets,
    String? scrollPerfTag,
    bool? scrollToOverflowEnabled,
    bool? scrollsToTop,
    String? snapToAlignment,
    bool? snapToEnd,
    double? snapToInterval,
    List<double>? snapToOffsets,
    bool? snapToStart,
    bool? stickyHeaderHiddenOnScroll,
    List<int>? stickyHeaderIndices,
    double? zoomScale,
    Map<String, dynamic>? contentContainerStyle,
  }) {
    return ScrollViewProps(
      ref: ref ?? this.ref,
      horizontal: horizontal ?? this.horizontal,
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
      onScroll: onScroll ?? this.onScroll,
      onScrollBeginDrag: onScrollBeginDrag ?? this.onScrollBeginDrag,
      onScrollEndDrag: onScrollEndDrag ?? this.onScrollEndDrag,
      onMomentumScrollBegin: onMomentumScrollBegin ?? this.onMomentumScrollBegin,
      onMomentumScrollEnd: onMomentumScrollEnd ?? this.onMomentumScrollEnd,
      
      // Serious Native properties
      alwaysBounceHorizontal: alwaysBounceHorizontal ?? this.alwaysBounceHorizontal,
      alwaysBounceVertical: alwaysBounceVertical ?? this.alwaysBounceVertical,
      automaticallyAdjustContentInsets: automaticallyAdjustContentInsets ?? this.automaticallyAdjustContentInsets,
      automaticallyAdjustKeyboardInsets: automaticallyAdjustKeyboardInsets ?? this.automaticallyAdjustKeyboardInsets,
      automaticallyAdjustsScrollIndicatorInsets: automaticallyAdjustsScrollIndicatorInsets ?? this.automaticallyAdjustsScrollIndicatorInsets,
      bouncesZoom: bouncesZoom ?? this.bouncesZoom,
      canCancelContentTouches: canCancelContentTouches ?? this.canCancelContentTouches,
      centerContent: centerContent ?? this.centerContent,
      contentInset: contentInset ?? this.contentInset,
      contentInsetAdjustmentBehavior: contentInsetAdjustmentBehavior ?? this.contentInsetAdjustmentBehavior,
      contentOffset: contentOffset ?? this.contentOffset,
      decelerationRate: decelerationRate ?? this.decelerationRate,
      directionalLockEnabled: directionalLockEnabled ?? this.directionalLockEnabled,
      disableIntervalMomentum: disableIntervalMomentum ?? this.disableIntervalMomentum,
      disableScrollViewPanResponder: disableScrollViewPanResponder ?? this.disableScrollViewPanResponder,
      endFillColor: endFillColor ?? this.endFillColor,
      fadingEdgeLength: fadingEdgeLength ?? this.fadingEdgeLength,
      indicatorStyle: indicatorStyle ?? this.indicatorStyle,
      invertStickyHeaders: invertStickyHeaders ?? this.invertStickyHeaders,
      keyboardDismissMode: keyboardDismissMode ?? this.keyboardDismissMode,
      keyboardShouldPersistTaps: keyboardShouldPersistTaps ?? this.keyboardShouldPersistTaps,
      maximumZoomScale: maximumZoomScale ?? this.maximumZoomScale,
      minimumZoomScale: minimumZoomScale ?? this.minimumZoomScale,
      nestedScrollEnabled: nestedScrollEnabled ?? this.nestedScrollEnabled,
      onContentSizeChange: onContentSizeChange ?? this.onContentSizeChange,
      onScrollToTop: onScrollToTop ?? this.onScrollToTop,
      overScrollMode: overScrollMode ?? this.overScrollMode,
      persistentScrollbar: persistentScrollbar ?? this.persistentScrollbar,
      pinchGestureEnabled: pinchGestureEnabled ?? this.pinchGestureEnabled,
      removeClippedSubviews: removeClippedSubviews ?? this.removeClippedSubviews,
      scrollIndicatorInsets: scrollIndicatorInsets ?? this.scrollIndicatorInsets,
      scrollPerfTag: scrollPerfTag ?? this.scrollPerfTag,
      scrollToOverflowEnabled: scrollToOverflowEnabled ?? this.scrollToOverflowEnabled,
      scrollsToTop: scrollsToTop ?? this.scrollsToTop,
      snapToAlignment: snapToAlignment ?? this.snapToAlignment,
      snapToEnd: snapToEnd ?? this.snapToEnd,
      snapToInterval: snapToInterval ?? this.snapToInterval,
      snapToOffsets: snapToOffsets ?? this.snapToOffsets,
      snapToStart: snapToStart ?? this.snapToStart,
      stickyHeaderHiddenOnScroll: stickyHeaderHiddenOnScroll ?? this.stickyHeaderHiddenOnScroll,
      stickyHeaderIndices: stickyHeaderIndices ?? this.stickyHeaderIndices,
      zoomScale: zoomScale ?? this.zoomScale,
      contentContainerStyle: contentContainerStyle ?? this.contentContainerStyle,
    );
  }
}
