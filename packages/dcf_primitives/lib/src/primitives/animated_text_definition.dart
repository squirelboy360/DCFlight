import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the AnimatedText component
class DCFAnimatedTextDefinition extends ComponentDefinition {
  @override
  String get type => 'AnimatedText';
  
  @override
  VDomElement create(Map<String, dynamic> props, List<VDomNode> children) {
    // Extract text content
    final String content = props['content'] ?? '';
    
    // Create new props with content
    final Map<String, dynamic> finalProps = {...props};
    finalProps['content'] = content;
    
    return VDomElement(
      type: type,
      props: finalProps,
      children: children,
    );
  }
  
  @override
  Future<dynamic> callMethod(String viewId, String methodName, Map<String, dynamic> args) async {
    // Handle animation-specific methods
    if (methodName == 'setText') {
      debugPrint('AnimatedText setText called with args: $args');
      return super.callMethod(viewId, methodName, args);
    } else if (methodName == 'animate') {
      debugPrint('AnimatedText animate called with args: $args');
      return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}
