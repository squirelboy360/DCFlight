
import '../renderer/vdom/vdom_node.dart';
import 'navigation_protocol.dart';
import 'route.dart';

/// Provides navigation context to components
class NavigationContext {
  /// The navigation controller
  final NavigationController navigator;
  
  /// The current route
  final Route? route;
  
  /// Create a new navigation context
  NavigationContext({
    required this.navigator,
    this.route,
  });
  
  /// Helper method to push a route and get result
  Future<T?> push<T>(Route<T> route, {RouteTransition? transition}) {
    return navigator.push(route, transition: transition);
  }
  
  /// Helper method to pop a route with a result
  Future<bool> pop<T>([T? result]) {
    return navigator.pop(result);
  }
  
  /// Push a route by name
  Future<T?> pushNamed<T>(String routeName, {
    Map<String, dynamic> params = const {},
    RouteTransition? transition,
  }) {
    final route = Route<T>(name: routeName, params: params);
    return push(route, transition: transition);
  }
  
  /// Replace the current route with a named route
  Future<T?> replaceWithNamed<T>(String routeName, {
    Map<String, dynamic> params = const {},
    RouteTransition? transition,
  }) {
    final route = Route<T>(name: routeName, params: params);
    return navigator.replace(route, transition: transition);
  }
  
  /// Push a screen directly
  Future<T?> pushScreen<T>(
    VDomNode Function(RouteContext) screenBuilder, {
    String? name,
    Map<String, dynamic> params = const {},
    RouteTransition? transition,
  }) {
    final routeName = name ?? 'dynamic_${DateTime.now().millisecondsSinceEpoch}';
    final route = Route<T>(name: routeName, params: params);
    return push(route, transition: transition);
  }
}

/// A provider for navigation context
class NavigationContextProvider {
  /// The shared instance
  static final NavigationContextProvider instance = NavigationContextProvider._();
  
  /// Private constructor
  NavigationContextProvider._();
  
  /// Map of navigation controllers by ID
  final Map<String, NavigationController> _controllers = {};
  
  /// Register a navigation controller
  void registerNavigationController(
    String id,
    NavigationController controller
  ) {
    _controllers[id] = controller;
  }
  
  /// Get a navigation controller by ID
  NavigationController? getNavigationController(String id) {
    return _controllers[id];
  }
  
  /// Get a navigation context for a controller ID
  NavigationContext? getNavigationContext(String id) {
    final controller = _controllers[id];
    if (controller == null) return null;
    
    return NavigationContext(
      navigator: controller,
      route: controller.currentRoute,
    );
  }
  
  /// Remove a navigation controller
  void removeNavigationController(String id) {
    _controllers.remove(id);
  }
}
