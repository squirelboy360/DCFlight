import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';

/// Represents a route in the navigation system
class Route<T> {
  /// Unique identifier for this route
  final String id;
  
  /// The name of the route
  final String name;
  
  /// Parameters for this route
  final Map<String, dynamic> params;
  
  /// Result data when the route is popped
  T? result;
  
  /// Create a new route
  Route({
    required this.name,
    this.params = const {},
    String? id,
  }) : id = id ?? '${name}_${DateTime.now().millisecondsSinceEpoch}';
  
  @override
  String toString() => 'Route(name: $name, params: $params)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Route && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}

/// Creates a route builder that can instantiate routes with parameters
typedef RouteBuilder = Route Function(Map<String, dynamic> params);

/// Creates a screen builder that can render a screen based on route information
typedef ScreenBuilder = VDomNode Function(RouteContext context);

/// Context provided to screen builders
class RouteContext {
  /// The current route
  final Route route;
  
  /// Navigation controller for this route
  final dynamic navigator;
  
  /// Create a new route context
  RouteContext(this.route, this.navigator);
  
  /// Get route parameters
  Map<String, dynamic> get params => route.params;
}

/// Type of route transition animation
enum RouteTransitionType {
  /// Default platform-specific transition
  platform,
  
  /// Fade transition
  fade,
  
  /// Slide from right transition
  slideRight,
  
  /// Slide from left transition
  slideLeft,
  
  /// Slide from top transition
  slideTop,
  
  /// Slide from bottom transition
  slideBottom,
  
  /// No transition animation
  none,
}

/// Route transition configuration
class RouteTransition {
  /// Type of transition animation
  final RouteTransitionType type;
  
  /// Duration of the transition in milliseconds
  final int durationMs;
  
  /// Create a route transition
  const RouteTransition({
    this.type = RouteTransitionType.platform,
    this.durationMs = 300,
  });
  
  /// Convert to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'durationMs': durationMs,
    };
  }
}
