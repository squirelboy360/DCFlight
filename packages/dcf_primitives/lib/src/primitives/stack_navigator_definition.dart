import 'package:dcflight/dcflight.dart';

/// Definition for the StackNavigator component
class StackNavigatorDefinition extends ComponentDefinition {
  @override
  String get type => 'StackNavigator';
  
  @override
  VDomElement create(Map<String, dynamic> props, List<VDomNode> children) {
    return VDomElement(
      type: type,
      props: props,
      children: children,
    );
  }
  
  @override
  Future<dynamic> callMethod(
    String viewId, 
    String methodName, 
    Map<String, dynamic> args
  ) async {
    // Handle stack navigation methods
    PlatformDispatcher dispatcher = PlatformDispatcherIml();
    
    switch (methodName) {
      case 'push':
        final routeInfo = args['route'] as Map<String, dynamic>;
        final transition = args['transition'] as Map<String, dynamic>?;
        return await dispatcher.callComponentMethod(
          viewId, 
          'push',
          {
            'routeInfo': routeInfo,
            'transition': transition,
          },
        );
        
      case 'pop':
        final result = args['result'];
        return await dispatcher.callComponentMethod(
          viewId, 
          'pop',
          {'result': result},
        );
        
      case 'popToRoot':
        final animated = args['animated'] as bool? ?? true;
        return await dispatcher.callComponentMethod(
          viewId, 
          'popToRoot',
          {'animated': animated},
        );
        
      case 'replace':
        final routeInfo = args['route'] as Map<String, dynamic>;
        final transition = args['transition'] as Map<String, dynamic>?;
        return await dispatcher.callComponentMethod(
          viewId, 
          'replace',
          {
            'routeInfo': routeInfo,
            'transition': transition,
          },
        );
        
      default:
        return await super.callMethod(viewId, methodName, args);
    }
  }
}
