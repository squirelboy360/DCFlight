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

    final tabState = useState(0);
    
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
    

    return view(
      layout: LayoutProps(
        flex: 1,
      ),
      children: [
        // Tab-based navigation with stack navigation in each tab
        tabNavigator(
          tabs: tabs,
          initialTabIndex: tabState.value,
          tabBarBackgroundColor: Colors.amber,
          showTabBar: true,

          layout: LayoutProps(
            flex: 1,
          ),
          onTabChange: (v){
              tabState.setValue(v);
      print('Switched to tab: $v');
          },
        ),
      ],
    );
  }
}



