import UIKit
import Foundation

/// Bridge between Dart FFI and native Swift/Objective-C code
/// Now adapted to work with method channels
@objc class DCMauiBridgeImpl: NSObject {
    
    // Singleton instance
    @objc static let shared = DCMauiBridgeImpl()
    
    // Dictionary to hold view references
    internal var views = [String: UIView]()
    
    // Track node operation status for synchronization with Dart side
    private struct NodeSyncStatus {
        var lastOperation: String
        var timestamp: TimeInterval
        var success: Bool
        var syncId: String    // Used to match operations between Dart and native side
        var errorMessage: String?
    }
    
    // Node status tracking dictionary
    private var nodeSyncStatuses = [String: NodeSyncStatus]()
    
    // Timestamp for last sync operation
    private var lastSyncTimestamp: TimeInterval = 0
    
    // App restart detection
    private var appBootId = UUID().uuidString
    private var lastBootTimestamp = Date().timeIntervalSince1970
    
    // Private initializer for singleton
    private override init() {
        super.init()
        NSLog("DCMauiFFIBridge initialized (method channel compatible version)")
    }
    
    // MARK: - Public Registration Methods
    
    /// Register a pre-existing view with the bridge
    @objc func registerView(_ view: UIView, withId viewId: String) {
        NSLog("DCMauiFFIBridge: Manually registering view with ID: \(viewId)")
        views[viewId] = view
        // Also register with ViewRegistry for method channel
        ViewRegistry.shared.registerView(view, id: viewId, type: "View")
    }
    
    /// Initialize the framework
    @objc func initialize() -> Bool {
        NSLog("DCMauiFFIBridge: initialize called")
        
        // Generate new boot ID for restart detection
        appBootId = UUID().uuidString
        lastBootTimestamp = Date().timeIntervalSince1970
        
        NSLog("🚀 App initialized with new boot ID: \(appBootId) at \(lastBootTimestamp)")
        
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
        
        // Clear all previous view registrations since this is a fresh start
        if !views.isEmpty {
            let oldViewCount = views.count
            
            // Only keep the root view if it exists
            let rootView = views["root"]
            views.removeAll()
            if let rootView = rootView {
                views["root"] = rootView
            }
            
            NSLog("♻️ Cleared \(oldViewCount) stale view references on app restart")
        }
        
        return true
    }
    
    /// Get app boot information - used by Dart side to detect restarts
    @objc func getAppBootInfo() -> String {
        let bootInfo: [String: Any] = [
            "bootId": appBootId,
            "timestamp": lastBootTimestamp,
            "viewCount": views.count
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: bootInfo, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "{\"bootId\":\"\(appBootId)\",\"timestamp\":\(lastBootTimestamp),\"error\":\"JSON conversion failed\"}"
        }
        
        return jsonString
    }
    
    /// Create a view with properties
    @objc func createView(viewId: String, viewType: String, propsJson: String) -> Bool {
        NSLog("DCMauiFFIBridge: createView called for \(viewId) of type \(viewType)")
        NSLog("DCMauiFFIBridge: With props \(propsJson)")
        
        // Parse props JSON
        guard let propsData = propsJson.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData, options: []) as? [String: Any] else {
            NSLog("Failed to parse props JSON: \(propsJson)")
            return false
        }
        
        // Log layout props for debugging
        logLayoutProps(props)
        
        // Create the component instance
        guard let componentType = DCMauiComponentRegistry.shared.getComponentType(for: viewType) else {
            NSLog("Component not found for type: \(viewType)")
            
            // Track sync failure
            trackSyncStatus(nodeId: viewId, operation: "create_view", success: false, 
                          errorMessage: "Component type not found: \(viewType)")
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
        DCMauiLayoutManager.shared.registerView(view, withNodeId: viewId, componentType: viewType, componentInstance: componentInstance)
        
        // Track successful node creation
        trackSyncStatus(nodeId: viewId, operation: "create_view", success: true)
        
        // Apply layout props if any
        let layoutProps = extractLayoutProps(from: props)
        if !layoutProps.isEmpty {
            NSLog("📊 EXTRACTED LAYOUT PROPS: \(layoutProps)")
            
            DCMauiLayoutManager.shared.updateNodeWithLayoutProps(
                nodeId: viewId,
                componentType: viewType,
                props: layoutProps
            )
        }
        
        return true
    }
    
    // Helper method to log layout properties for debugging
    private func logLayoutProps(_ props: [String: Any]) {
        let layoutProps = SupportedLayoutsProps.supportedLayoutProps;
        
        var foundLayoutProps = [String: Any]()
        for key in layoutProps {
            if let value = props[key] {
                foundLayoutProps[key] = value
            }
        }
        
        if !foundLayoutProps.isEmpty {
            NSLog("📐 LAYOUT PROPS: \(foundLayoutProps)")
        } else {
            NSLog("⚠️ NO LAYOUT PROPS FOUND")
        }
    }

