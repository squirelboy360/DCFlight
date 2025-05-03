import UIKit
import Foundation

/// Bridge between Dart FFI and native Swift/Objective-C code
/// Simplified version that focuses on core view operations
@objc class DCMauiBridgeImpl: NSObject {
    
    // Singleton instance
    @objc static let shared = DCMauiBridgeImpl()
    
    // Dictionary to hold view references
    internal var views = [String: UIView]()
    
    // Track parent-child relationships for proper cleanup
    private var viewHierarchy = [String: [String]]() // parent ID -> child IDs
    private var childToParent = [String: String]() // child ID -> parent ID
    
    // Private initializer for singleton
    private override init() {
        super.init()
        NSLog("DCMauiFFIBridge initialized (simplified version)")
    }
    
    // MARK: - Public Registration Methods
    
    /// Register a pre-existing view with the bridge
    @objc func registerView(_ view: UIView, withId viewId: String) {
        NSLog("DCMauiFFIBridge: Registering view with ID: \(viewId)")
        views[viewId] = view
        ViewRegistry.shared.registerView(view, id: viewId, type: "View")
        DCFLayoutManager.shared.registerView(view, withId: viewId)
    }
    
    /// Initialize the framework
    @objc func initialize() -> Bool {
        NSLog("DCMauiFFIBridge: initialize called")
        
        // Check if root view exists already
        if let rootView = views["root"] {
            NSLog("DCMauiFFIBridge: Found pre-registered root view: \(rootView)")
            
            // Ensure the root view is registered with the shadow tree
            if YogaShadowTree.shared.nodes["root"] == nil {
                YogaShadowTree.shared.createNode(id: "root", componentType: "View")
                NSLog("DCMauiFFIBridge: Created root node in shadow tree")
            }
        } else {
            NSLog("DCMauiFFIBridge: Warning - No root view registered yet")
        }
        
        return true
    }
    
    /// Create a view with properties
    @objc func createView(viewId: String, viewType: String, propsJson: String) -> Bool {
        NSLog("DCMauiFFIBridge: createView called for \(viewId) of type \(viewType)")
        
        // Parse props JSON
        guard let propsData = propsJson.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData, options: []) as? [String: Any] else {
            NSLog("Failed to parse props JSON: \(propsJson)")
            return false
        }
        
        // Create the component instance
        guard let componentType = DCFComponentRegistry.shared.getComponentType(for: viewType) else {
            NSLog("Component not found for type: \(viewType)")
            return false
        }
        
        // Create component instance
        let componentInstance = componentType.init()
        
        // Create view
        let view = componentInstance.createView(props: props)
        
        // Store view reference
        views[viewId] = view
        
        // Create a node in the shadow tree
        YogaShadowTree.shared.createNode(id: viewId, componentType: viewType)
        
        // Register view with layout system
        DCFLayoutManager.shared.registerView(view, withNodeId: viewId, componentType: viewType, componentInstance: componentInstance)
        ViewRegistry.shared.registerView(view, id: viewId, type: viewType)
        
        // Apply layout props if any
        let layoutProps = extractLayoutProps(from: props)
        if !layoutProps.isEmpty {
            DCFLayoutManager.shared.updateNodeWithLayoutProps(
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
        
        // Parse props JSON
        guard let propsData = propsJson.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData, options: []) as? [String: Any] else {
            NSLog("Failed to parse props JSON: \(propsJson)")
            return false
        }
        
        // Find the view in all possible registries
        var view = self.views[viewId]
        
        if view == nil {
            view = ViewRegistry.shared.getView(id: viewId) ?? DCFLayoutManager.shared.getView(withId: viewId)
            
            // If found in another registry, update our registry
            if let foundView = view {
                self.views[viewId] = foundView
            }
        }
        
        guard let finalView = view else {
            NSLog("View not found with ID: \(viewId)")
            return false
        }
        
        // Separate layout props from other props
        let layoutProps = self.extractLayoutProps(from: props)
        let nonLayoutProps = props.filter { !layoutProps.keys.contains($0.key) }
        
        // Update layout props if any
        if !layoutProps.isEmpty {
            DCFLayoutManager.shared.updateNodeWithLayoutProps(
                nodeId: viewId,
                componentType: String(describing: type(of: finalView)),
                props: layoutProps
            )
        }
        
        // Update non-layout props
        var success = true
        if !nonLayoutProps.isEmpty {
            // Find component type for this view class
            let viewClassName = String(describing: type(of: finalView))
            
            // Try to find component based on view class name
            var componentFound = false
            for (componentName, componentType) in DCFComponentRegistry.shared.componentTypes {
                let tempInstance = componentType.init()
                let tempView = tempInstance.createView(props: [:])
                
                if String(describing: type(of: tempView)) == viewClassName {
                    // Found matching component, update view
                    success = tempInstance.updateView(finalView, withProps: nonLayoutProps)
                    componentFound = true
                    NSLog("Found component \(componentName) for view class: \(viewClassName)")
                    break
                }
            }
            
            if !componentFound {
                NSLog("Component not found for view class: \(viewClassName)")
                success = false
            }
        }
        
        return success
    }
    
