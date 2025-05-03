import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the Text component
class DCFTextDefinition extends ComponentDefinition {
  @override
  String get type => 'Text';
  
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
    // Handle text-specific methods
    if (methodName == 'setText') {
      // This method will be handled by the native implementation
      final String newText = args['text'] ?? '';
      debugPrint('Setting text on $viewId: $newText');
      return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}