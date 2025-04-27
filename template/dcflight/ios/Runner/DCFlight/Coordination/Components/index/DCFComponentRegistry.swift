import UIKit

/// Registry for all component types
class DCFComponentRegistry {
    static let shared = DCFComponentRegistry()
    
    internal var componentTypes: [String: DCFComponent.Type] = [:]
    
    private init() {
        // Register all built-in components
        registerComponent("View", componentClass: DCFViewComponent.self)
        registerComponent("Button", componentClass: DCFButtonComponent.self)
        registerComponent("Text", componentClass: DCFTextComponent.self)
        registerComponent("Image", componentClass: DCFImageComponent.self)
        registerComponent("ScrollView", componentClass: DCFScrollViewComponent.self)
        
        // Add debugging function to verify prop handling
        #if DEBUG
        verifyComponentPropHandling()
        #endif
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