    /// Delete a view
    @objc func deleteView(viewId: String) -> Bool {
        NSLog("DCMauiFFIBridge: deleteView called for \(viewId)")
        
        // Try to find the view in any registry
        var view = self.views[viewId]
        
        if view == nil {
            view = ViewRegistry.shared.getView(id: viewId) ?? DCFLayoutManager.shared.getView(withId: viewId)
        }
        
        guard let finalView = view else {
            NSLog("View not found with ID: \(viewId)")
            
            // Even if view is not found, still clean up any children
            // This handles the case where a parent was removed but children still exist in registries
            cleanupOrphanedChildren(parentId: viewId)
            return false
        }
        
        // First, recursively delete all children
        deleteChildrenRecursively(parentId: viewId)
        
        // Then remove the view itself from hierarchy
        finalView.removeFromSuperview()
        
        // Remove from all registries
        self.views.removeValue(forKey: viewId)
        ViewRegistry.shared.removeView(id: viewId)
        YogaShadowTree.shared.removeNode(nodeId: viewId)
        DCFLayoutManager.shared.unregisterView(withId: viewId)
        
        // Remove from hierarchy tracking
        let parentId = childToParent[viewId]
        if let parentId = parentId {
            viewHierarchy[parentId]?.removeAll(where: { $0 == viewId })
        }
        childToParent.removeValue(forKey: viewId)
        viewHierarchy.removeValue(forKey: viewId)
        
        return true
    }
    
    /// Recursively delete all children of a view
    private func deleteChildrenRecursively(parentId: String) {
        // Get children for this parent
        guard let children = viewHierarchy[parentId], !children.isEmpty else {
            return
        }
        
        NSLog("🧹 Cleaning up \(children.count) children of view \(parentId)")
        
        // Make a copy to avoid modification during iteration
        let childrenCopy = children
        
        // Process each child
        for childId in childrenCopy {
            // Recursively delete grandchildren first
            deleteChildrenRecursively(parentId: childId)
            
            // Now delete the child view
            if let childView = self.views[childId] {
                childView.removeFromSuperview()
                
                // Remove from registries
                self.views.removeValue(forKey: childId)
                ViewRegistry.shared.removeView(id: childId)
                YogaShadowTree.shared.removeNode(nodeId: childId)
                DCFLayoutManager.shared.unregisterView(withId: childId)
                
                NSLog("🗑️ Removed child view: \(childId)")
            }
            
            // Update tracking
            childToParent.removeValue(forKey: childId)
        }
        
        // Clear the children array for this parent
        viewHierarchy[parentId] = []
    }
    
    /// Clean up any orphaned children if parent is no longer in registry
    private func cleanupOrphanedChildren(parentId: String) {
        // Check if we have children records for this parent
        guard let children = viewHierarchy[parentId], !children.isEmpty else {
            return
        }
        
        NSLog("🧹 Cleaning up orphaned children of missing view \(parentId)")
        
        // Make a copy to avoid modification during iteration
        let childrenCopy = children
        
        // Process each child
        for childId in childrenCopy {
            // Recursively delete grandchildren first
            deleteChildrenRecursively(parentId: childId)
            
            // Now delete the child view from registries
            if let childView = self.views[childId] {
                childView.removeFromSuperview()
                self.views.removeValue(forKey: childId)
            }
            ViewRegistry.shared.removeView(id: childId)
            YogaShadowTree.shared.removeNode(nodeId: childId)
            DCFLayoutManager.shared.unregisterView(withId: childId)
            
            NSLog("🗑️ Removed orphaned child view: \(childId)")
            
            // Update tracking
            childToParent.removeValue(forKey: childId)
        }
        
        // Remove the parent from hierarchy tracking
        viewHierarchy.removeValue(forKey: parentId)
    }
    
