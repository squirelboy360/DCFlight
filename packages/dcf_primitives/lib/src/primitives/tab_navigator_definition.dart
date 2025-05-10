import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the TabNavigator component
class DCFTabNavigatorDefinition extends ComponentDefinition {
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
  Future<dynamic> callMethod(String viewId, String methodName, Map<String, dynamic> args) async {
    switch (methodName) {
      case 'switchToTab':
        final int index = args['index'] ?? 0;
        debugPrint('Switching to tab $index in navigator $viewId');
        return super.callMethod(viewId, methodName, args);
      
      case 'switchToTabWithId':
        final String tabId = args['tabId'] ?? '';
        debugPrint('Switching to tab with ID $tabId in navigator $viewId');
        return super.callMethod(viewId, methodName, args);
      
      case 'setBadge':
        final int index = args['index'] ?? 0;
        final String? badge = args['badge'];
        debugPrint('Setting badge to "$badge" for tab $index in navigator $viewId');
        return super.callMethod(viewId, methodName, args);

      case 'setTabBarHidden':
        final bool hidden = args['hidden'] ?? false;
        final bool animated = args['animated'] ?? true;
        debugPrint('Setting tab bar hidden: $hidden in navigator $viewId, animated: $animated');
        return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}
