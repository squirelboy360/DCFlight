import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the StackNavigator component
class DCFStackNavigatorDefinition extends ComponentDefinition {
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
  Future<dynamic> callMethod(String viewId, String methodName, Map<String, dynamic> args) async {
    switch (methodName) {
      case 'push':
        final String screenId = args['screenId'] ?? '';
        final bool animated = args['animated'] ?? true;
        debugPrint('Pushing screen $screenId in navigator $viewId, animated: $animated');
        return super.callMethod(viewId, methodName, args);
      
      case 'pop':
        final bool animated = args['animated'] ?? true;
        debugPrint('Popping screen in navigator $viewId, animated: $animated');
        return super.callMethod(viewId, methodName, args);
      
      case 'popToRoot':
        final bool animated = args['animated'] ?? true;
        debugPrint('Popping to root in navigator $viewId, animated: $animated');
        return super.callMethod(viewId, methodName, args);

      case 'setNavigationBarHidden':
        final bool hidden = args['hidden'] ?? false;
        final bool animated = args['animated'] ?? true;
        debugPrint('Setting navigation bar hidden: $hidden in navigator $viewId, animated: $animated');
        return super.callMethod(viewId, methodName, args);
        
      case 'setTitle':
        final String title = args['title'] ?? '';
        debugPrint('Setting title to "$title" in navigator $viewId');
        return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}
