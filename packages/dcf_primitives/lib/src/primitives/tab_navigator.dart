import 'package:dcflight/dcflight.dart';

/// Tab item configuration
class TabItem {
  /// Title to display on the tab
  final String title;
  
  /// Icon name to display on the tab
  final String? icon;
  
  /// Selected icon name (when tab is active)
  final String? selectedIcon;
  
  /// Builder for the screen content
  final ScreenBuilder builder;
  
  /// Additional data for this tab
  final Map<String, dynamic>? data;
  
  /// Create a new tab item
  const TabItem({
    required this.title,
    this.icon,
    this.selectedIcon,
    required this.builder,
    this.data,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      if (icon != null) 'icon': icon,
      if (selectedIcon != null) 'selectedIcon': selectedIcon,
      if (data != null) 'data': data,
    };
  }
}

/// Tab navigator properties
class TabNavigatorProps {
  /// The list of tab items
  final List<TabItem> tabs;
  
  /// Initially selected tab index
  final int initialTabIndex;
  
  /// Whether to show the tab bar
  final bool showTabBar;
  
  /// Background color of the tab bar
  final Color? tabBarBackgroundColor;
  
  /// Text color for the tabs
  final Color? tabTextColor;
  
  /// Selected tab text color
  final Color? selectedTabTextColor;
  
  /// Position of the tab bar (bottom or top)
  final String tabBarPosition;
  
  /// Create tab navigator props
  const TabNavigatorProps({
    required this.tabs,
    this.initialTabIndex = 0,
    this.showTabBar = true,
    this.tabBarBackgroundColor,
    this.tabTextColor,
    this.selectedTabTextColor,
    this.tabBarPosition = 'bottom',
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    final tabItems = tabs.map((tab) => tab.toMap()).toList();
    
    return {
      'tabs': tabItems,
      'initialTabIndex': initialTabIndex,
      'showTabBar': showTabBar,
      if (tabBarBackgroundColor != null) 'tabBarBackgroundColor': tabBarBackgroundColor,
      if (tabTextColor != null) 'tabTextColor': tabTextColor,
      if (selectedTabTextColor != null) 'selectedTabTextColor': selectedTabTextColor,
      'tabBarPosition': tabBarPosition,
    };
  }
}

/// Tab change listener
typedef TabChangeListener = void Function(int index);

/// A tab-based navigation component
VDomElement tabNavigator({
  required List<TabItem> tabs,
  int initialTabIndex = 0,
  bool showTabBar = true,
  Color? tabBarBackgroundColor,
  Color? tabTextColor,
  Color? selectedTabTextColor,
  String tabBarPosition = 'bottom',
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  TabChangeListener? onTabChange,
  Map<String, dynamic>? events,
}) {
  // Create a navigation controller for each tab
  final navigatorId = 'tab_nav_${DateTime.now().millisecondsSinceEpoch}';
  
  // Create props
  final props = TabNavigatorProps(
    tabs: tabs,
    initialTabIndex: initialTabIndex,
    showTabBar: showTabBar,
    tabBarBackgroundColor: tabBarBackgroundColor,
    tabTextColor: tabTextColor,
    selectedTabTextColor: selectedTabTextColor,
    tabBarPosition: tabBarPosition,
  );
  
  // Combine props
  final combinedProps = {
    ...props.toMap(),
    ...style.toMap(),
    ...layout.toMap(),
    'navigatorId': navigatorId,
  };
  
  // Add event handlers
  final combinedEvents = {
    ...?events,
    if (onTabChange != null) 'onTabChange': (Map<String, dynamic> eventData) {
      final index = eventData['index'] as int;
      onTabChange(index);
    },
  };
  
  return VDomElement(
    type: 'TabNavigator',
    props: combinedProps,
    events: combinedEvents,
    children: [],
  );
}

/// Control interface for a tab navigator
class TabNavigatorRef {
  final String _viewId;
  final PlatformDispatcher _dispatcher;
  
  /// Create a new tab navigator reference
  TabNavigatorRef(this._viewId)
      : _dispatcher = PlatformDispatcherIml();
  
  /// Switch to a specific tab
  Future<bool> switchTab(int index) async {
    final result = await _dispatcher.callComponentMethod(
      _viewId, 
      'switchTab',
      {'index': index},
    );
    
    return result as bool? ?? false;
  }
  
  /// Get the currently selected tab index
  Future<int> getSelectedIndex() async {
    final result = await _dispatcher.callComponentMethod(
      _viewId, 
      'getSelectedIndex',
      {},
    );
    
    return result as int? ?? 0;
  }
}
