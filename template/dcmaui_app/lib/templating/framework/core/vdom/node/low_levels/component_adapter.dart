import 'package:dc_test/templating/framework/core/vdom/node/low_levels/control.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:flutter/foundation.dart';

/// ComponentAdapter bridges between VNode components and Controls
/// This allows Components to be included in the Control tree
class ComponentAdapter extends Control {
  final VNode componentNode;

  ComponentAdapter(this.componentNode);

  @override
  VNode build() {
    // CRITICAL FIX: Add better logging
    debugPrint(
        'ComponentAdapter: Building VNode of type ${componentNode.type} with key ${componentNode.key}');

    // CRITICAL FIX: Make sure the component node has a proper key and add trace info
    if (componentNode.key.isEmpty || componentNode.key == 'null') {
      debugPrint(
          'ComponentAdapter: WARNING - Component has no key, generating one');
      final newKey = 'adapter_${identityHashCode(this)}';

      // Create a new VNode with the same properties but a valid key
      final enhancedNode = VNode(
        componentNode.type,
        props: Map<String, dynamic>.from(componentNode.props)
          ..['_adapted'] = true // Mark as processed by adapter
          ..['_originalType'] = componentNode.type,
        children: componentNode.children,
        key: newKey,
      );

      debugPrint('ComponentAdapter: Created enhanced node with key $newKey');
      return enhancedNode;
    }

    // CRITICAL FIX: Add trace info but preserve the original node
    final enhancedProps = Map<String, dynamic>.from(componentNode.props)
      ..['_adapted'] = true;

    // Pass through the component node with enhanced props
    return VNode(
      componentNode.type,
      props: enhancedProps,
      children: componentNode.children,
      key: componentNode.key,
    );
  }
}
