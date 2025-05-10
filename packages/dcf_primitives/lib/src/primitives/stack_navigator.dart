import 'package:dcf_primitives/src/primitives/stack_navigator_definition.dart';
import 'package:dcflight/dcflight.dart';

/// Stack navigation bar style
enum StackNavigationBarStyle {
  /// Default bar style
  defaultStyle,
  
  /// Large title bar style
  largeTitles,
  
  /// Transparent bar style
  transparent,
}

/// Navigation route configuration for stack navigator
class StackRoute {
  /// Unique identifier for the route
  final String id;
  
  /// Title to display in the navigation bar
  final String title;
  
  /// Component to render for this route
  final VDomNode component;
  
  /// Create a stack route
  const StackRoute({
    required this.id,
    required this.title,
    required this.component,
  });
  
  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
    };
  }
}

/// Stack navigator properties
class StackNavigatorProps {
  /// Initial route ID to display
  final String initialRouteId;
  
  /// Routes configuration
  final List<StackRoute> routes;
  
  /// Whether the navigation bar is hidden
  final bool navigationBarHidden;
  
  /// Style of the navigation bar
  final StackNavigationBarStyle barStyle;
  
  /// Tint color of the navigation bar (hex color string)
  final String? barTintColor;
  
  /// Create stack navigator props
  const StackNavigatorProps({
    required this.initialRouteId,
    required this.routes,
    this.navigationBarHidden = false,
    this.barStyle = StackNavigationBarStyle.defaultStyle,
    this.barTintColor,
  });
  
  /// Convert to props map
  Map<String, dynamic> toMap() {
    return {
      'initialRouteId': initialRouteId,
      'routes': routes.map((route) => route.toMap()).toList(),
      'navigationBarHidden': navigationBarHidden,
      'barStyle': barStyle.toString().split('.').last,
      if (barTintColor != null) 'barTintColor': barTintColor,
    };
  }
}

/// Reference object to control a StackNavigator component
class StackNavigatorRef {
  final String _viewId;
  
  /// Create a stack navigator reference
  StackNavigatorRef(this._viewId);
  
  /// Push a screen onto the navigation stack
  Future<void> push(String screenId, {bool animated = true}) async {
    await DCFStackNavigatorDefinition().callMethod(
      _viewId,
      'push',
      {
        'screenId': screenId,
        'animated': animated,
      },
    );
  }
  
  /// Pop the top screen from the navigation stack
  Future<void> pop({bool animated = true}) async {
    await DCFStackNavigatorDefinition().callMethod(
      _viewId,
      'pop',
      {'animated': animated},
    );
  }
  
  /// Pop to the root screen
  Future<void> popToRoot({bool animated = true}) async {
    await DCFStackNavigatorDefinition().callMethod(
      _viewId,
      'popToRoot',
      {'animated': animated},
    );
  }
  
  /// Set whether the navigation bar is hidden
  Future<void> setNavigationBarHidden(bool hidden, {bool animated = true}) async {
    await DCFStackNavigatorDefinition().callMethod(
      _viewId,
      'setNavigationBarHidden',
      {
        'hidden': hidden,
        'animated': animated,
      },
    );
  }
  
  /// Set the title of the current screen
  Future<void> setTitle(String title) async {
    await DCFStackNavigatorDefinition().callMethod(
      _viewId,
      'setTitle',
      {'title': title},
    );
  }
}

/// Stack navigator component
class StackNavigator extends Component {
  /// Stack navigator properties
  final Map<String, dynamic> _props;
  
  /// Stack navigator reference
  final StackNavigatorRef? ref;
  
  /// Routes configuration
  final List<StackRoute> routes;
  
  /// Create a stack navigator
  StackNavigator({
    this.ref,
    required String initialRouteId,
    required this.routes,
    bool navigationBarHidden = false,
    StackNavigationBarStyle barStyle = StackNavigationBarStyle.defaultStyle,
    String? barTintColor,
    super.key,
  }) : _props = StackNavigatorProps(
         initialRouteId: initialRouteId,
         routes: routes,
         navigationBarHidden: navigationBarHidden,
         barStyle: barStyle,
         barTintColor: barTintColor,
       ).toMap();
  
  @override
  void componentDidMount() {
    // If we have a reference, register routes
    if (ref != null) {
      // Routes are already registered in the props
    }
  }
  
  @override
  VDomNode render() {
    // We need to convert the routes to components that can be rendered
    final routeComponents = routes.map((route) {
      return VDomElement(
        type: '_RouteComponent',
        props: route.toMap(),
        children: [route.component],
      );
    }).toList();
    
    return VDomElement(
      type: 'StackNavigator',
      props: {
        ..._props,
        'onNavigate': _handleNavigate,
      },
      children: routeComponents,
    );
  }
  
  /// Handle navigation events
  void _handleNavigate(Map<String, dynamic> data) {
    final String eventType = data['type'] ?? '';
    final String routeId = data['routeId'] ?? '';
    
    // Add custom event handling here if needed
    print('Navigation event: $eventType, routeId: $routeId');
  }
}
