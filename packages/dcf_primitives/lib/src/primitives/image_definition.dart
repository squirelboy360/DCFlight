import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the Image component
class DCFImageDefinition extends ComponentDefinition {
  @override
  String get type => 'Image';
  
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
    // Handle image-specific methods
    if (methodName == 'setImage') {
      final String uri = args['uri'] ?? '';
      debugPrint('Setting image on $viewId: $uri');
      return super.callMethod(viewId, methodName, args);
    } else if (methodName == 'reload') {
      debugPrint('Reloading image $viewId');
      return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}