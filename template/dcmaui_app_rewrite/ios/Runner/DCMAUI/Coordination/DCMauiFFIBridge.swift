import UIKit
import Foundation

/// Bridge between Dart FFI and native Swift/Objective-C code
@objc class DCMauiFFIBridge: NSObject {
    
    // Singleton instance
    @objc static let shared = DCMauiFFIBridge()
    
    // Main queue for UI operations
    private let mainQueue = DispatchQueue.main
    
    // Dictionary to hold view references
    private var views = [String: UIView]()
    
    // Private initializer for singleton
    private override init() {
        super.init()
        NSLog("DCMauiFFIBridge initialized")
    }
    
    // MARK: - FFI Implementation Functions
    
    /// Initialize the framework
    @objc func initialize() -> Bool {
        NSLog("DCMauiFFIBridge: initialize called")
        return true
    }
    
    /// Create a view with properties
    @objc func createView(viewId: String, viewType: String, propsJson: String) -> Bool {
        NSLog("DCMauiFFIBridge: createView called for \(viewId) of type \(viewType)")
        NSLog("DCMauiFFIBridge: With details \(propsJson)")
        
        var success = false
        
        // Parse props JSON
        guard let propsData = propsJson.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData, options: []) as? [String: Any] else {
            NSLog("Failed to parse props JSON: \(propsJson)")
            return false
        }
        
        // Execute on main queue
        if Thread.isMainThread {
            // If already on main thread, execute directly
            success = createViewOnMainThread(viewId: viewId, viewType: viewType, props: props)
        } else {
            // Use async and wait for result if not on main thread
            let semaphore = DispatchSemaphore(value: 0)
            mainQueue.async {
                success = self.createViewOnMainThread(viewId: viewId, viewType: viewType, props: props)
                semaphore.signal()
            }
            semaphore.wait()
        }
        