    // Track node synchronization status
    private func trackSyncStatus(nodeId: String, operation: String, success: Bool, syncId: String = UUID().uuidString, errorMessage: String? = nil) {
        let timestamp = Date().timeIntervalSince1970
        nodeSyncStatuses[nodeId] = NodeSyncStatus(
            lastOperation: operation,
            timestamp: timestamp,
            success: success,
            syncId: syncId,
            errorMessage: errorMessage
        )
        lastSyncTimestamp = timestamp
        
        if !success {
            NSLog("⚠️ Node sync error: \(nodeId) - \(operation) failed: \(errorMessage ?? "Unknown error")")
        } else {
            NSLog("✅ Node sync: \(nodeId) - \(operation) succeeded")
        }
    }
    
    // Get sync status for a node
    func getSyncStatus(nodeId: String) -> [String: Any]? {
        guard let status = nodeSyncStatuses[nodeId] else {
            return nil
        }
        
        return [
            "lastOperation": status.lastOperation,
            "timestamp": status.timestamp,
            "success": status.success,
            "syncId": status.syncId,
            "errorMessage": status.errorMessage ?? NSNull()
        ]
    }
    
    // Check if node exists in both Dart and native
    func verifyNodeConsistency(nodeId: String) -> Bool {
        // Check if view exists
        let viewExists = views[nodeId] != nil
        
        // Check if yoga node exists
        let yogaNodeExists = YogaShadowTree.shared.nodes[nodeId] != nil
        
        // Check if node is registered with layout manager
        let layoutNodeExists = DCMauiLayoutManager.shared.getView(withId: nodeId) != nil
        
        let consistent = viewExists && yogaNodeExists && layoutNodeExists
        
        if !consistent {
            NSLog("🔍 Node consistency check failed for \(nodeId): view=\(viewExists), yoga=\(yogaNodeExists), layout=\(layoutNodeExists)")
        }
        
        return consistent
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
        
        // CRITICAL FIX: Check multiple sources for the view
        var view = self.views[viewId]
        
        // If view not found in main registry, try ViewRegistry as backup
        if view == nil {
            view = ViewRegistry.shared.getView(id: viewId)
            
            // If found in ViewRegistry but not in our registry, update our registry
            if view != nil {
                self.views[viewId] = view
                NSLog("🔄 View \(viewId) found in ViewRegistry but not in bridge registry - synced")
            }
        }
        
        // If still not found, check LayoutManager
        if view == nil {
            view = DCMauiLayoutManager.shared.getView(withId: viewId)
            
            // If found in LayoutManager but not in our registry, update our registry
            if view != nil {
                self.views[viewId] = view
                NSLog("🔄 View \(viewId) found in LayoutManager but not in bridge registry - synced")
            }
        }
        
        // Final check - view must exist by now
        guard let finalView = view else {
            NSLog("⚠️ View not found with ID: \(viewId) in any registry")
            
            // Track view reference failure for debugging
            trackSyncStatus(nodeId: viewId, operation: "update_view", success: false, 
                          errorMessage: "View not found in any registry")
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
            for (componentName, componentType) in DCMauiComponentRegistry.shared.componentTypes {
                let tempInstance = componentType.init()
                let tempView = tempInstance.createView(props: [:])
                
                if String(describing: type(of: tempView)) == viewClassName {
                    // Found matching component, update view
                    success = tempInstance.updateView(finalView, withProps: nonLayoutProps)
                    componentFound = true
                    NSLog("✅ Found component \(componentName) for view class: \(viewClassName)")
                    break
                }
            }
            
            if !componentFound {
                NSLog("Component not found for view class: \(viewClassName)")
                success = false
            }
        }
        
        // Track update operation result
        trackSyncStatus(nodeId: viewId, operation: "update_view", success: success)
        
        return success
    }
    
    /// Delete a view
    @objc func deleteView(viewId: String) -> Bool {
        NSLog("DCMauiFFIBridge: deleteView called for \(viewId)")
        
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
        
        // Track deletion operation
        trackSyncStatus(nodeId: viewId, operation: "delete_view", success: true)
        
        return true
    }
    
    /// Attach a child view to a parent view
    @objc func attachView(childId: String, parentId: String, index: Int) -> Bool {
        NSLog("DCMauiFFIBridge: attachView called for child \(childId) to parent \(parentId) at index \(index)")
        
        // Get the views
        guard let childView = self.views[childId], let parentView = self.views[parentId] else {
            NSLog("Child or parent view not found")
            
            // Track attachment failure
            let errorMsg = "Child or parent view not found: child=\(self.views[childId] != nil), parent=\(self.views[parentId] != nil)"
            trackSyncStatus(nodeId: childId, operation: "attach_view", success: false, errorMessage: errorMsg)
            return false
        }
        
        // Add child to parent in view hierarchy
        parentView.insertSubview(childView, at: index)
        
        // Update shadow tree
        DCMauiLayoutManager.shared.addChildNode(parentId: parentId, childId: childId, index: index)
        
        // Track successful attachment
        trackSyncStatus(nodeId: childId, operation: "attach_view", success: true)
        
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
        NSLog("🎯 LAYOUT VALUES: left=\(left), top=\(top), width=\(width), height=\(height)")
        
        // Get the view
        guard let view = self.views[viewId] else {
            NSLog("View not found with ID: \(viewId)")
            return false
        }
        
        // Check view's current frame BEFORE updating
        NSLog("📏 BEFORE LAYOUT: View \(viewId) frame is \(view.frame)")
        
        // CRITICAL FIX: Ensure minimum dimensions and execute on main thread
        let safeWidth = max(1.0, width)
        let safeHeight = max(1.0, height)
        
        // Apply layout directly on main thread
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
        
        // CRITICAL FIX: Ensure view is visible
        view.isHidden = false
        view.alpha = 1.0
        
        // Check view's updated frame AFTER updating
        NSLog("📏 AFTER LAYOUT: View \(viewId) frame is now \(view.frame)")
        
        return true
    }
    
