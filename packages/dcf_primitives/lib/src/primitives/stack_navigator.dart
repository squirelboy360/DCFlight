import 'package:dcflight/dcflight.dart';

/// Stack navigation properties
class StackNavigatorProps {
  /// Initial route name to display
  final String? initialRoute;
  
  /// Whether to show the navigation bar
  final bool showNavigationBar;
  
  /// Title for the navigation bar
  final String? title;
  
  /// Route definitions keyed by route name
  final Map<String, ScreenBuilder>? routes;
  
  /// Whether to allow swipe back gesture
  final bool enableSwipeBack;
  
  /// Background color of the navigation bar
  final Color? barBackgroundColor;
  
  /// Text color for the navigation bar
  final Color? barTextColor;
  
  /// Create stack navigator props
  const StackNavigatorProps({
    this.initialRoute,
    this.showNavigationBar = true,
    this.title,
    this.routes,
    this.enableSwipeBack = true,
    this.barBackgroundColor,
    this.barTextColor,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      if (initialRoute != null) 'initialRoute': initialRoute,
      'showNavigationBar': showNavigationBar,
      if (title != null) 'title': title,
      'enableSwipeBack': enableSwipeBack,
      if (barBackgroundColor != null) 'barBackgroundColor': barBackgroundColor,
      if (barTextColor != null) 'barTextColor': barTextColor,
    };
  }
}

/// A stack-based navigation component
VDomElement stackNavigator({
  StackNavigatorProps props = const StackNavigatorProps(),
  Map<String, ScreenBuilder>? routes,
  String? initialRoute,
  LayoutProps layout = const LayoutProps(),
  StyleSheet style = const StyleSheet(),
  Map<String, dynamic>? events,
  List<VDomNode> children = const [],
}) {
  // Create a navigation controller for this navigator
  final controller = NavigationControllerImpl();
  final navigatorId = 'stack_nav_${DateTime.now().millisecondsSinceEpoch}';
  
  // Register the controller so it can be accessed by ID
  NavigationContextProvider.instance.registerNavigationController(
    navigatorId, 
    controller,
  );
  
  // Combine props
  final combinedProps = {
    ...props.toMap(),
    ...style.toMap(),
    ...layout.toMap(),
    'navigatorId': navigatorId,
    if (initialRoute != null) 'initialRoute': initialRoute,
    if (routes != null) 'hasRoutes': true,
  };
  
  // If there's an initial route and we have routes defined, push it
  if (initialRoute != null && routes != null && routes.containsKey(initialRoute)) {
    // Schedule after creation
    Future.microtask(() {
      final route = Route(name: initialRoute, params: {});
      controller.push(route);
    });
  }
  
  return VDomElement(
    type: 'StackNavigator',
    props: combinedProps,
    children: children,
    events: events,
  );
}

/// Represents a navigation reference that can be used to control the navigator
class StackNavigatorRef {
  final NavigationController _controller;
  
  /// Create a new stack navigator reference
  StackNavigatorRef(this._controller);
  
  /// Push a new route onto the stack
  Future<T?> push<T>(Route<T> route, {RouteTransition? transition}) {
    return _controller.push(route, transition: transition);
  }
  
  /// Pop the current route
  Future<bool> pop<T>([T? result]) {
    return _controller.pop(result);
  }
  
  /// Pop to the root route
  Future<bool> popToRoot({bool animated = true}) {
    return _controller.popToRoot(animated: animated);
  }
  
  /// Replace the current route with a new one
  Future<T?> replace<T>(Route<T> route, {RouteTransition? transition}) {
    return _controller.replace(route, transition: transition);
  }
  
  /// Push a route by name
  Future<T?> pushNamed<T>(String routeName, {
    Map<String, dynamic> params = const {},
    RouteTransition? transition,
  }) {
    final route = Route<T>(name: routeName, params: params);
    return push(route, transition: transition);
  }
}
