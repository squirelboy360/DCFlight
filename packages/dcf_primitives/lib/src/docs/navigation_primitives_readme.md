# DCFlight Navigation Primitives

This document provides an overview of the navigation primitives available in the DCFlight cross-platform framework.

## Overview

DCFlight navigation primitives offer a complete set of components for managing navigation and modality in your cross-platform applications. These primitives are designed to provide a native look and feel on iOS while maintaining a consistent API across platforms.

## Available Components

### Modal

A component for presenting modal content that overlays the current screen.

#### Properties

- `visible`: Whether the modal is visible
- `animated`: Whether to animate transitions
- `dismissOnBackdropTap`: Whether the modal can be dismissed by tapping the backdrop
- `backdropOpacity`: The opacity of the backdrop
- `presentationStyle`: The presentation style of the modal
  - `fullScreen`
  - `pageSheet`
  - `formSheet`
  - `overCurrentContext`
- `transitionStyle`: The transition style of the modal
  - `coverVertical`
  - `flipHorizontal`
  - `crossDissolve`
  - `partialCurl`

#### Methods

- `present()`: Present the modal
- `dismiss()`: Dismiss the modal
- `setBackdropOpacity(double opacity)`: Set the backdrop opacity

#### Events

- `onDismiss`: Triggered when the modal is dismissed

### Alert

A component for presenting alerts and action sheets.

#### Properties

- `title`: The title of the alert
- `message`: The message body of the alert
- `style`: The style of the alert
  - `defaultStyle`: Standard alert
  - `actionSheet`: Action sheet presentation
- `actions`: The buttons/actions for the alert
- `visible`: Whether the alert is visible

#### Methods

- `show()`: Show the alert
- `dismiss()`: Dismiss the alert
- `addAction(AlertAction action)`: Add an action to the alert

#### Events

- `onAction`: Triggered when an action button is pressed

### Stack Navigator

A component for hierarchical navigation with a navigation stack.

#### Properties

- `initialRouteId`: The ID of the initial route to display
- `routes`: An array of route configurations
- `navigationBarHidden`: Whether the navigation bar is hidden
- `barStyle`: The style of the navigation bar
  - `defaultStyle`: Standard navigation bar
  - `largeTitles`: Large title navigation bar
  - `transparent`: Transparent navigation bar
- `barTintColor`: The tint color of the navigation bar

#### Methods

- `push(String screenId)`: Push a screen onto the navigation stack
- `pop()`: Pop the top screen from the navigation stack
- `popToRoot()`: Pop to the root screen
- `setNavigationBarHidden(bool hidden)`: Set whether the navigation bar is hidden
- `setTitle(String title)`: Set the title of the current screen

#### Events

- `onNavigate`: Triggered when navigation occurs

### Tab Navigator

A component for tab-based navigation.

#### Properties

- `initialIndex`: The index of the initially selected tab
- `tabs`: An array of tab configurations
- `tabBarHidden`: Whether the tab bar is hidden
- `tintColor`: The tint color of the tab bar
- `unselectedTintColor`: The tint color of unselected tabs

#### Methods

- `switchToTab(int index)`: Switch to a tab by index
- `switchToTabWithId(String tabId)`: Switch to a tab by ID
- `setBadge(int index, String? badge)`: Set a badge for a tab
- `setTabBarHidden(bool hidden)`: Set whether the tab bar is hidden

#### Events

- `onTabChange`: Triggered when the selected tab changes

## Usage Examples

See the example code in `src/examples/navigation_examples.dart` for comprehensive usage examples.

### Basic Modal Example

```dart
// Create a reference for controlling the modal
final modalRef = ModalRef("modal1");

// Create the modal component
final modal = Modal(
  ref: modalRef,
  presentationStyle: ModalPresentationStyle.pageSheet,
  content: yourContent,
);

// Show the modal
modalRef.present();

// Later, to dismiss the modal
modalRef.dismiss();
```

### Basic Alert Example

```dart
// Create a reference for controlling the alert
final alertRef = AlertRef("alert1");

// Create the alert component
final alert = Alert(
  ref: alertRef,
  title: "Confirmation",
  message: "Are you sure?",
  actions: [
    AlertAction(
      title: "Cancel",
      style: AlertActionStyle.cancel,
      onPress: () {
        print("Cancel pressed");
      },
    ),
    AlertAction(
      title: "OK",
      onPress: () {
        print("OK pressed");
      },
    ),
  ],
);

// Show the alert
alertRef.show();
```

### Basic Stack Navigator Example

```dart
// Create a reference for controlling the stack navigator
final navRef = StackNavigatorRef("nav1");

// Create the stack navigator
final navigator = StackNavigator(
  ref: navRef,
  initialRouteId: "home",
  routes: [
    StackRoute(
      id: "home",
      title: "Home",
      component: homeScreen,
    ),
    StackRoute(
      id: "details",
      title: "Details",
      component: detailsScreen,
    ),
  ],
);

// Navigate to a screen
navRef.push("details");

// Go back
navRef.pop();
```

### Basic Tab Navigator Example

```dart
// Create a reference for controlling the tab navigator
final tabRef = TabNavigatorRef("tabs1");

// Create the tab navigator
final tabNavigator = TabNavigator(
  ref: tabRef,
  initialIndex: 0,
  tabs: [
    TabItem(
      id: "home",
      title: "Home",
      icon: "system:house",
      component: homeScreen,
    ),
    TabItem(
      id: "profile",
      title: "Profile",
      icon: "system:person",
      component: profileScreen,
    ),
  ],
);

// Switch to a tab
tabRef.switchToTab(1);

// Add a badge
tabRef.setBadge(0, "5");
```

## Integration with Existing Components

These navigation primitives integrate seamlessly with existing DCFlight components. You can nest them as needed to create complex navigation patterns:

- Use a TabNavigator with StackNavigator in each tab
- Present a Modal from any screen
- Show an Alert from any component
- Combine navigation patterns as needed for your app's design

## Best Practices

1. Always provide meaningful IDs for each component to ensure proper referencing
2. Use references (ModalRef, AlertRef, etc.) to control components programmatically
3. Create reusable screen components for consistent navigation
4. Handle navigation events to update your application state appropriately
5. Consider the native navigation patterns of each platform for the best user experience
