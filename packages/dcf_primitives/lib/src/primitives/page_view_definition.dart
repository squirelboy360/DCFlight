import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the PageView component
class DCFPageViewDefinition extends ComponentDefinition {
  @override
  String get type => 'PageView';
  
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
    // Handle pageview-specific methods
    if (methodName == 'goToPage') {
      debugPrint('PageView goToPage called with args: $args');
      return super.callMethod(viewId, methodName, args);
    } else if (methodName == 'nextPage') {
      debugPrint('PageView nextPage called with args: $args');
      return super.callMethod(viewId, methodName, args);
    } else if (methodName == 'previousPage') {
      debugPrint('PageView previousPage called with args: $args');
      return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}
