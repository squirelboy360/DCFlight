import 'package:dcf_primitives/dcf_primitives.dart';
import 'package:dcflight/dcflight.dart';

import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

class DCFGo extends StatefulComponent {
  @override
  VDomNode render() {
    // Shared routes used across tabs
    final sharedRoutes = {
      'details': detailsScreen,
    };
    
    // Create tabs with their own stack navigators
    final tabs = [
      TabItem(
        title: 'Home',
        icon: 'home',
        selectedIcon: 'home',
        builder: (context) {
          // Create a stack navigator for the Home tab
          return stackNavigator(
            props: StackNavigatorProps(
              routes: {
                'home': homeScreen,
                ...sharedRoutes,
              },
              initialRoute: 'home',
              title: 'Home',
            ),
            layout: LayoutProps(
              flex: 1,
            ),
          );
        },
      ),
      TabItem(
        title: 'Profile',
        icon: 'person',
        selectedIcon: 'person',
        builder: (context) {
          // Create a stack navigator for the Profile tab
          return stackNavigator(
            props: StackNavigatorProps(
              routes: {
                'profile': profileScreen,
                ...sharedRoutes,
              },
              initialRoute: 'profile',
              title: 'Profile',
            ),
            layout: LayoutProps(
              flex: 1,
            ),
          );
        },
      ),
      TabItem(
        title: 'Settings',
        icon: 'settings',
        selectedIcon: 'settings',
        builder: (context) {
          // Create a stack navigator for the Settings tab
          return stackNavigator(
            props: StackNavigatorProps(
              routes: {
                'settings': settingsScreen,
                ...sharedRoutes,
              },
              initialRoute: 'settings',
              title: 'Settings',
            ),
            layout: LayoutProps(
              flex: 1,
            ),
          );
        },
      ),
    ];
    
    // Setup tab change callback
    void onTabChange(int index) {
      print('Switched to tab: $index');
    }
    
    return view(
      layout: LayoutProps(
        flex: 1,
        // Apply safe area insets
        paddingTop: ScreenUtilities.instance.statusBarHeight,
        paddingBottom: ScreenUtilities.instance.statusBarHeight,
      ),
      children: [
        // Tab-based navigation with stack navigation in each tab
        tabNavigator(
          tabs: tabs,
          initialTabIndex: 0,
          tabBarBackgroundColor: Colors.white,
          tabTextColor: Colors.grey,
          selectedTabTextColor: Colors.blue,
          layout: LayoutProps(
            flex: 1,
          ),
          onTabChange: onTabChange,
        ),
      ],
    );
  }
}



