import 'package:dcflight/dcflight.dart';

/// ScrollView properties
class ScrollViewProps {
  /// Whether to show the scroll indicator
  final bool showsIndicator;
  
  /// Whether to bounce at the edges
  final bool bounces;
  
  /// Whether the scroll view scrolls horizontally
  final bool horizontal;
  
  /// Whether paging is enabled
  final bool pagingEnabled;
  
  /// Whether scrolling is enabled
  final bool scrollEnabled;
  
  /// Whether content should be clipped to bounds
  final bool clipsToBounds;
  
  /// Content insets to apply to the scroll view content
  final EdgeInsets? contentInset;
  
  /// Additional content offset at the beginning
  final double? contentOffsetStart;
  
  /// Adjust insets that automatically apply to scrollViews
  final bool automaticallyAdjustContentInsets;
  
  /// Create scroll view props
  const ScrollViewProps({
    this.showsIndicator = true,
    this.bounces = true,
    this.horizontal = false,
    this.pagingEnabled = false,
    this.scrollEnabled = true,
    this.clipsToBounds = true,
    this.contentInset,
    this.contentOffsetStart,
    this.automaticallyAdjustContentInsets = true,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    final map = {
      'showsIndicator': showsIndicator,
      'bounces': bounces,
      'horizontal': horizontal,
      'pagingEnabled': pagingEnabled,
      'scrollEnabled': scrollEnabled,
      'clipsToBounds': clipsToBounds,
      'automaticallyAdjustContentInsets': automaticallyAdjustContentInsets,
    };
    
    if (contentInset != null) {
      map['contentInset'] = contentInset!.toMap();
    }
    
    if (contentOffsetStart != null) {
      map['contentOffsetStart'] = contentOffsetStart;
    }
    
    return map;
  }
}

/// Edge insets for content positioning
class EdgeInsets {
  final double top;
  final double left;
  final double bottom;
  final double right;
  
  const EdgeInsets({
    this.top = 0,
    this.left = 0,
    this.bottom = 0,
    this.right = 0,
  });
  
  /// Create edge insets with all sides equal
  const EdgeInsets.all(double value)
      : top = value,
        left = value,
        bottom = value,
        right = value;
        
  /// Create edge insets with horizontal and vertical values
  const EdgeInsets.symmetric({
    double vertical = 0,
    double horizontal = 0,
  })  : top = vertical,
        left = horizontal,
        bottom = vertical,
        right = horizontal;
        
  /// Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'top': top,
      'left': left,
      'bottom': bottom,
      'right': right,
    };
  }
}

/// A component that provides scrollable content
VDomElement scrollView({
  ScrollViewProps scrollViewProps = const ScrollViewProps(),
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  List<VDomNode> children = const [],
  Function? onScrollBegin,
  Function? onScrollEnd,
  Function? onScroll,
  Map<String, dynamic>? events,
}) {
  // Create events map if callbacks are provided
  Map<String, dynamic> eventMap = events ?? {};
  
  if (onScrollBegin != null) {
    eventMap['onScrollBegin'] = onScrollBegin;
  }
  
  if (onScrollEnd != null) {
    eventMap['onScrollEnd'] = onScrollEnd;
  }
  
  if (onScroll != null) {
    eventMap['onScroll'] = onScroll;
  }
  
  return VDomElement(
    type: 'ScrollView',
    props: {
      ...scrollViewProps.toMap(),
      ...layout.toMap(),
      ...style.toMap(),
    },
    children: children,
    events: eventMap.isNotEmpty ? eventMap : null,
  );
}

/// Create a horizontal scrolling view
VDomElement horizontalScrollView({
  bool showsIndicator = true,
  bool bounces = true,
  bool pagingEnabled = false,
  bool scrollEnabled = true,
  bool clipsToBounds = true,
  EdgeInsets? contentInset,
  double? contentOffsetStart,
  bool automaticallyAdjustContentInsets = true,
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  List<VDomNode> children = const [],
  Function? onScrollBegin,
  Function? onScrollEnd,
  Function? onScroll,
  Map<String, dynamic>? events,
}) {
  return scrollView(
    scrollViewProps: ScrollViewProps(
      horizontal: true,
      showsIndicator: showsIndicator,
      bounces: bounces,
      pagingEnabled: pagingEnabled,
      scrollEnabled: scrollEnabled,
      clipsToBounds: clipsToBounds,
      contentInset: contentInset,
      contentOffsetStart: contentOffsetStart,
      automaticallyAdjustContentInsets: automaticallyAdjustContentInsets,
    ),
    layout: layout,
    style: style,
    children: children,
    onScrollBegin: onScrollBegin,
    onScrollEnd: onScrollEnd,
    onScroll: onScroll,
    events: events,
  );
}