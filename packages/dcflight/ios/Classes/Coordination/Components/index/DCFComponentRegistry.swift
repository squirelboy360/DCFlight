import UIKit

/// Registry for all component types
class DCFComponentRegistry {
    static let shared = DCFComponentRegistry()
    
    internal var componentTypes: [String: DCFComponent.Type] = [:]
    
    private init() {
        // No built-in components are registered here
        // Module developers will register their own components
        
    }
    
    /// Register a component type handler
    func registerComponent(_ type: String, componentClass: DCFComponent.Type) {
        componentTypes[type] = componentClass
        print("Registered component type: \(type)")
    }
    
    /// Get the component handler for a specific type
    func getComponentType(for type: String) -> DCFComponent.Type? {
        return componentTypes[type]
    }
    
    /// Get all registered component types
    var registeredTypes: [String] {
        return Array(componentTypes.keys)
    }
}
