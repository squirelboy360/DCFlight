import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the GestureDetector component
class DCFGestureDetectorDefinition extends ComponentDefinition {
  @override
  String get type => 'GestureDetector';
  
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
    debugPrint('Method $methodName called on GestureDetector component $viewId');
    return super.callMethod(viewId, methodName, args);
  }
}
