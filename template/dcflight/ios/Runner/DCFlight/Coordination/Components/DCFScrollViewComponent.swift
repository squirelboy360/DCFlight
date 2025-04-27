import UIKit
import yoga

class DCFScrollViewComponent: NSObject, DCFComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a UIScrollView with default configuration
        let scrollView = UIScrollView()
        
        // Set default properties
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        
        // Apply props to newly created view
        _ = updateView(scrollView, withProps: props)
        
        return scrollView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let scrollView = view as? UIScrollView else {
            print("⚠️ DCMauiScrollViewComponent: Attempting to update non-scrollview view")
            return false 
        }
        
        // Apply standard styles using common extension
        view.applyStyles(props: props)
        
        // Apply ScrollView-specific props
        if let showsVerticalIndicator = props["showsVerticalScrollIndicator"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsVerticalIndicator
        }
        
        if let showsHorizontalIndicator = props["showsHorizontalScrollIndicator"] as? Bool {
            scrollView.showsHorizontalScrollIndicator = showsHorizontalIndicator
        }
        
        if let bounces = props["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        if let pagingEnabled = props["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        // Handle contentInset if specified
        if let topInset = props["contentInsetTop"] as? CGFloat,
           let leftInset = props["contentInsetLeft"] as? CGFloat,
           let bottomInset = props["contentInsetBottom"] as? CGFloat,
           let rightInset = props["contentInsetRight"] as? CGFloat {
            scrollView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
        
        // Always ensure scrolling is enabled
        if let scrollEnabled = props["scrollEnabled"] as? Bool {
            scrollView.isScrollEnabled = scrollEnabled
        } else {
            scrollView.isScrollEnabled = true
        }
        
        return true
    }
    
    // Override applyLayout to set contentSize
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        guard let scrollView = view as? UIScrollView else {
            print("⚠️ DCFScrollViewComponent: applyLayout called on non-UIScrollView")
            return
        }

        // 1. Apply the frame calculated by Yoga to the ScrollView itself
        // Ensure this happens on the main thread
        DispatchQueue.main.async {
            scrollView.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
            print("📏 Applied frame to ScrollView \(scrollView.accessibilityIdentifier ?? "unknown"): \(scrollView.frame)")

            // 2. Calculate the content size based on subviews
            var contentWidth: CGFloat = 0
            var contentHeight: CGFloat = 0

            for subview in scrollView.subviews {
                // Use the frame set by Yoga's layout application on the subviews
                let subviewFrame = subview.frame
                contentWidth = max(contentWidth, subviewFrame.maxX)
                contentHeight = max(contentHeight, subviewFrame.maxY)
            }

            // 3. Set the contentSize
            // Ensure contentSize is at least the size of the scroll view's bounds
            // Add a small buffer if needed, or ensure Yoga layout accounts for padding correctly
            let finalContentWidth = max(contentWidth, scrollView.bounds.width)
            let finalContentHeight = max(contentHeight, scrollView.bounds.height)
            let newContentSize = CGSize(width: finalContentWidth, height: finalContentHeight)

            if scrollView.contentSize != newContentSize {
                scrollView.contentSize = newContentSize
                print("📐 Updated contentSize for ScrollView \(scrollView.accessibilityIdentifier ?? "unknown"): \(scrollView.contentSize)")
            } else {
                 print("📐 ContentSize for ScrollView \(scrollView.accessibilityIdentifier ?? "unknown") unchanged: \(scrollView.contentSize)")
            }
        }
    }
    
    // MARK: - Component Method Handlers
    
    /// Handle scrollTo method calls from Dart
    func scrollTo(view: UIScrollView, args: [String: Any]) {
        guard let x = args["x"] as? CGFloat,
              let y = args["y"] as? CGFloat else {
            print("❌ scrollTo: Missing x or y coordinates")
            return
        }
        
        let animated = args["animated"] as? Bool ?? true
        
        // Apply scroll on main thread
        DispatchQueue.main.async {
            view.setContentOffset(CGPoint(x: x, y: y), animated: animated)
        }
    }
    
    /// Handle scrollToEnd method calls from Dart (scroll to bottom)
    func scrollToEnd(view: UIScrollView, args: [String: Any]) {
        let animated = args["animated"] as? Bool ?? true
        
        // Calculate the bottom offset
        let bottomOffset = CGPoint(
            x: 0,
            y: max(0, view.contentSize.height - view.bounds.height)
        )
        
        // Apply scroll on main thread
        DispatchQueue.main.async {
            view.setContentOffset(bottomOffset, animated: animated)
        }
    }
    
    // Only needed for initial registration
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        view.accessibilityIdentifier = nodeId
    }
}
