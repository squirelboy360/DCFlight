# DCFlight Navigation API Documentation

## Overview

The DCFlight framework provides a robust navigation system with support for both stack-based and tab-based navigation. The navigation system is designed to be platform-agnostic while providing native performance and appearance on each platform.

## Core Navigation Components

### 1. Routes

Routes represent destinations in your application. Each route has a name, parameters, and can return a result when popped.

```dart
// Create a route
final route = Route(
  name: 'details',
  params: {'id': 123, 'title': 'Product Details'},
);

// Push a route and get a result
final result = await navigator.push(route);
```

### 2. Navigation Controller

The `NavigationController` interface provides methods to manipulate the navigation stack:

```dart
// Push a new route
await navigator.push(route);

// Pop the current route with a result
await navigator.pop(result);

// Replace the current route
await navigator.replace(newRoute);

// Pop to the root route
await navigator.popToRoot();

// Pop until a specific condition is met
await navigator.popUntil((route) => route.name == 'home');
```

### 3. Navigation Context

The `NavigationContext` provides contextual information and helper methods for navigation:

```dart
// In a screen builder function
VDomNode myScreen(RouteContext context) {
  // Access route parameters
  final id = context.params['id'] as int;
  
  // Navigate using the context
  context.navigator.push(newRoute);
  context.navigator.pushNamed('details', params: {'id': 123});
  context.navigator.pop(result);
}
```

## Stack Navigation

Stack navigation allows you to push and pop screens in a linear stack. It's ideal for drill-down flows.

### Stack Navigator Component

```dart
// Create a stack navigator
stackNavigator(
  props: StackNavigatorProps(
    initialRoute: 'home',
    showNavigationBar: true,
    title: 'My App',
    enableSwipeBack: true,
    barBackgroundColor: Colors.blue,
    barTextColor: Colors.white,
  ),
  routes: {
    'home': homeScreen,
    'details': detailsScreen,
    'settings': settingsScreen,
  },
  layout: LayoutProps(flex: 1),
);
```

### Stack Navigator Reference

You can obtain a reference to programmatically control the stack navigator:

```dart
final navigatorRef = StackNavigatorRef(viewId, controller);

// Use the reference to navigate
navigatorRef.push(route);
navigatorRef.pop();
navigatorRef.pushNamed('details', params: {'id': 123});
```

## Tab Navigation

Tab navigation allows users to switch between different sections of your app with a tab bar.

### Tab Navigator Component

```dart
// Create tab items
final tabs = [
  TabItem(
    title: 'Home',
    icon: 'home',
    selectedIcon: 'home',
    builder: homeScreen,
  ),
  TabItem(
    title: 'Profile',
    icon: 'person',
    selectedIcon: 'person',
    builder: profileScreen,
  ),
];

// Create a tab navigator
tabNavigator(
  tabs: tabs,
  initialTabIndex: 0,
  showTabBar: true,
  tabBarBackgroundColor: Colors.white,
  tabTextColor: Colors.grey,
  selectedTabTextColor: Colors.blue,
  tabBarPosition: 'bottom',
  onTabChange: (index) {
    print('Switched to tab: $index');
  },
);
```

### Tab Navigator Reference

You can obtain a reference to programmatically control the tab navigator:

```dart
final tabRef = TabNavigatorRef(viewId);

// Switch to a specific tab
tabRef.switchTab(2);

// Get the current tab index
final currentIndex = await tabRef.getSelectedIndex();
```

## Combining Stack and Tab Navigation

You can combine stack and tab navigation by placing a stack navigator inside each tab:

```dart
TabItem(
  title: 'Home',
  icon: 'home',
  builder: (context) {
    // Create a stack navigator for this tab
    return stackNavigator(
      props: StackNavigatorProps(
        routes: {
          'home': homeScreen,
          'details': detailsScreen,
        },
        initialRoute: 'home',
      ),
    );
  },
),
```

## Route Transitions

You can customize transitions between routes:

```dart
// Push with a custom transition
navigator.push(
  route,
  transition: RouteTransition(
    type: RouteTransitionType.fade,
    durationMs: 300,
  ),
);
```

Available transition types:
- `platform` (default platform behavior)
- `fade`
- `slideRight`
- `slideLeft`
- `slideTop`
- `slideBottom`
- `none` (no animation)

## Best Practices

1. **Route Organization**: Keep your routes organized in a central place for easy reference.
2. **Screen Parameters**: Use route parameters to pass data between screens.
3. **Screen Results**: Use route results when you need to return data from a screen.
4. **Tab + Stack**: For complex apps, combine tab navigation with stack navigation in each tab.
5. **Deep Linking**: Define your routes in a way that supports deep linking from external sources.
