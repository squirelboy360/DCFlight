import UIKit

/// Registry for all component types
class DCMauiComponentRegistry {
    static let shared = DCMauiComponentRegistry()
    
    internal var componentTypes: [String: DCMauiComponent.Type] = [:]
    
    private init() {
        // Register all built-in components
        registerComponent("View", componentClass: DCMauiViewComponent.self)
        registerComponent("Button", componentClass: DCMauiButtonComponent.self)
        registerComponent("Text", componentClass: DCMauiTextComponent.self)
        registerComponent("Image", componentClass: DCMauiImageComponent.self)
        
        // Add debugging function to verify prop handling
        #if DEBUG
        verifyComponentPropHandling()
        #endif
    }
    
    /// Register a component type handler
    func registerComponent(_ type: String, componentClass: DCMauiComponent.Type) {
        componentTypes[type] = componentClass
        print("Registered component type: \(type)")
    }
    
    /// Get the component handler for a specific type
    func getComponentType(for type: String) -> DCMauiComponent.Type? {
        return componentTypes[type]
    }
    
    /// Get all registered component types
    var registeredTypes: [String] {
        return Array(componentTypes.keys)
    }
}
