import Flutter
import UIKit
import yoga
import Foundation

// Internal class definition for supported layout properties
class SupportedLayoutsProps {
    static let supportedLayoutProps = [
        "width", "height", "minWidth", "maxWidth", "minHeight", "maxHeight",
        "margin", "marginTop", "marginRight", "marginBottom", "marginLeft",
        "marginHorizontal", "marginVertical",
        "padding", "paddingTop", "paddingRight", "paddingBottom", "paddingLeft",
        "paddingHorizontal", "paddingVertical",
        "left", "top", "right", "bottom", "position",
        "flexDirection", "justifyContent", "alignItems", "alignSelf", "alignContent",
        "flexWrap", "flex", "flexGrow", "flexShrink", "flexBasis",
        "display", "overflow", "direction", "borderWidth"
    ]
}

// For ambiguous init issue:
typealias ViewTypeInfo = (view: UIView, type: String)

/// Registry for storing and managing view references
class ViewRegistry {
    // Singleton instance
    static let shared = ViewRegistry()
    
    // Maps view IDs to views and their types
    private var registry = [String: ViewTypeInfo]()
    
    private init() {}
    
    // Register a view with ID and type
    func registerView(_ view: UIView, id: String, type: String) {
        registry[id] = (view, type)
        
        // Also register with layout manager for direct access
        DCFLayoutManager.shared.registerView(view, withId: id)
    }
    
    // Get view info by ID
    func getViewInfo(id: String) -> ViewTypeInfo? {
        return registry[id]
    }
    
    // Get view by ID
    func getView(id: String) -> UIView? {
        return registry[id]?.view
    }
    
    // Remove a view by ID
    func removeView(id: String) {
        registry.removeValue(forKey: id)
        DCFLayoutManager.shared.unregisterView(withId: id)
    }
    
    // Get all view IDs
    var allViewIds: [String] {
        return Array(registry.keys)
    }
    
    // Clean up views
    func cleanup() {
        registry.removeAll()
    }
}

