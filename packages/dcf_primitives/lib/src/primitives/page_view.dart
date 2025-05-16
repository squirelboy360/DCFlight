import 'package:dcflight/dcflight.dart';
import 'package:dcf_primitives/src/primitives/page_view_definition.dart';

/// PageView properties
class PageViewProps {
  /// Initial page index
  final int initialPage;
  
  /// Whether to show page indicator
  final bool showIndicator;
  
  /// Color of the page indicator
  final Color? indicatorColor;
  
  /// Inactive color of the page indicator
  final Color? inactiveIndicatorColor;
  
  /// Whether swiping between pages is enabled
  final bool enableSwipe;
  
  /// Whether to scroll infinitely
  final bool infinite;
  
  /// Create page view props
  const PageViewProps({
    this.initialPage = 0,
    this.showIndicator = true,
    this.indicatorColor,
    this.inactiveIndicatorColor,
    this.enableSwipe = true,
    this.infinite = false,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'initialPage': initialPage,
      'showIndicator': showIndicator,
      if (indicatorColor != null) 'indicatorColor': indicatorColor,
      if (inactiveIndicatorColor != null) 'inactiveIndicatorColor': inactiveIndicatorColor,
      'enableSwipe': enableSwipe,
      'infinite': infinite,
    };
  }
}

/// A component that allows swiping through pages of content
VDomElement pageView({
  required List<VDomNode> children,
  PageViewProps pageViewProps = const PageViewProps(),
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Function? onPageChanged,
  Function? onViewId,
  Map<String, dynamic>? events,
}) {
  // Create an events map if callbacks are provided
  Map<String, dynamic> eventMap = events ?? {};
  
  if (onPageChanged != null) {
    eventMap['onPageChanged'] = onPageChanged;
  }
  
  if (onViewId != null) {
    eventMap['onViewId'] = onViewId;
  }
  
  return VDomElement(
    type: 'PageView',
    props: {
      ...pageViewProps.toMap(),
      ...layout.toMap(),
      ...style.toMap(),
        ...eventMap,
    },
    children: children,
  );
}

/// Utility class for calling methods on PageView components
class PageViewMethods {
  /// Navigate to a specific page
  static Future<void> goToPage(String viewId, int pageIndex, {bool animated = true}) async {
    await DCFPageViewDefinition().callMethod(
      viewId,
      'goToPage',
      {
        'index': pageIndex,
        'animated': animated,
      },
    );
  }
  
  /// Navigate to the next page
  static Future<void> nextPage(String viewId, {bool animated = true}) async {
    await DCFPageViewDefinition().callMethod(
      viewId,
      'nextPage',
      {
        'animated': animated,
      },
    );
  }
  
  /// Navigate to the previous page
  static Future<void> previousPage(String viewId, {bool animated = true}) async {
    await DCFPageViewDefinition().callMethod(
      viewId,
      'previousPage',
      {
        'animated': animated,
      },
    );
  }
}
