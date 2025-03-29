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
        registerComponent("Button", componentClass: DCMauiButtonComponent.self)
        registerComponent("Text", componentClass: DCMauiTextComponent.self)
        registerComponent("Image", componentClass: DCMauiImageComponent.self)
        registerComponent("ScrollView", componentClass: DCMauiScrollComponent.self)
        
        // Add debugging function to verify prop handling
        #if DEBUG
        verifyComponentPropHandling()
        #endif
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
    
    #if DEBUG
    /// Debug helper to verify component prop handling
    private func verifyComponentPropHandling() {
        print("🧪 VERIFYING COMPONENT PROP HANDLING")
        
        // Check ScrollView props
        let scrollViewProps = [
            "showsVerticalScrollIndicator", "showsHorizontalScrollIndicator",
            "bounces", "pagingEnabled", "scrollEventThrottle",
            "directionalLockEnabled", "alwaysBounceVertical", 
            "alwaysBounceHorizontal", "horizontal", "flexWrap"
        ]
        checkComponentProps("ScrollView", props: scrollViewProps)
        
        // Check Text props
        let textProps = [
            "fontSize", "fontWeight", "fontFamily", "color", "textAlign",
            "letterSpacing", "lineHeight", "textDecorationLine", "numberOfLines"
        ]
        checkComponentProps("Text", props: textProps)
        
        // Check View props (most important layout props)
        let viewProps = [
            "width", "height", "backgroundColor", "borderRadius",
            "flexDirection", "flexWrap", "justifyContent", "alignItems",
            "flex", "margin", "padding", "transform", "opacity"
        ]
        checkComponentProps("View", props: viewProps)
        
        // Check Image props
        let imageProps = [
            "source", "resizeMode", "borderRadius", "width", "height"
        ]
        checkComponentProps("Image", props: imageProps)
    }
    
    /// Check if component handler contains methods to process the given props
    private func checkComponentProps(_ componentType: String, props: [String]) {
        guard let component = getComponentType(for: componentType) else {
            print("❌ Component not found: \(componentType)")
            return
        }
        
        print("🔍 Checking \(componentType) props support:")
        
        // Look for properties in the component's updateView method implementation
        let componentDescription = String(describing: component)
        for prop in props {
            // This is a simple check - just looks for the property name in the component code
            // A more sophisticated check would verify each property is actually handled
            if componentDescription.contains("\"\(prop)\"") {
                print("  ✅ \(prop)")
            } else {
                print("  ⚠️ \(prop) - no explicit handling found")
            }
        }
    }
    #endif
}