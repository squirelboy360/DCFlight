import 'package:dcflight/framework/renderer/vdom/vdom_element.dart';
import 'package:dcflight/framework/renderer/vdom/vdom_node.dart';
import 'package:flutter/foundation.dart';
import 'component_protocol.dart';

/// Registry for component factories
/// This allows components to be registered with the framework
/// without requiring the framework to know about their specific implementations
class ComponentRegistry {
  /// Singleton instance for global access
  static final ComponentRegistry instance = ComponentRegistry._();
  
  /// Private constructor for singleton
  ComponentRegistry._();
  
  /// Map of component factories by type
  final Map<String, ComponentFactory> _factories = {};
  
  /// Map of component definitions by type
  final Map<String, ComponentDefinition> _definitions = {};
  
  /// Register a component factory and definition
  void registerComponent(String type, ComponentFactory factory, [ComponentDefinition? definition]) {
    _factories[type] = factory;
    
    if (definition != null) {
      _definitions[type] = definition;
    }
    
    debugPrint('Registered component: $type');
  }
  
  /// Register a component definition
  void registerComponentDefinition(ComponentDefinition definition) {
    _definitions[definition.type] = definition;
    
    // Also register the factory function
    _factories[definition.type] = definition.create;
    debugPrint('Registered component definition: ${definition.type}');
  }
  
  /// Get a component factory by type
  ComponentFactory? getFactory(String type) {
    return _factories[type];
  }
  
  /// Get a component definition by type
  ComponentDefinition? getDefinition(String type) {
    return _definitions[type];
  }
  
  /// Check if a component type is registered
  bool hasComponent(String type) {
    return _factories.containsKey(type);
  }
  
  /// Get all registered component types
  List<String> get registeredTypes {
    return _factories.keys.toList();
  }
  
  /// Create a component instance with the given type, props and children
  VDomElement create(String type, Map<String, dynamic> props, List<VDomNode> children) {
    final factory = _factories[type];
    if (factory == null) {
      throw Exception('Component factory not found: $type');
    }
    
    return factory(props, children);
  }
  
  /// Call a method on a component instance
  Future<dynamic> callMethod(String type, String viewId, String methodName, Map<String, dynamic> args) async {
    final definition = _definitions[type];
    if (definition == null) {
      debugPrint('Component definition not found for method call: $type');
      return null;
    }
    
    return definition.callMethod(viewId, methodName, args);
  }
}