    /// Calculate layout for the entire tree
    @objc func calculateLayout(screenWidth: CGFloat, screenHeight: CGFloat) -> Bool {
        NSLog("DCMauiFFIBridge: calculateLayout called with dimensions: \(screenWidth)x\(screenHeight)")
        
        // CRITICAL FIX: Make sure root view is properly registered
        guard let rootView = self.views["root"] else {
            print("❌ CRITICAL ERROR: Root view is not registered! Cannot perform layout.")
            
            // Try to debug what views are available
            print("🔍 Available views in registry: \(self.views.keys.joined(separator: ", "))")
            return false
        }
        
        print("✅ Root view found: \(rootView)")
        print("✅ Root view frame before layout: \(rootView.frame)")
        
        // Use the shadow tree to calculate and apply layout
        let success = YogaShadowTree.shared.calculateAndApplyLayout(width: screenWidth, height: screenHeight)
        
        print("✅ Root view frame after layout: \(rootView.frame)")
        
        return success
    }
    
    /// Measure text
    @objc func measureText(viewId: String, text: String, attributesJson: String) -> String {
        NSLog("DCMauiFFIBridge: measureText called for \(viewId)")
        
        // Parse attributes JSON
        guard let attributesData = attributesJson.data(using: .utf8),
              let attributes = try? JSONSerialization.jsonObject(with: attributesData, options: []) as? [String: Any] else {
            return "{\"width\":0.0,\"height\":0.0}"
        }
        
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
    
    // Sync method exposed to Dart to verify node hierarchy consistency
    @objc func syncNodeHierarchy(rootId: String, nodeTreeJson: String) -> String {
        NSLog("🔄 Syncing node hierarchy from root: \(rootId)")
        
        guard let nodeTreeData = nodeTreeJson.data(using: .utf8),
              let nodeTree = try? JSONSerialization.jsonObject(with: nodeTreeData) as? [String: Any] else {
            return "{\"success\":false,\"error\":\"Invalid node tree JSON\"}"
        }
        
        // Process the hierarchy - implemented in YogaShadowTree
        let syncResults = YogaShadowTree.shared.validateAndRepairHierarchy(nodeTree: nodeTree, rootId: rootId)
        
        // Create detailed result response
        let resultDict: [String: Any] = [
            "success": syncResults.success,
            "error": syncResults.errorMessage ?? NSNull(),
            "nodesChecked": syncResults.nodesChecked,
            "nodesMismatched": syncResults.nodesMismatched,
            "nodesRepaired": syncResults.nodesRepaired,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: resultDict, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "{\"success\":false,\"error\":\"Failed to serialize sync results\"}"
        }
        
        return jsonString
    }
    
    // Function to get node hierarchy as JSON
    @objc func getNodeHierarchy(nodeId: String) -> String {
        // Get hierarchy as JSON from YogaShadowTree
        return YogaShadowTree.shared.getHierarchyAsJson(startingAt: nodeId)
    }
    
    // MARK: - Helper Methods
    
    /// Extract layout properties from props dictionary
    private func extractLayoutProps(from props: [String: Any]) -> [String: Any] {
        let layoutPropKeys = SupportedLayoutsProps.supportedLayoutProps
        
        return props.filter { layoutPropKeys.contains($0.key) }
    }
    
    // Implement viewExists method - enhance to check across all registries
    @objc func viewExists(viewId: String) -> Bool {
        // Check all possible registries for this view
        let inMainRegistry = views[viewId] != nil
        let inViewRegistry = ViewRegistry.shared.getView(id: viewId) != nil
        let inLayoutManager = DCMauiLayoutManager.shared.getView(withId: viewId) != nil
        
        let exists = inMainRegistry || inViewRegistry || inLayoutManager
        
        // Log detailed information about where the view was found
        NSLog("🔍 View existence check for \(viewId): main=\(inMainRegistry), viewRegistry=\(inViewRegistry), layoutManager=\(inLayoutManager)")
        
        // If view was found in secondary registry but not main registry, sync it to main registry
        if !inMainRegistry && (inViewRegistry || inLayoutManager) {
            // Fixed: Use nil coalescing to ensure we're handling the optionals correctly
            if let view = ViewRegistry.shared.getView(id: viewId) ?? DCMauiLayoutManager.shared.getView(withId: viewId) {
                // Sync to main registry
                views[viewId] = view
                NSLog("🔄 View \(viewId) found in secondary registry - synchronized to main registry")
            }
        }
        
        return exists
    }
}

