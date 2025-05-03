import 'package:dcflight/framework/protocol/component_protocol.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';

/// Definition for the ScrollView component
class DCFScrollViewDefinition extends ComponentDefinition {
  @override
  String get type => 'ScrollView';
  
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
    // Handle scrollview-specific methods
    if (methodName == 'scrollToPosition') {
      final double x = args['x'] ?? 0.0;
      final double y = args['y'] ?? 0.0;
      final bool animated = args['animated'] ?? true;
      debugPrint('Scrolling $viewId to position ($x, $y), animated: $animated');
      return super.callMethod(viewId, methodName, args);
    } else if (methodName == 'scrollToTop') {
      final bool animated = args['animated'] ?? true;
      debugPrint('Scrolling $viewId to top, animated: $animated');
      return super.callMethod(viewId, methodName, args);
    } else if (methodName == 'scrollToBottom') {
      final bool animated = args['animated'] ?? true;
      debugPrint('Scrolling $viewId to bottom, animated: $animated');
      return super.callMethod(viewId, methodName, args);
    }
    
    return super.callMethod(viewId, methodName, args);
  }
}