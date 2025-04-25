import UIKit
import yoga

class DCMauiScrollViewComponent: NSObject, DCMauiComponent {
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
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        guard let scrollView = view as? UIScrollView else { return }

        // Apply frame layout to the scroll view itself
        scrollView.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
        
        // Calculate content size based on child views
        // UIScrollView should derive its contentSize from its subviews' frames
        // Yoga will have already laid out the children through the shadow tree
        if let contentView = scrollView.subviews.first {
            // Use the frame calculated by Yoga for the content view
            let contentSize = CGSize(
                width: max(contentView.frame.maxX, scrollView.frame.width),
                height: max(contentView.frame.maxY, scrollView.frame.height)
            )
            
            // Only update if different
            if scrollView.contentSize != contentSize {
                scrollView.contentSize = contentSize
                print("📏 ScrollView contentSize updated to: \(contentSize)")
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
