import UIKit
import yoga

/// Manages layout for DCMAUI components
/// Note: Primary layout calculations occur on the Dart side
/// This class primarily handles applying calculated layouts and handling absolute positioning
class DCMauiLayoutManager {
    // Singleton instance
    static let shared = DCMauiLayoutManager()
    
    // Set of views using absolute layout (controlled by Dart)
    private var absoluteLayoutViews = Set<UIView>()
    
    // Map view IDs to actual UIViews for direct access
    private var viewRegistry = [String: UIView]()
    
    private init() {}
    
    // MARK: - View Registry Management
    
    /// Register a view with an ID
    func registerView(_ view: UIView, withId viewId: String) {
        viewRegistry[viewId] = view
    }
    
    /// Unregister a view
    func unregisterView(withId viewId: String) {
        viewRegistry.removeValue(forKey: viewId)
    }
    
    /// Get view by ID
    func getView(withId viewId: String) -> UIView? {
        return viewRegistry[viewId]
    }
    
    // MARK: - Layout Application
    
    // Remove this duplicate method completely - we only want the one from the extension
    // func applyLayout(to viewId: String, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> Bool {
    //    // Duplicate method removed to avoid ambiguity
    // }
    
    // MARK: - Absolute Layout Management
    
    /// Mark a view as using absolute layout (controlled by Dart side)
    func setViewUsingAbsoluteLayout(view: UIView) {
        absoluteLayoutViews.insert(view)
    }
    
    /// Check if a view uses absolute layout
    func isUsingAbsoluteLayout(_ view: UIView) -> Bool {
        return absoluteLayoutViews.contains(view)
    }
    
    // MARK: - Cleanup
    
    /// Clean up resources for a view
    func cleanUp(viewId: String) {
        if let view = viewRegistry[viewId] {
            absoluteLayoutViews.remove(view)
        }
        viewRegistry.removeValue(forKey: viewId)
    }
    
    // MARK: - Style Application
    
    /// Apply styles to a view (using the shared UIView extension)
    func applyStyles(to view: UIView, props: [String: Any]) {
        view.applyStyles(props: props)
    }
}

extension DCMauiLayoutManager {
    
    /// Apply calculated layout to a view
    @discardableResult
    func applyLayout(to viewId: String, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> Bool {
        guard let view = getView(withId: viewId) else {
            print("Layout Error: View not found for ID \(viewId)")
            return false
        }
        
        print("🔄 LAYOUT MANAGER APPLYING LAYOUT TO \(viewId): (\(left), \(top), \(width), \(height))")
        print("🔄 BEFORE LAYOUT: View \(viewId) frame was \(view.frame)")
        
        // Apply frame directly
        let frame = CGRect(x: left, y: top, width: width, height: height)
        
        print("🔄 FRAME TO SET: \(frame)")
        
        DispatchQueue.main.async {
            print("⏱️ ASYNC LAYOUT OPERATION STARTING FOR \(viewId)")
            print("⏱️ VIEW \(viewId) is type \(type(of: view))")
            
            // Check if explicit dimensions were set from Dart
            let hasExplicitDimensions = objc_getAssociatedObject(view, 
                                         UnsafeRawPointer(bitPattern: "hasExplicitDimensions".hashValue)!) as? Bool ?? false
            
            // Check if this is a percentage-based view
            let hasPercentageWidth = objc_getAssociatedObject(view,
                                    UnsafeRawPointer(bitPattern: "hasPercentageWidth".hashValue)!) as? Bool ?? false
            let hasPercentageHeight = objc_getAssociatedObject(view,
                                     UnsafeRawPointer(bitPattern: "hasPercentageHeight".hashValue)!) as? Bool ?? false
            
            // Only modify frame if not explicitly set from Dart or it's a percentage-based view
            if !hasExplicitDimensions || hasPercentageWidth || hasPercentageHeight {
                var newFrame = frame
                
                // If percentage width/height, recalculate based on screen dimensions
                if hasPercentageWidth && view.accessibilityIdentifier?.hasPrefix("view_") == true {
                    let percentValue = objc_getAssociatedObject(view, 
                                      UnsafeRawPointer(bitPattern: "percentageWidthValue".hashValue)!) as? CGFloat ?? 100
                    newFrame.size.width = UIScreen.main.bounds.width * percentValue / 100.0
                }
                
                if hasPercentageHeight && view.accessibilityIdentifier?.hasPrefix("view_") == true {
                    let percentValue = objc_getAssociatedObject(view, 
                                      UnsafeRawPointer(bitPattern: "percentageHeightValue".hashValue)!) as? CGFloat ?? 100
                    newFrame.size.height = UIScreen.main.bounds.height * percentValue / 100.0
                }
                
                view.frame = newFrame
            }
            
            // Force layout if needed
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            print("⏱️ AFTER layoutIfNeeded: \(view.frame) FOR VIEW \(viewId)")
        }
        
        return true
    }
}
