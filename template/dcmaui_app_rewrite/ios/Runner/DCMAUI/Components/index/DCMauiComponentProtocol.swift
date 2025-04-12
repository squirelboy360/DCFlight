import UIKit
import yoga

/// Protocol that all DCMAUI components must implement
protocol DCMauiComponent {
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
extension DCMauiComponent {
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
        // CRITICAL FIX: Print detailed debug info for event registration
        print("📣 Registering events \(eventTypes) for view \(viewId) of type \(type(of: view))")
        
        // Store the event callback and view ID for generic event handling
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
        
        // CRITICAL FIX: Verify storage of event data
        let storedCallback = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!)
        print("✅ Event callback stored: \(storedCallback != nil ? "yes" : "no")")
    }
    
    // Default implementation for removeEventListeners
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // Clean up the stored event types
        if let existingTypes = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!) as? [String] {
            var remainingTypes = existingTypes
            for type in eventTypes {
                if let index = remainingTypes.firstIndex(of: type) {
                    remainingTypes.remove(at: index)
                }
            }
            
            if remainingTypes.isEmpty {
                // Clear all event-related objects if no events remain
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
            } else {
                // Store remaining event types
                objc_setAssociatedObject(view, 
                                       UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!,
                                       remainingTypes,
                                       .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    // Generic event trigger helper that can be used by any component
    func triggerEvent(on view: UIView, eventType: String, eventData: [String: Any] = [:]) {
        // CRITICAL FIX: Print more detailed debug info
        print("🔔 Attempting to trigger event \(eventType) on view \(type(of: view))")
        
        guard let callback = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!) 
                as? (String, String, [String: Any]) -> Void,
              let viewId = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String else {
            print("❌ Event triggering failed: Missing callback or viewId")
            return
        }
              
        // Get registered event types
        let eventTypes = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!) as? [String] ?? []
        
        // CRITICAL FIX: Use more flexible event matching for common patterns
        let shouldTrigger = eventTypes.contains(eventType) ||
                           (eventType == "press" && eventTypes.contains("onPress")) ||
                           (eventType == "onPress" && eventTypes.contains("press"))
        
        if shouldTrigger {
            print("✅ Triggering event \(eventType) for view with ID \(viewId)")
            // Call the event callback
            callback(viewId, eventType, eventData)
        } else {
            print("❌ Event not registered. Registered events: \(eventTypes)")
        }
    }
}

// This extension is renamed to avoid conflict with the one in LayoutDebugVisualizer.swift
extension UIView {
    // Use direct objc_getAssociatedObject instead of property to avoid conflicts
    func getNodeId() -> String? {
        return objc_getAssociatedObject(self, UnsafeRawPointer(bitPattern: "nodeId".hashValue)!) as? String
    }
    
    func setNodeId(_ nodeId: String?) {
        objc_setAssociatedObject(self, 
                              UnsafeRawPointer(bitPattern: "nodeId".hashValue)!, 
                              nodeId, 
                              .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // Convenience method to trigger events
    func triggerEvent(_ eventType: String, withData data: [String: Any] = [:]) {
        // Get the component protocol from the component registry
        let viewClassName = String(describing: type(of: self))
        
        // Try to find component for view's class
        for (_, componentType) in DCMauiComponentRegistry.shared.componentTypes {
            let tempInstance = componentType.init()
            let tempView = tempInstance.createView(props: [:])
            
            if String(describing: type(of: tempView)) == viewClassName {
                tempInstance.triggerEvent(on: self, eventType: eventType, eventData: data)
                return
            }
        }
    }
}