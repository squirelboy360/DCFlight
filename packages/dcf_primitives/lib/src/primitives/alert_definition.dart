import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the Alert component
class DCFAlertDefinition extends ComponentDefinition {
  @override
  String get type => 'Alert';
  
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
      case 'show':
        debugPrint('Showing alert $viewId');
        return super.callMethod(viewId, methodName, args);
      
      case 'dismiss':
        debugPrint('Dismissing alert $viewId');
        return super.callMethod(viewId, methodName, args);
      
      case 'addAction':
        final String title = args['title'] ?? '';
        final String style = args['style'] ?? 'default';
        debugPrint('Adding "$title" action with style $style to alert $viewId');
        return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}
