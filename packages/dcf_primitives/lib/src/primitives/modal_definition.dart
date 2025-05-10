import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the Modal component
class DCFModalDefinition extends ComponentDefinition {
  @override
  String get type => 'Modal';
  
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
      case 'present':
        final bool animated = args['animated'] ?? true;
        debugPrint('Presenting modal $viewId, animated: $animated');
        return super.callMethod(viewId, methodName, args);
      
      case 'dismiss':
        final bool animated = args['animated'] ?? true;
        debugPrint('Dismissing modal $viewId, animated: $animated');
        return super.callMethod(viewId, methodName, args);
      
      case 'setBackdropOpacity':
        final double opacity = args['opacity'] ?? 0.5;
        debugPrint('Setting backdrop opacity to $opacity for modal $viewId');
        return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}
