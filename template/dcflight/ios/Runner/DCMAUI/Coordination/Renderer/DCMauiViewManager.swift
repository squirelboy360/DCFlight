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
        DCMauiLayoutManager.shared.registerView(view, withId: id)
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
        DCMauiLayoutManager.shared.unregisterView(withId: id)
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

@objc public class DCMauiNativeBridgeCoordinator: NSObject {
    // Singleton instance
    @objc public static let shared = DCMauiNativeBridgeCoordinator()
    
    // Private initializer
    private override init() {
        super.init()
        NSLog("DCMauiNativeBridgeCoordinator initialized")
    }
    
  
    // Extract layout props from props dictionary
    private func extractLayoutProps(from props: [String: Any]) -> [String: Any] {
        // No need to create an instance - access the static property directly
        let layoutPropKeys = SupportedLayoutsProps.supportedLayoutProps
        return props.filter { layoutPropKeys.contains($0.key) }
    }
    
    // Send event to Flutter - now delegates to the event handler
    @objc public func sendEvent(_ eventName: String, data: [String: Any], viewId: String) {
        // Delegate to the event handler
        DCMauiEventMethodHandler.shared.sendEvent(viewId: viewId, eventName: eventName, eventData: data)
    }
    
    // Called by FFI to initialize the native bridge
    @objc public func dcmaui_initialize() -> Int8 {
        print("DCMauiNativeBridge: initialize() called from FFI")
        // Set up any necessary initialization
        return 1
    }
    
    // Create a view with the given ID, type and properties
    @objc public func dcmaui_create_view(_ viewId: UnsafePointer<CChar>, 
                                      _ type: UnsafePointer<CChar>,
                                      _ propsJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let typeString = String(cString: type)
        let propsString = String(cString: propsJson)
        print("DCMauiNativeBridge: Creating view - ID: \(viewIdString), Type: \(typeString)")
        
        // Parse props JSON
        guard let propsData = propsString.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData) as? [String: Any] else {
            print("DCMauiNativeBridge: Failed to parse props JSON")
            return 0
        }
        
        // Get the component type from registry
        guard let componentType = DCMauiComponentRegistry.shared.getComponentType(for: typeString) else {
            print("DCMauiNativeBridge: Unknown component type: \(typeString)")
            return 0
        }
        
        // Create an instance of the component type
        let component = componentType.init()
        
        // Create the view using the component
        let view = component.createView(props: props)
        
        // Register the view
        ViewRegistry.shared.registerView(view, id: viewIdString, type: typeString)
        
        print("DCMauiNativeBridge: View created successfully: \(viewIdString)")
        return 1
    }
    
    // Update a view's properties - now uses the stored component type
    @objc public func dcmaui_update_view(_ viewId: UnsafePointer<CChar>, 
                                      _ propsJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let propsString = String(cString: propsJson)
        
        // Parse props JSON
        guard let propsData = propsString.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData) as? [String: Any],
              let viewInfo = ViewRegistry.shared.getViewInfo(id: viewIdString) else {
            return 0
        }
        
        // Get component handler by the registered type and update
        let view = viewInfo.view
        let componentType = viewInfo.type
        
        if let handlerType = DCMauiComponentRegistry.shared.getComponentType(for: componentType) {
            // Create an instance of the component handler
            let handler = handlerType.init()
            _ = handler.updateView(view, withProps: props)
            return 1
        }
        return 0
    }
    
    // Delete a view
    @objc public func dcmaui_delete_view(_ viewId: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        
        guard let viewInfo = ViewRegistry.shared.getViewInfo(id: viewIdString) else {
            print("DCMauiNativeBridge: View not found for deletion: \(viewIdString)")
            return 0
        }
        
        let view = viewInfo.view
        
        // Remove from parent view
        view.removeFromSuperview()
        
        // Clean up from registry
        ViewRegistry.shared.removeView(id: viewIdString)
        
        return 1
    }
    
    // Attach a child view to a parent view
    @objc public func dcmaui_attach_view(_ childId: UnsafePointer<CChar>,
                                      _ parentId: UnsafePointer<CChar>,
                                      _ index: Int32) -> Int8 {
        let childIdString = String(cString: childId)
        let parentIdString = String(cString: parentId)
        
        guard let childView = ViewRegistry.shared.getView(id: childIdString),
              let parentView = ViewRegistry.shared.getView(id: parentIdString) else {
            print("Failed to find child or parent view: \(childIdString) -> \(parentIdString)")
            return 0
        }
        
        // Add child to parent
        parentView.addSubview(childView)
        
        // Log the views for debugging
        print("Attaching view \(childIdString) to parent \(parentIdString)")
        
        return 1
    }
    
    // Set children for a view
    @objc public func dcmaui_set_children(_ viewId: UnsafePointer<CChar>,
                                       _ childrenJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let childrenString = String(cString: childrenJson)
        
        guard let childrenData = childrenString.data(using: .utf8),
              let childrenIds = try? JSONSerialization.jsonObject(with: childrenData) as? [String],
              let parentView = ViewRegistry.shared.getView(id: viewIdString) else {
            return 0
        }
        
        // Set z-order of children based on array order
        for (index, childId) in childrenIds.enumerated() {
            if let childView = ViewRegistry.shared.getView(id: childId) {
                parentView.insertSubview(childView, at: index)
            }
        }
        
        return 1
    }

    /// Update a view's layout directly with absolute positioning
    func updateViewLayout(viewId: String, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> Bool {
        guard let view = ViewRegistry.shared.getView(id: viewId) else {
            print("❌ Layout Error: View not found for ID \(viewId)")
            return false
        }
        
        // Debugging layout application
        print("📐 APPLYING LAYOUT: View \(viewId) - (\(left), \(top), \(width), \(height))")
        
        // Check for invalid dimensions and fix them
        var fixedWidth = width
        var fixedHeight = height
        
        // Don't allow zero or negative dimensions
        if (fixedWidth <= 0) {
            fixedWidth = view.superview?.bounds.width ?? 100
            print("⚠️ Fixed invalid width: \(width) → \(fixedWidth)")
        }
        
        if (fixedHeight <= 0) {
            // Use minimal height for UI elements
            fixedHeight = 44
            print("⚠️ Fixed invalid height: \(height) → \(fixedHeight)")
        }
        
        // Apply frame directly
        let frame = CGRect(x: left, y: top, width: fixedWidth, height: fixedHeight)
        
        // Always apply layout on main thread
        DispatchQueue.main.async {
            view.frame = frame
            
            // Force layout if needed
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            // Print actual frame after layout
            print("📏 View \(viewId) actual frame: \(view.frame)")
        }
        return true
    }
}
