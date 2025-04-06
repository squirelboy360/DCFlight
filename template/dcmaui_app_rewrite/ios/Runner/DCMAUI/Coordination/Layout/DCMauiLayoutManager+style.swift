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
    
    // REMOVED DUPLICATE METHOD: applyLayout(to:left:top:width:height:)
    // This method is now defined only in the extension below
    
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
        
        // Apply frame directly
        let frame = CGRect(x: left, y: top, width: width, height: height)
        
        DispatchQueue.main.async {
            // Check if explicit dimensions were set from Dart
            let hasExplicitDimensions = objc_getAssociatedObject(view, 
                                         UnsafeRawPointer(bitPattern: "hasExplicitDimensions".hashValue)!) as? Bool ?? false
            
            // Only modify frame if not explicitly set from Dart
            if !hasExplicitDimensions {
                view.frame = frame
            }
            
            // Force layout if needed
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
        
        return true
    }
    
    // Add this debugging helper method to the manager
    func logLayoutApplication(viewId: String, frame: CGRect) {
        // Empty implementation - debugging functionality removed as requested
    }
    
    // Method to preserve dimensions specified in Dart
    func preserveExplicitDimensions(for viewId: String, width: CGFloat?, height: CGFloat?) {
        if let view = getView(withId: viewId), width != nil || height != nil {
            // Mark this view as having explicit dimensions
            objc_setAssociatedObject(view, 
                                   UnsafeRawPointer(bitPattern: "hasExplicitDimensions".hashValue)!,
                                   true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Verify and fix layout if needed - call this to ensure proper layout
    func verifyAndFixLayout(respectExplicitDimensions: Bool = false) {
        // Start with root view and properly size it
        if let rootView = getView(withId: "root") {
            // Check if root has explicit dimensions that should be preserved
            let rootHasExplicitDimensions = objc_getAssociatedObject(rootView, 
                                          UnsafeRawPointer(bitPattern: "hasExplicitDimensions".hashValue)!) as? Bool ?? false
            
            if !rootHasExplicitDimensions || !respectExplicitDimensions {
                rootView.frame = UIScreen.main.bounds
            }
        }
        
        // Apply systematic layout to ensure everything fits
        applySystematicLayout(respectExplicitDimensions: respectExplicitDimensions)
    }
    
    /// Apply layout systematically to the entire view hierarchy
    private func applySystematicLayout(respectExplicitDimensions: Bool = false) {
        // Start with the root and work our way down
        guard let rootView = getView(withId: "root") else { return }
        
        // First pass: Set size for all parent views
        resizeViewsWithChildren(rootView, respectExplicitDimensions: respectExplicitDimensions)
        
        // Second pass: Position all child views within their parents
        positionChildrenInParents(rootView)
    }
    
    /// Set size for views with children
    private func resizeViewsWithChildren(_ view: UIView, depth: Int = 0, maxWidth: CGFloat? = nil, respectExplicitDimensions: Bool = false) {
        let viewWidth = maxWidth ?? UIScreen.main.bounds.width
        
        // Apply size to the view
        if view.frame.width == 0 {
            var frame = view.frame
            frame.size.width = viewWidth
            
            // Set a reasonable height if none
            if frame.size.height == 0 {
                if let scrollView = view as? UIScrollView {
                    frame.size.height = 400
                } else {
                    frame.size.height = 44
                }
            }
            
            view.frame = frame
        }
        
        // Handle scroll views specially
        if let scrollView = view as? UIScrollView {
            scrollView.contentSize = CGSize(width: viewWidth, height: max(1000, scrollView.contentSize.height))
            
            // Get content view (tag 1001)
            if let contentView = scrollView.viewWithTag(1001) {
                contentView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: scrollView.contentSize.height)
            }
        }
        
        // Process children
        for subview in view.subviews {
            resizeViewsWithChildren(subview, depth: depth + 1, maxWidth: viewWidth, respectExplicitDimensions: respectExplicitDimensions)
        }
    }
    
    /// Position children within their parent views
    private func positionChildrenInParents(_ view: UIView, depth: Int = 0, yOffset: CGFloat = 0) {
        // Handle scroll view content differently
        let isScrollViewContent = view.superview is UIScrollView
        let currentYOffset = isScrollViewContent ? yOffset : 0
        var nextYOffset = currentYOffset
        
        // Special handling for direct children - stack them vertically
        for (index, subview) in view.subviews.enumerated() {
            // Skip UIScrollViewScrollIndicator views
            if String(describing: type(of: subview)).contains("ScrollIndicator") {
                continue
            }
            
            // For buttons and labels which are control elements
            if subview is UIControl || subview is UILabel {
                if subview.frame.height == 0 {
                    var frame = subview.frame
                    frame.size.height = 40
                    subview.frame = frame
                }
            }
            
            // Reposition view
            var frame = subview.frame
            
            // Keep x position, adjust y position for vertical stacking
            frame.origin.y = nextYOffset
            
            // If this is a scroll view, maintain its full height
            if !(subview is UIScrollView) && depth > 0 {
                nextYOffset += frame.height + 10 // Add spacing between elements
            }
            
            subview.frame = frame
            
            // Recursively process subviews
            positionChildrenInParents(subview, depth: depth + 1, yOffset: 0)
        }
        
        // If this is a scroll view content and we've stacked elements, update content size
        if isScrollViewContent, let scrollView = view.superview as? UIScrollView {
            scrollView.contentSize.height = max(nextYOffset, scrollView.contentSize.height)
        }
    }
}