        return success
    }
    
    /// Helper method to create view on main thread
    private func createViewOnMainThread(viewId: String, viewType: String, props: [String: Any]) -> Bool {
        // Create the view through the component registry
        guard let componentType = DCMauiComponentRegistry.shared.getComponentType(for: viewType) else {
            NSLog("Component not found for type: \(viewType)")
            return false
        }
        
        // Create component instance
        let componentInstance = componentType.init()
        
        // Create view
        let view = componentInstance.createView(props: props)
        
        // Store view reference
        self.views[viewId] = view
        
        // Create a node in the shadow tree
        YogaShadowTree.shared.createNode(id: viewId, componentType: viewType)
        
        // Register view with layout system
        DCMauiLayoutManager.shared.registerView(view, withNodeId: viewId, componentType: viewType, componentInstance: componentInstance)
        
        // Apply layout props if any
        let layoutProps = self.extractLayoutProps(from: props)
        if !layoutProps.isEmpty {
            DCMauiLayoutManager.shared.updateNodeWithLayoutProps(
                nodeId: viewId,
                componentType: viewType,
                props: layoutProps
            )
        }
        
        return true
    }
    
    /// Update a view's properties
    @objc func updateView(viewId: String, propsJson: String) -> Bool {
        NSLog("DCMauiFFIBridge: updateView called for \(viewId)")
        
        var success = false
        
        // Parse props JSON
        guard let propsData = propsJson.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData, options: []) as? [String: Any] else {
            NSLog("Failed to parse props JSON: \(propsJson)")
            return false
        }
        
        // Execute on main thread safely
        if Thread.isMainThread {
            success = updateViewOnMainThread(viewId: viewId, props: props)
        } else {
            let semaphore = DispatchSemaphore(value: 0)
            mainQueue.async {
                success = self.updateViewOnMainThread(viewId: viewId, props: props)
                semaphore.signal()
            }
            semaphore.wait()
        }
        
        return success
    }
    
    /// Helper method to update view on main thread
    private func updateViewOnMainThread(viewId: String, props: [String: Any]) -> Bool {
        var success = false
        
        // Get the view
        guard let view = self.views[viewId] else {
            NSLog("View not found with ID: \(viewId)")
            return false
        }
        
        // Separate layout props from other props
        let layoutProps = self.extractLayoutProps(from: props)
        let nonLayoutProps = props.filter { !layoutProps.keys.contains($0.key) }
        
        // Update layout props if any
        if !layoutProps.isEmpty {
            // Apply to shadow tree which will trigger layout calculation
            DCMauiLayoutManager.shared.updateNodeWithLayoutProps(
                nodeId: viewId,
                componentType: String(describing: type(of: view)), // Use class name as component type
                props: layoutProps
            )
        }
        
        // Update non-layout props
        if !nonLayoutProps.isEmpty {
            // Find component type for this view class
            let viewClassName = String(describing: type(of: view))
            
            // Look up component type in registry
            var componentFound = false
            
            // Try to find component based on view class name
            for (componentName, componentType) in DCMauiComponentRegistry.shared.componentTypes {
                let tempInstance = componentType.init()
                let tempView = tempInstance.createView(props: [:])
                
                if String(describing: type(of: tempView)) == viewClassName {
                    // Found matching component, update view
                    success = tempInstance.updateView(view, withProps: nonLayoutProps)
                    componentFound = true
                    break
                }
            }
            
            if !componentFound {
                NSLog("Component not found for view class: \(viewClassName)")
            }
        } else {
            success = true // No non-layout props to update
        }
        
        return success
    }
    
    /// Delete a view
    @objc func deleteView(viewId: String) -> Bool {
        NSLog("DCMauiFFIBridge: deleteView called for \(viewId)")
        
        var success = false
        
        // Execute on main thread safely
        if Thread.isMainThread {
            success = deleteViewOnMainThread(viewId: viewId)
        } else {
            let semaphore = DispatchSemaphore(value: 0)
            mainQueue.async {
                success = self.deleteViewOnMainThread(viewId: viewId)
                semaphore.signal()
            }
            semaphore.wait()
        }
        
        return success
    }
    
    /// Helper method to delete view on main thread
    private func deleteViewOnMainThread(viewId: String) -> Bool {
        // Get the view
        guard let view = self.views[viewId] else {
            NSLog("View not found with ID: \(viewId)")
            return false
        }
        
        // Remove view from hierarchy
        view.removeFromSuperview()
        
        // Remove view reference
        self.views.removeValue(forKey: viewId)
        
        // Remove node from shadow tree
        DCMauiLayoutManager.shared.removeNode(nodeId: viewId)
        
        return true
    }
    
    /// Attach a child view to a parent view
    @objc func attachView(childId: String, parentId: String, index: Int) -> Bool {
        NSLog("DCMauiFFIBridge: attachView called for child \(childId) to parent \(parentId) at index \(index)")
        
        var success = false
        
        // Execute on main thread safely
        if Thread.isMainThread {
            success = attachViewOnMainThread(childId: childId, parentId: parentId, index: index)
        } else {
            let semaphore = DispatchSemaphore(value: 0)
            mainQueue.async {
                success = self.attachViewOnMainThread(childId: childId, parentId: parentId, index: index)
                semaphore.signal()
            }
            semaphore.wait()
        }
        
        return success
    }
    
    /// Helper method to attach view on main thread
    private func attachViewOnMainThread(childId: String, parentId: String, index: Int) -> Bool {
        // Get the views
        guard let childView = self.views[childId], let parentView = self.views[parentId] else {
            NSLog("Child or parent view not found")
            return false
        }
        
        // Add child to parent in view hierarchy
        parentView.insertSubview(childView, at: index)
        
        // Update shadow tree
        DCMauiLayoutManager.shared.addChildNode(parentId: parentId, childId: childId, index: index)
        
        return true
    }
    
    /// Set all children for a view
    @objc func setChildren(viewId: String, childrenJson: String) -> Bool {
        NSLog("DCMauiFFIBridge: setChildren called for \(viewId)")
        
        // Parse children JSON
        guard let childrenData = childrenJson.data(using: .utf8),
              let childrenIds = try? JSONSerialization.jsonObject(with: childrenData, options: []) as? [String] else {
            NSLog("Failed to parse children JSON: \(childrenJson)")
            return false
        }
        
        var success = false
        
        // Execute on main thread safely
        if Thread.isMainThread {
            success = setChildrenOnMainThread(viewId: viewId, childrenIds: childrenIds)
        } else {
            let semaphore = DispatchSemaphore(value: 0)
            mainQueue.async {
                success = self.setChildrenOnMainThread(viewId: viewId, childrenIds: childrenIds)
                semaphore.signal()
            }
            semaphore.wait()
        }
        
        return success
    }
    
    /// Helper method to set children on main thread
    private func setChildrenOnMainThread(viewId: String, childrenIds: [String]) -> Bool {
        // Get the parent view
        guard let parentView = self.views[viewId] else {
            NSLog("Parent view not found with ID: \(viewId)")
            return false
        }
        
        // Remove all existing subviews
        for subview in parentView.subviews {
            subview.removeFromSuperview()
        }
        
        // Add children in order
        for (index, childId) in childrenIds.enumerated() {
            if let childView = self.views[childId] {
                parentView.insertSubview(childView, at: index)
                
                // Update shadow tree
                DCMauiLayoutManager.shared.addChildNode(parentId: viewId, childId: childId, index: index)
            }
        }
        
        return true
    }
    
    /// Apply layout to a view directly (legacy method for backward compatibility)
    @objc func updateViewLayout(viewId: String, left: Float, top: Float, width: Float, height: Float) -> Bool {
        NSLog("DCMauiFFIBridge: updateViewLayout called for \(viewId)")
        
        var success = false
        
        // Execute on main thread safely
        if Thread.isMainThread {
            success = updateViewLayoutOnMainThread(viewId: viewId, left: left, top: top, width: width, height: height)
        } else {
            let semaphore = DispatchSemaphore(value: 0)
            mainQueue.async {
                success = self.updateViewLayoutOnMainThread(viewId: viewId, left: left, top: top, width: width, height: height)
                semaphore.signal()
            }
            semaphore.wait()
        }
        
        return success
    }
    
    /// Helper method to update view layout on main thread
    private func updateViewLayoutOnMainThread(viewId: String, left: Float, top: Float, width: Float, height: Float) -> Bool {
        // Get the view
        guard let view = self.views[viewId] else {
            NSLog("View not found with ID: \(viewId)")
            return false
        }
        
        // Apply layout directly (for backward compatibility only)
        view.frame = CGRect(
            x: CGFloat(left),
            y: CGFloat(top),
            width: CGFloat(width),
            height: CGFloat(height)
        )
        
        return true
    }
    
    /// Measure text
    @objc func measureText(viewId: String, text: String, attributesJson: String) -> String {
        NSLog("DCMauiFFIBridge: measureText called for \(viewId)")
        
        // Parse attributes JSON
        guard let attributesData = attributesJson.data(using: .utf8),
              let attributes = try? JSONSerialization.jsonObject(with: attributesData, options: []) as? [String: Any] else {
            return "{\"width\":0.0,\"height\":0.0}"
        }
        
        var result = "{\"width\":0.0,\"height\":0.0}"
        
        // Execute on main thread safely
        if Thread.isMainThread {
            result = measureTextOnMainThread(viewId: viewId, text: text, attributes: attributes)
        } else {
            let semaphore = DispatchSemaphore(value: 0)
            mainQueue.async {
                result = self.measureTextOnMainThread(viewId: viewId, text: text, attributes: attributes)
                semaphore.signal()
            }
            semaphore.wait()
        }
        
        return result
    }
    
    /// Helper method to measure text on main thread
    private func measureTextOnMainThread(viewId: String, text: String, attributes: [String: Any]) -> String {
        // Get the view
        guard let view = self.views[viewId] else {
            NSLog("View not found with ID: \(viewId)")
            return "{\"width\":0.0,\"height\":0.0}"
        }
        
        // Find component type for this view class
        let viewClassName = String(describing: type(of: view))
        var size = CGSize.zero
        
        // Try to find component based on view class
        for (_, componentType) in DCMauiComponentRegistry.shared.componentTypes {
            let tempInstance = componentType.init()
            let tempView = tempInstance.createView(props: [:])
            
            if String(describing: type(of: tempView)) == viewClassName {
                // Found matching component, use it to measure text
                let props = attributes.merging(["text": text]) { (_, new) in new }
                size = tempInstance.getIntrinsicSize(view, forProps: props)
                break
            }
        }
        
        // Convert result to JSON
        return "{\"width\":\(size.width),\"height\":\(size.height)}"
    }
    
    // MARK: - Helper Methods
    
    /// Extract layout properties from props dictionary
    private func extractLayoutProps(from props: [String: Any]) -> [String: Any] {
        let layoutPropKeys = [
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
        
        return props.filter { layoutPropKeys.contains($0.key) }
    }
}

