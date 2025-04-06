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
            print("❌ Layout Error: View not found for ID \(viewId)")
            return false
        }
        
        // Debugging layout application
        print("📐 APPLYING LAYOUT: View \(viewId) - (\(left), \(top), \(width), \(height))")
        
        // Apply frame directly
        let frame = CGRect(x: left, y: top, width: width, height: height)
        
        DispatchQueue.main.async {
            view.frame = frame
            
            // Force layout if needed
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            // Use more concise logging for production mode
            #if DEBUG
            print("📏 View \(viewId) actual frame: \(view.frame)")
            #endif
        }
        
        return true
    }
    
    // Add this debugging helper method to the manager
    func logLayoutApplication(viewId: String, frame: CGRect) {
        #if DEBUG
        // Add detailed logging for layout debugging
        print("📐 DETAILED LAYOUT: View \(viewId) - frame: \(frame)")
        
        // Get view to log its actual frame after layout
        if let view = getView(withId: viewId) {
            // Measure time until actual layout occurs
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("📏 View \(viewId) actual frame after layout: \(view.frame)")
            }
        }
        #endif
    }
    
    // No need to define applyLayout again as it's already in the main class
    // Instead, add enhanced debugging to trace layout application issues
    
    /// Debug utility to dump the view hierarchy
    func debugViewHierarchy(startingAt viewId: String = "root") {
        guard let view = getView(withId: viewId) else {
            print("⚠️ Cannot debug hierarchy: View with ID \(viewId) not found")
            return
        }
        
        print("\n📊 VIEW HIERARCHY DUMP - Starting at \(viewId):")
        _printView(view, level: 0)
        print("📊 END OF HIERARCHY DUMP\n")
    }
    
    private func _printView(_ view: UIView, level: Int) {
        let indent = String(repeating: "  ", count: level)
        let className = type(of: view)
        let frame = view.frame
        
        print("\(indent)📱 \(className): frame=(\(frame.origin.x), \(frame.origin.y), \(frame.size.width), \(frame.size.height)), alpha=\(view.alpha)")
        
        // Print subviews
        for subview in view.subviews {
            _printView(subview, level: level + 1)
        }
    }
    
    /// Verify and fix layout if needed - call this to ensure proper layout
    func verifyAndFixLayout() {
        print("🔍 Verifying and fixing layout of all registered views...")
        
        // First, force root view to take full screen size
        if let rootView = getView(withId: "root") {
            print("🔑 Setting root view to full screen size")
            rootView.frame = UIScreen.main.bounds
        }
        
        // Set explicit frames for main container views
        if let view1 = getView(withId: "view_1") {
            print("🔑 Setting main container view to full root size")
            view1.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            // Force layout
            view1.setNeedsLayout()
            view1.layoutIfNeeded()
        }
        
        // Set background color for debugging
        if let view2 = getView(withId: "view_2") {
            print("🔑 Setting header view size")
            view2.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
            view2.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            
            // Force layout
            view2.setNeedsLayout()
            view2.layoutIfNeeded()
        }
        
        // Set main scroll view frame
        if let scrollView = getView(withId: "view_7") as? UIScrollView {
            print("🔑 Setting main scroll view size")
            scrollView.frame = CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 80)
            scrollView.backgroundColor = UIColor.white
            
            // Set content size to ensure scrolling works
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 2000)
            
            // Force layout
            scrollView.setNeedsLayout()
            scrollView.layoutIfNeeded()
        }
        
        // Apply layout to all views systematically
        applySystematicLayoutToViewHierarchy()
        
        // Log the updated view hierarchy
        debugViewHierarchy()
    }
    
    /// Apply layout systematically to the entire view hierarchy
    private func applySystematicLayoutToViewHierarchy() {
        print("⚙️ Applying systematic layout to all views...")
        
        // Start with the root and work our way down
        guard let rootView = getView(withId: "root") else { return }
        
        // First pass: Set size for all parent views
        resizeViewsWithChildren(rootView)
        
        // Second pass: Position all child views within their parents
        positionChildrenInParents(rootView)
        
        print("✅ Systematic layout applied to view hierarchy")
    }
    
    /// Set size for views with children
    private func resizeViewsWithChildren(_ view: UIView, depth: Int = 0, maxWidth: CGFloat? = nil) {
        let indent = String(repeating: "  ", count: depth)
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
            print("\(indent)📐 Resized view: \(frame)")
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
            resizeViewsWithChildren(subview, depth: depth + 1, maxWidth: viewWidth)
        }
    }
    
    /// Position children within their parent views
    private func positionChildrenInParents(_ view: UIView, depth: Int = 0, yOffset: CGFloat = 0) {
        let indent = String(repeating: "  ", count: depth)
        
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
            print("\(indent)📍 Positioned view at index \(index) to y=\(frame.origin.y)")
            
            // Recursively process subviews
            positionChildrenInParents(subview, depth: depth + 1, yOffset: 0)
        }
        
        // If this is a scroll view content and we've stacked elements, update content size
        if isScrollViewContent, let scrollView = view.superview as? UIScrollView {
            scrollView.contentSize.height = max(nextYOffset, scrollView.contentSize.height)
            print("\(indent)📜 Updated scroll view content height to \(scrollView.contentSize.height)")
        }
    }
    
    /// Force layout and background colors for debugging
    func forceLayoutForDebugging() {
        print("🔍 APPLYING DEBUG LAYOUT AND COLORS")
        
        // Apply background colors to help visualize the layout
        if let rootView = getView(withId: "root") {
            rootView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        }
        
        if let mainView = getView(withId: "view_1") {
            mainView.backgroundColor = UIColor.white
            mainView.frame = UIScreen.main.bounds
        }
        
        if let headerView = getView(withId: "view_2") {
            headerView.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
            headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
        }
        
        if let scrollView = getView(withId: "view_7") as? UIScrollView {
            scrollView.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
            scrollView.frame = CGRect(x: 0, y: 80, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 80)
            
            // Set large content size to ensure scrolling works
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 2000)
        }
        
        // Add a visual label to verify rendering is working
        let debugLabel = UILabel(frame: CGRect(x: 20, y: 100, width: 300, height: 80))
        debugLabel.text = "DEBUG: If you can see this text, rendering is working!"
        debugLabel.textColor = UIColor.black
        debugLabel.backgroundColor = UIColor.yellow
        debugLabel.textAlignment = .center
        debugLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        if let mainView = getView(withId: "view_1") {
            mainView.addSubview(debugLabel)
        }
    }
}
