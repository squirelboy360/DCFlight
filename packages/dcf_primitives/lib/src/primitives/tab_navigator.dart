import 'package:dcf_primitives/src/primitives/tab_navigator_definition.dart';
import 'package:dcflight/dcflight.dart';

/// Tab navigator tab item
class TabItem {
  /// Unique identifier for the tab
  final String id;
  
  /// Title to display in the tab bar
  final String title;
  
  /// Icon name to display in the tab bar
  final String icon;
  
  /// Selected icon name to display when tab is active
  final String? selectedIcon;
  
  /// Component to render for this tab
  final VDomNode component;
  
  /// Create a tab item
  const TabItem({
    required this.id,
    required this.title,
    required this.icon,
    this.selectedIcon,
    required this.component,
  });
  
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      if (selectedIcon != null) 'selectedIcon': selectedIcon,
    };
  }
}

/// Tab navigator properties
class TabNavigatorProps {
  /// Initial tab index to display
  final int initialIndex;
  
  /// Tab configuration
  final List<TabItem> tabs;
  
  /// Whether the tab bar is hidden
  final bool tabBarHidden;
  
  /// Tint color of the tab bar (hex color string)
  final String? tintColor;
  
  /// Unselected tint color of the tab bar (hex color string)
  final String? unselectedTintColor;
  
  /// Create tab navigator props
  const TabNavigatorProps({
    this.initialIndex = 0,
    required this.tabs,
    this.tabBarHidden = false,
    this.tintColor,
    this.unselectedTintColor,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'initialIndex': initialIndex,
      'tabs': tabs.map((tab) => tab.toMap()).toList(),
      'tabBarHidden': tabBarHidden,
      if (tintColor != null) 'tintColor': tintColor,
      if (unselectedTintColor != null) 'unselectedTintColor': unselectedTintColor,
    };
  }
}

/// Reference object to control a TabNavigator component
class TabNavigatorRef {
  final String _viewId;
  
  /// Create a tab navigator reference
  TabNavigatorRef(this._viewId);
  
  /// Switch to a tab by index
  Future<void> switchToTab(int index) async {
    await DCFTabNavigatorDefinition().callMethod(
      _viewId,
      'switchToTab',
      {'index': index},
    );
  }
  
  /// Switch to a tab by ID
  Future<void> switchToTabWithId(String tabId) async {
    await DCFTabNavigatorDefinition().callMethod(
      _viewId,
      'switchToTabWithId',
      {'tabId': tabId},
    );
  }
  
  /// Set badge for a tab by index
  Future<void> setBadge(int index, String? badge) async {
    await DCFTabNavigatorDefinition().callMethod(
      _viewId,
      'setBadge',
      {
        'index': index,
        'badge': badge,
      },
    );
  }
  
  /// Set whether the tab bar is hidden
  Future<void> setTabBarHidden(bool hidden, {bool animated = true}) async {
    await DCFTabNavigatorDefinition().callMethod(
      _viewId,
      'setTabBarHidden',
      {
        'hidden': hidden,
        'animated': animated,
      },
    );
  }
}

/// Tab navigator component
class TabNavigator extends Component {
  /// Tab navigator properties
  final Map<String, dynamic> _props;
  
  /// Tab navigator reference
  final TabNavigatorRef? ref;
  
  /// Tab configuration
  final List<TabItem> tabs;
  
  /// Create a tab navigator
  TabNavigator({
    this.ref,
    int initialIndex = 0,
    required this.tabs,
    bool tabBarHidden = false,
    String? tintColor,
    String? unselectedTintColor,
    super.key,
  }) : _props = TabNavigatorProps(
         initialIndex: initialIndex,
         tabs: tabs,
         tabBarHidden: tabBarHidden,
         tintColor: tintColor,
         unselectedTintColor: unselectedTintColor,
       ).toMap();
  
  @override
  void componentDidMount() {
    // If we have a reference, register tabs
    if (ref != null) {
      // Tabs are already registered in the props
    }
  }
  
  @override
  VDomNode render() {
    // We need to convert the tabs to components that can be rendered
    final tabComponents = tabs.map((tab) {
      return VDomElement(
        type: '_TabComponent',
        props: tab.toMap(),
        children: [tab.component],
      );
    }).toList();
    
    return VDomElement(
      type: 'TabNavigator',
      props: {
        ..._props,
        'onTabChange': _handleTabChange,
      },
      children: tabComponents,
    );
  }
  
  /// Handle tab change events
  void _handleTabChange(Map<String, dynamic> data) {
    final int index = data['index'] ?? 0;
    final String tabId = data['tabId'] ?? '';
    
    // Add custom event handling here if needed
    print('Tab changed: index=$index, tabId=$tabId');
  }
}