    /// Attach a child view to a parent view
    @objc func attachView(childId: String, parentId: String, index: Int) -> Bool {
        NSLog("DCMauiFFIBridge: attachView called for child \(childId) to parent \(parentId) at index \(index)")
        
        // Get the views
        guard let childView = self.views[childId], let parentView = self.views[parentId] else {
            NSLog("Child or parent view not found")
            return false
        }
        
        // Add child to parent in view hierarchy
        parentView.insertSubview(childView, at: index)
        
        // Update shadow tree
        DCFLayoutManager.shared.addChildNode(parentId: parentId, childId: childId, index: index)
        
        // Track parent-child relationship for cleanup
        if viewHierarchy[parentId] == nil {
            viewHierarchy[parentId] = []
        }
        if !viewHierarchy[parentId]!.contains(childId) {
            viewHierarchy[parentId]!.append(childId)
        }
        childToParent[childId] = parentId
        
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
        
        // Get the parent view
        guard let parentView = self.views[viewId] else {
            NSLog("Parent view not found with ID: \(viewId)")
            return false
        }
        
        // Remove all existing children from tracking that are not in new list
        let oldChildren = viewHierarchy[viewId] ?? []
        for oldChildId in oldChildren {
            if !childrenIds.contains(oldChildId) {
                childToParent.removeValue(forKey: oldChildId)
            }
        }
        
        // Reset children array
        viewHierarchy[viewId] = childrenIds
        
        // Update child->parent mapping
        for childId in childrenIds {
            childToParent[childId] = viewId
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
                DCFLayoutManager.shared.addChildNode(parentId: viewId, childId: childId, index: index)
            }
        }
        
        return true
    }
    
    /// Apply layout to a view directly
    @objc func updateViewLayout(viewId: String, left: Float, top: Float, width: Float, height: Float) -> Bool {
        NSLog("DCMauiFFIBridge: updateViewLayout called for \(viewId)")
        
        // Get the view
        guard let view = self.views[viewId] else {
            NSLog("View not found with ID: \(viewId)")
            return false
        }
        
        // Ensure minimum dimensions
        let safeWidth = max(1.0, width)
        let safeHeight = max(1.0, height)
        
        // Apply layout on main thread
        if Thread.isMainThread {
            view.frame = CGRect(
                x: CGFloat(left),
                y: CGFloat(top),
                width: CGFloat(safeWidth),
                height: CGFloat(safeHeight)
            )
            view.setNeedsLayout()
            view.layoutIfNeeded()
        } else {
            DispatchQueue.main.sync {
                view.frame = CGRect(
                    x: CGFloat(left),
                    y: CGFloat(top),
                    width: CGFloat(safeWidth),
                    height: CGFloat(safeHeight)
                )
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
        }
        
        // Ensure view is visible
        view.isHidden = false
        view.alpha = 1.0
        
        return true
    }
    
    /// Calculate layout for the entire tree
    @objc func calculateLayout(screenWidth: CGFloat, screenHeight: CGFloat) -> Bool {
        NSLog("DCMauiFFIBridge: calculateLayout called with dimensions: \(screenWidth)x\(screenHeight)")
        
        // Make sure root view exists
        guard let rootView = self.views["root"] else {
            print("Root view is not registered! Cannot perform layout.")
            return false
        }
        
        // Use the shadow tree to calculate and apply layout
        let success = YogaShadowTree.shared.calculateAndApplyLayout(width: screenWidth, height: screenHeight)
        
        return success
    }
    
    /// Detach a view from its parent
    @objc func detachView(childId: String) -> Bool {
        NSLog("DCMauiFFIBridge: detachView called for \(childId)")
        
        guard let childView = self.views[childId] else {
            NSLog("Child view not found with ID: \(childId)")
            return false
        }
        
        // Remove view from its parent
        childView.removeFromSuperview()
        
        // Update parent-child tracking
        if let parentId = childToParent[childId] {
            viewHierarchy[parentId]?.removeAll(where: { $0 == childId })
        }
        childToParent.removeValue(forKey: childId)
        
        // Note: We don't remove from views or other registries since we're just detaching
        
        return true
    }
    
    // MARK: - Helper Methods
    
    /// Extract layout properties from props dictionary
    private func extractLayoutProps(from props: [String: Any]) -> [String: Any] {
        let layoutPropKeys = SupportedLayoutsProps.supportedLayoutProps
        return props.filter { layoutPropKeys.contains($0.key) }
    }
    
    // Check if a view exists
    @objc func viewExists(viewId: String) -> Bool {
        // Check all registries
        return self.views[viewId] != nil || 
               ViewRegistry.shared.getView(id: viewId) != nil || 
               DCFLayoutManager.shared.getView(withId: viewId) != nil
    }
    
    // Get children of a view
    @objc func getChildrenIds(viewId: String) -> [String] {
        return viewHierarchy[viewId] ?? []
    }
    
    // Get parent of a view
    @objc func getParentId(childId: String) -> String? {
        return childToParent[childId]
    }
    
    // Print hierarchy for debugging
    @objc func printHierarchy() {
        NSLog("--- View Hierarchy ---")
        for (parentId, childrenIds) in viewHierarchy {
            NSLog("Parent: \(parentId), Children: \(childrenIds)")
        }
        NSLog("---------------------")
    }
}

