import 'package:dc_test/templating/framework/core/vdom/node/node.dart';

/// Base class for all UI controls
abstract class Control {
  /// Convert this control to a VNode for rendering
  VNode build();

  /// Utility method to create node list from children controls
  List<VNode> buildChildren(List<Control> children) {
    return children.map((child) => child.build()).toList();
  }
}

/// Base class for all style properties
abstract class StyleProps {
  Map<String, dynamic> toMap();
}

/// Base class for control props
abstract class ControlProps {
  const ControlProps();

  /// Standard method to convert props to a map
  Map<String, dynamic> toMap();

  /// Utility method to identify if a property is an event handler
  static bool isEventHandler(String propName) {
    // Only rule: All event handlers start with "on" and are at least 3 chars
    return propName.startsWith('on') && propName.length > 2;
  }

  /// Normalize event name to standard format (with "on" prefix)
  // This method is now simpler since we're not supporting legacy event names
  static String normalizeEventName(String propName) {
    // We now only support properly formatted event names starting with "on"
    // This is just a pass-through since we expect all events to already start with "on"
    return propName;
  }
}
