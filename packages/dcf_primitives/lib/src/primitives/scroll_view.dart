import 'package:dcflight/dcflight.dart';
import 'package:dcflight/framework/constants/layout_properties.dart';
import 'package:dcflight/framework/constants/style_properties.dart';

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
  
  /// Create scroll view props
  const ScrollViewProps({
    this.showsIndicator = true,
    this.bounces = true,
    this.horizontal = false,
    this.pagingEnabled = false,
    this.scrollEnabled = true,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'showsIndicator': showsIndicator,
      'bounces': bounces,
      'horizontal': horizontal,
      'pagingEnabled': pagingEnabled,
      'scrollEnabled': scrollEnabled,
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
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  List<VDomNode> children = const [],
  Function? onScrollBegin,
  Function? onScrollEnd,
  Map<String, dynamic>? events,
}) {
  return scrollView(
    scrollViewProps: ScrollViewProps(
      horizontal: true,
      showsIndicator: showsIndicator,
    ),
    layout: layout,
    style: style,
    children: children,
    onScrollBegin: onScrollBegin,
    onScrollEnd: onScrollEnd,
    events: events,
  );
}