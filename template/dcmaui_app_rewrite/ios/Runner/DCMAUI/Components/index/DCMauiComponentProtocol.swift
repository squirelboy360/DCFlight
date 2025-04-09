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
    
    // Default implementation for addEventListeners - do nothing by default
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // Default implementation does nothing
    }
    
    // Default implementation for removeEventListeners - do nothing by default
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // Default implementation does nothing
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
}