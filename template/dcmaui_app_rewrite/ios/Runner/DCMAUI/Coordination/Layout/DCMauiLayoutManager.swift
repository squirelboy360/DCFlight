import UIKit
import yoga

/// Manages layout for DCMAUI components
/// Note: Primary layout calculations occur on the Dart side
/// This class primarily handles applying calculated layouts and handling absolute positioning
class DCMauiLayoutManager {
    // Singleton instance
    static let shared = DCMauiLayoutManager()
    
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
    
    /// Apply layout to a view
    func applyLayout(to viewId: String, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) {
        guard let view = viewRegistry[viewId] else {
            print("View not found for layout: \(viewId)")
            return
        }
        
        // Apply layout on main thread
        DispatchQueue.main.async {
            view.frame = CGRect(x: left, y: top, width: width, height: height)
        }
    }
    
    /// Apply layout to all views in the tree
    func applyLayoutToAllViews() {
        // Get layout size from screen
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height
        
        // Calculate layout
        YogaShadowTree.shared.calculateLayout(width: width, height: height)
        
        // Apply layout to each view
        for (nodeId, _) in viewRegistry {
            if let layout = YogaShadowTree.shared.getNodeLayout(nodeId: nodeId) {
                applyLayout(to: nodeId, left: layout.minX, top: layout.minY, 
                            width: layout.width, height: layout.height)
            }
        }
    }
    
    // MARK: - Style Application
    
    /// Apply styles to a view (using the shared UIView extension)
    func applyStyles(to view: UIView, props: [String: Any]) {
        view.applyStyles(props: props)
    }
    
    // MARK: - Cleanup
    
    /// Clean up resources
    func cleanup() {
        viewRegistry.removeAll()
    }
}
