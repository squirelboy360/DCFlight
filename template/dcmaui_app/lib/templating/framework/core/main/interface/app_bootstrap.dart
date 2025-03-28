import 'package:dc_test/templating/framework/core/vdom/node/low_levels/component.dart';
import 'package:dc_test/templating/framework/core/vdom/node/low_levels/element_factory.dart';
import 'package:dc_test/templating/framework/core/vdom/node/node.dart';
import 'package:dc_test/templating/framework/core/vdom/vdom/vdom.dart';
import 'package:flutter/foundation.dart';

/// Bootstrap application components
class AppBootstrap {
  // VDOM instance for rendering
  final VDOM _vdom = VDOM();

  // Render a root component
  void renderComponent(
      Component Function() componentConstructor, String rootKey) {
    try {
      debugPrint('Bootstrap: Creating app component with key $rootKey');

      // CRITICAL FIX: Reset element counters before creating component tree
      // This ensures every render starts with a clean slate for key generation
      ElementFactory.resetElementCounters();

      // Create the component VNode
      final componentNode = ElementFactory.createComponent(
        componentConstructor,
        {'key': rootKey},
      );

      // Debug the component tree before rendering
      debugPrint('DC Bootstrap: Component tree before render:');
      debugPrint(componentConstructor().toString());

      // Render the component through the VDOM
      debugPrint('DC Bootstrap: Rendering root component');
      _vdom.render(componentNode);
    } catch (e, stack) {
      debugPrint('ERROR in renderComponent: $e');
      debugPrint('Stack trace: $stack');
    }
  }
}
