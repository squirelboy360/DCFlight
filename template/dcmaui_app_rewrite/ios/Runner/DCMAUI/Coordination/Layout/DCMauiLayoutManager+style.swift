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
    
    /// Apply layout directly to a view
    func applyLayout(to viewId: String, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> Bool {
        guard let view = viewRegistry[viewId] else {
            print("⚠️ Cannot apply layout: View with ID \(viewId) not found")
            return false
        }
        
        // Ensure values are valid
        guard !left.isNaN && !top.isNaN && !width.isNaN && !height.isNaN else {
            print("⚠️ Invalid layout values: \(left), \(top), \(width), \(height)")
            return false
        }
        
        // Set absolute positioning flag
        setViewUsingAbsoluteLayout(view: view)
        
        // Apply the frame
        view.frame = CGRect(x: left, y: top, width: width, height: height)
        print("📏 Applied layout to \(viewId): \(view.frame)")
        
        return true
    }
    
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
