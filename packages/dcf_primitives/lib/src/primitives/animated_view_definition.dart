import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the AnimatedView component
class DCFAnimatedViewDefinition extends ComponentDefinition {
  @override
  String get type => 'AnimatedView';
  
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
    // Handle animation-specific methods
    if (methodName == 'animate') {
      debugPrint('AnimatedView animate called with args: $args');
      return super.callMethod(viewId, methodName, args);
    } else if (methodName == 'reset') {
      debugPrint('AnimatedView reset called with args: $args');
      return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}
