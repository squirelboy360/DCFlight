import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the Button component
class DCFButtonDefinition extends ComponentDefinition {
  @override
  String get type => 'Button';
  
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
    // Handle button-specific methods
    if (methodName == 'setHighlighted') {
      // This method will be handled by the native implementation
      return super.callMethod(viewId, methodName, args);
    } else if (methodName == 'performClick') {
      // Simulate button click
      debugPrint('Button $viewId clicked programmatically');
      return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}