// MARK: - C FFI Interface Functions

@_cdecl("dcmaui_initialize_impl")
public func dcmaui_initialize_impl() -> Int8 {
    return DCMauiFFIBridge.shared.initialize() ? 1 : 0
}

@_cdecl("dcmaui_create_view_impl")
public func dcmaui_create_view_impl(
    view_id: UnsafePointer<CChar>,
    view_type: UnsafePointer<CChar>,
    props_json: UnsafePointer<CChar>
) -> Int8 {
    let viewId = String(cString: view_id)
    let viewType = String(cString: view_type)
    let propsJson = String(cString: props_json)
    
    return DCMauiFFIBridge.shared.createView(viewId: viewId, viewType: viewType, propsJson: propsJson) ? 1 : 0
}

@_cdecl("dcmaui_update_view_impl")
public func dcmaui_update_view_impl(
    view_id: UnsafePointer<CChar>,
    props_json: UnsafePointer<CChar>
) -> Int8 {
    let viewId = String(cString: view_id)
    let propsJson = String(cString: props_json)
    
    return DCMauiFFIBridge.shared.updateView(viewId: viewId, propsJson: propsJson) ? 1 : 0
}

@_cdecl("dcmaui_delete_view_impl")
public func dcmaui_delete_view_impl(view_id: UnsafePointer<CChar>) -> Int8 {
    let viewId = String(cString: view_id)
    
    return DCMauiFFIBridge.shared.deleteView(viewId: viewId) ? 1 : 0
}

