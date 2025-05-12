import 'package:dcflight/dcflight.dart';

/// Definition for the TabNavigator component
class TabNavigatorDefinition extends ComponentDefinition {
  @override
  String get type => 'TabNavigator';
  
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
    // Handle tab navigation methods
    PlatformDispatcher dispatcher = PlatformDispatcherIml();
    
    switch (methodName) {
      case 'switchTab':
        final index = args['index'] as int;
        return await dispatcher.callComponentMethod(
          viewId, 
          'switchTab',
          {'index': index},
        );
        
      case 'getSelectedIndex':
        return await dispatcher.callComponentMethod(
          viewId, 
          'getSelectedIndex',
          {},
        );
        
      default:
        return await super.callMethod(viewId, methodName, args);
    }
  }
}
