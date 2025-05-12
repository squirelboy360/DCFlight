import 'dart:async';
import 'route.dart';

/// Base class for navigation events
abstract class NavigationEvent {
  /// The route associated with this event
  final Route route;
  
  /// Create a new navigation event
  NavigationEvent(this.route);
}

/// Event when a route is pushed onto the stack
class RouteAddedEvent extends NavigationEvent {
  RouteAddedEvent(super.route);
}

/// Event when a route is popped from the stack
class RouteRemovedEvent extends NavigationEvent {
  RouteRemovedEvent(super.route);
}

/// Event when a route becomes active (top of the stack)
class RouteActivatedEvent extends NavigationEvent {
  RouteActivatedEvent(super.route);
}

/// Interface for navigation controllers
abstract class NavigationController {
  /// Push a new route onto the stack
  Future<T?> push<T>(Route<T> route, {RouteTransition? transition});
  
  /// Replace the current route with a new one
  Future<T?> replace<T>(Route<T> route, {RouteTransition? transition});
  
  /// Replace the entire stack with a new route
  Future<T?> replaceAll<T>(Route<T> route, {RouteTransition? transition});
  
  /// Pop the current route off the stack
  Future<bool> pop<T>([T? result]);
  
  /// Pop to the root route
  Future<bool> popToRoot({bool animated = true});
  
  /// Pop until a predicate returns true
  Future<bool> popUntil(bool Function(Route route) predicate);
  
  /// Get the current route
  Route? get currentRoute;
  
  /// Get all routes in the stack
  List<Route> get routes;
  
  /// Stream of navigation events
  Stream<NavigationEvent> get events;
  
  /// Add a listener for navigation events
  void addListener(void Function(NavigationEvent) listener);
  
  /// Remove a navigation listener
  void removeListener(void Function(NavigationEvent) listener);
}

/// Core implementation of a navigation controller
class NavigationControllerImpl implements NavigationController {
  /// Stack of routes
  final List<Route> _routes = [];
  
  /// Controller for navigation events
  final StreamController<NavigationEvent> _eventsController = 
      StreamController<NavigationEvent>.broadcast();
  
  @override
  Stream<NavigationEvent> get events => _eventsController.stream;
  
  @override
  Route? get currentRoute => _routes.isNotEmpty ? _routes.last : null;
  
  @override
  List<Route> get routes => List.unmodifiable(_routes);
  
  @override
  Future<T?> push<T>(Route<T> route, {RouteTransition? transition}) async {
    // Add route to stack
    _routes.add(route);
    
    // Notify listeners
    _eventsController.add(RouteAddedEvent(route));
    _eventsController.add(RouteActivatedEvent(route));
    
    // Wait for result (set when pop is called)
    // This is a simplification; in practice, this would be handled by the native bridge
    return route.result;
  }
  
  @override
  Future<T?> replace<T>(Route<T> route, {RouteTransition? transition}) async {
    if (_routes.isEmpty) {
      return push(route, transition: transition);
    }
    
    // Remove current route
    final oldRoute = _routes.removeLast();
    _eventsController.add(RouteRemovedEvent(oldRoute));
    
    // Add new route
    _routes.add(route);
    _eventsController.add(RouteAddedEvent(route));
    _eventsController.add(RouteActivatedEvent(route));
    
    return route.result;
  }
  
  @override
  Future<T?> replaceAll<T>(Route<T> route, {RouteTransition? transition}) async {
    // Remove all existing routes
    final oldRoutes = List<Route>.from(_routes);
    _routes.clear();
    
    for (final oldRoute in oldRoutes) {
      _eventsController.add(RouteRemovedEvent(oldRoute));
    }
    
    // Add new route
    _routes.add(route);
    _eventsController.add(RouteAddedEvent(route));
    _eventsController.add(RouteActivatedEvent(route));
    
    return route.result;
  }
  
  @override
  Future<bool> pop<T>([T? result]) async {
    if (_routes.isEmpty) {
      return false;
    }
    
    // Remove current route
    final route = _routes.removeLast();
    
    // Set result
    if (route is Route<T>) {
      route.result = result;
    }
    
    // Notify listeners
    _eventsController.add(RouteRemovedEvent(route));
    
    // Activate previous route if it exists
    if (_routes.isNotEmpty) {
      _eventsController.add(RouteActivatedEvent(_routes.last));
    }
    
    return true;
  }
  
  @override
  Future<bool> popToRoot({bool animated = true}) async {
    if (_routes.isEmpty) {
      return false;
    }
    
    if (_routes.length == 1) {
      return true; // Already at root
    }
    
    // Remove all routes except the first one
    final routesToRemove = _routes.sublist(1);
    _routes.removeRange(1, _routes.length);
    
    // Notify listeners
    for (final route in routesToRemove.reversed) {
      _eventsController.add(RouteRemovedEvent(route));
    }
    
    // Activate root route
    _eventsController.add(RouteActivatedEvent(_routes.first));
    
    return true;
  }
  
  @override
  Future<bool> popUntil(bool Function(Route route) predicate) async {
    if (_routes.isEmpty) {
      return false;
    }
    
    // Find the route that satisfies the predicate
    int index = _routes.lastIndexWhere(predicate);
    
    if (index == -1) {
      return false; // No route satisfies the predicate
    }
    
    if (index == _routes.length - 1) {
      return true; // Already at the target route
    }
    
    // Remove routes until we reach the target
    final routesToRemove = _routes.sublist(index + 1);
    _routes.removeRange(index + 1, _routes.length);
    
    // Notify listeners
    for (final route in routesToRemove.reversed) {
      _eventsController.add(RouteRemovedEvent(route));
    }
    
    // Activate the target route
    _eventsController.add(RouteActivatedEvent(_routes.last));
    
    return true;
  }
  
  @override
  void addListener(void Function(NavigationEvent) listener) {
    events.listen(listener);
  }
  
  @override
  void removeListener(void Function(NavigationEvent) listener) {
    // In a real implementation, we would need to store subscription references
    // For now, this is a no-op since we're using a broadcast stream
  }
}