@_cdecl("dcmaui_attach_view_impl")
public func dcmaui_attach_view_impl(
    child_id: UnsafePointer<CChar>,
    parent_id: UnsafePointer<CChar>,
    index: Int32
) -> Int8 {
    let childId = String(cString: child_id)
    let parentId = String(cString: parent_id)
    
    return DCMauiFFIBridge.shared.attachView(childId: childId, parentId: parentId, index: Int(index)) ? 1 : 0
}

@_cdecl("dcmaui_set_children_impl")
public func dcmaui_set_children_impl(
    view_id: UnsafePointer<CChar>,
    children_json: UnsafePointer<CChar>
) -> Int8 {
    let viewId = String(cString: view_id)
    let childrenJson = String(cString: children_json)
    
    return DCMauiFFIBridge.shared.setChildren(viewId: viewId, childrenJson: childrenJson) ? 1 : 0
}

@_cdecl("dcmaui_update_view_layout_impl")
public func dcmaui_update_view_layout_impl(
    view_id: UnsafePointer<CChar>,
    left: Float,
    top: Float,
    width: Float,
    height: Float
) -> Int8 {
    let viewId = String(cString: view_id)
    
    return DCMauiFFIBridge.shared.updateViewLayout(
        viewId: viewId,
        left: left,
        top: top,
        width: width,
        height: height
    ) ? 1 : 0
}

@_cdecl("dcmaui_measure_text_impl")
public func dcmaui_measure_text_impl(
    view_id: UnsafePointer<CChar>,
    text: UnsafePointer<CChar>,
    attributes_json: UnsafePointer<CChar>
) -> UnsafePointer<CChar> {
    let viewId = String(cString: view_id)
    let textString = String(cString: text)
    let attributesJson = String(cString: attributes_json)
    
    let result = DCMauiFFIBridge.shared.measureText(
        viewId: viewId,
        text: textString,
        attributesJson: attributesJson
    )
    
    // Convert to C string
    let resultCStr = strdup(result)
    return UnsafePointer(resultCStr!)
}
