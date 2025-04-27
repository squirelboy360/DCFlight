import UIKit
import yoga

/// Protocol that all DCMAUI components must implement
protocol DCFComponent {
    /// Initialize the component
    init()
    
    /// Create a view with the given props
    func createView(props: [String: Any]) -> UIView
    
    /// Update a view with new props
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool
    
    /// Apply yoga layout to the view
    func applyLayout(_ view: UIView, layout: YGNodeLayout)
    
    /// Get intrinsic content size for a view (for text measurement, etc.)
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize
    
    /// Called when a view is registered with the shadow tree
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String)
    
    /// Add event listeners to a view
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void)
    
    /// Remove event listeners from a view
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String])
}

/// Layout information from a Yoga node
struct YGNodeLayout {
    let left: CGFloat
    let top: CGFloat
    let width: CGFloat
    let height: CGFloat
}

// To resolve initializer requirement issues, make the extension provide a default implementation
extension DCFComponent {
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        // Default implementation - position and size the view
        view.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        // Default implementation - use view's intrinsic size or zero
        return view.intrinsicContentSize != .zero ? view.intrinsicContentSize : CGSize(width: 0, height: 0)
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Default implementation - store node ID on the view
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "nodeId".hashValue)!, 
                               nodeId, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // Default implementation for addEventListeners
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        print("📣 Registering events \(eventTypes) for view \(viewId) of type \(type(of: view))")
        
        // Store the event callback and view ID using associated objects
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!, 
                               eventCallback, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "viewId".hashValue)!, 
                               viewId, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Store the registered event types
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!,
                               eventTypes,
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Verify storage of event data
        let storedCallback = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!)
        let storedViewId = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "viewId".hashValue)!)
        let storedEventTypes = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!)
        
        print("✅ Event registration verification:")
        print("   - Callback stored: \(storedCallback != nil ? "yes" : "no")")
        print("   - ViewId stored: \(storedViewId != nil ? "yes" : "no")")
        print("   - EventTypes stored: \(storedEventTypes != nil ? "yes" : "no")")
    }
    
    // Default implementation for removeEventListeners
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        print("🔴 Removing event listeners \(eventTypes) from view \(viewId)")
        
        // Update the stored event types
        if let existingTypes = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!) as? [String] {
            var remainingTypes = existingTypes
            for type in eventTypes {
                if let index = remainingTypes.firstIndex(of: type) {
                    remainingTypes.remove(at: index)
                }
            }
            
            if remainingTypes.isEmpty {
                // Clean up all event data if no events remain
                objc_setAssociatedObject(view, 
                                       UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!,
                                       nil, 
                                       .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                objc_setAssociatedObject(view, 
                                       UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
                                       nil, 
                                       .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                objc_setAssociatedObject(view, 
                                       UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!,
                                       nil,
                                       .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                print("🧹 Cleared all event data for view \(viewId)")
            } else {
                // Store updated event types
                objc_setAssociatedObject(view, 
                                       UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!,
                                       remainingTypes,
                                       .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                
                print("🔄 Updated event types for view \(viewId): \(remainingTypes)")
            }
        }
    }
    
    // Generic event trigger helper that enforces "on" prefix convention
    func triggerEvent(on view: UIView, eventType: String, eventData: [String: Any] = [:]) {
        // UPDATED: Enforce "on" prefix
        let standardEventType = eventType
        
        // Only proceed if the event type follows the "on" prefix convention
        if !standardEventType.hasPrefix("on") {
            print("⚠️ Event name \"\(eventType)\" does not follow the \"on\" prefix convention. Events should use format \"onEventName\"")
            // Convert to standard format for internal use, but warn about it
            print("⚠️ Attempting to use standardized name: \"onEventType\"")
        }
        
        print("🔔 Triggering event \(standardEventType) on view \(type(of: view))")
        
        // Get stored event data
        guard let callback = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!) 
                as? (String, String, [String: Any]) -> Void,
              let viewId = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String,
              let eventTypes = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!) as? [String] else {
            print("❌ Event triggering failed: Missing callback, viewId, or eventTypes")
            return
        }
        
        // UPDATED: Check if this event type is registered - only exact matches, no conversion
        if eventTypes.contains(standardEventType) {
            print("✅ Found matching event type: \(standardEventType)")
            // Call the event callback with the exact event type that was registered
            callback(viewId, standardEventType, eventData)
        } else {
            print("❌ No matching event type found. Registered: \(eventTypes), Tried to trigger: \(standardEventType)")
        }
    }
}


