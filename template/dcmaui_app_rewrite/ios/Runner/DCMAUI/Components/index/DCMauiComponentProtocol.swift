import UIKit
import yoga

/// Protocol that all DCMAUI components must implement
protocol DCMauiComponentProtocol {
    /// Create a view from properties
    static func createView(props: [String: Any]) -> UIView
    
    /// Update an existing view with new properties
    static func updateView(_ view: UIView, props: [String: Any])
    
    /// Register event listeners for this view
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void)
    
    /// Remove event listeners from this view
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String])
    
    /// Apply layout properties to this view (optional)
    static func applyLayoutProps(_ view: UIView, props: [String: Any])
}

// Default implementation
extension DCMauiComponentProtocol {
    // Default layout implementation using DCMauiLayoutManager
    static func applyLayoutProps(_ view: UIView, props: [String: Any]) {
        DCMauiLayoutManager.shared.applyLayout(to: view, withProps: props)
    }
}

/// Registry for all component types
class DCMauiComponentRegistry {
    static let shared = DCMauiComponentRegistry()
    
    private var componentTypes: [String: DCMauiComponentProtocol.Type] = [:]
    
    private init() {
        // Register all built-in components
        registerComponent("View", componentClass: DCMauiViewComponent.self)
        registerComponent("Text", componentClass: DCMauiTextComponent.self)
        registerComponent("Button", componentClass: DCMauiButtonComponent.self)
        registerComponent("Image", componentClass: DCMauiImageComponent.self)
        registerComponent("ScrollView", componentClass: DCMauiScrollComponent.self)
        
        // You can add more components here as needed
        // The beauty is you don't need to modify the bridge code anymore
    }
    
    /// Register a component type handler
    func registerComponent(_ type: String, componentClass: DCMauiComponentProtocol.Type) {
        componentTypes[type] = componentClass
        print("Registered component type: \(type)")
    }
    
    /// Get the component handler for a specific type
    func getComponentType(for type: String) -> DCMauiComponentProtocol.Type? {
        return componentTypes[type]
    }
    
    /// Get all registered component types
    var registeredTypes: [String] {
        return Array(componentTypes.keys)
    }
}
