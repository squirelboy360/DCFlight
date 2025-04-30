import 'package:flutter/foundation.dart';

import '../renderer/vdom/vdom_node.dart';
import '../renderer/vdom/vdom_element.dart';

/// Type definition for a component factory function
/// This will be used to register component factories with the framework
typedef ComponentFactory = VDomElement Function(Map<String, dynamic> props, List<VDomNode> children);

/// Interface for component definitions
/// This allows the framework to work with components without knowing their specific implementation
abstract class ComponentDefinition {
  /// The type identifier for this component
  String get type;
  
  /// Create a component instance with the given props and children
  VDomElement create(Map<String, dynamic> props, List<VDomNode> children);
  
  /// Call a method on a component instance
  Future<dynamic> callMethod(String viewId, String methodName, Map<String, dynamic> args) async {
    debugPrint('Method $methodName called on $type component $viewId');
    return null;
  }
}

/// Base class for component property definitions
abstract class ComponentProps {
  /// Convert the props to a map for serialization
  Map<String, dynamic> toMap();
  
  /// Create a new instance by merging with another instance
  ComponentProps merge(ComponentProps other);
  
  /// Clone with some properties changed
  ComponentProps copyWith();
}