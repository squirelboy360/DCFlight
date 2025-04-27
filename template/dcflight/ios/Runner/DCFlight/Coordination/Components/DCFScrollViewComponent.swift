import UIKit
import yoga

class DCFScrollViewComponent: NSObject, DCFComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a UIScrollView with default configuration
        let scrollView = UIScrollView()
        
        // CRITICAL FIX: Ensure user interaction is enabled
        scrollView.isUserInteractionEnabled = true
        
        // CRITICAL FIX: Ensure scroll content touches are handled properly
        scrollView.delaysContentTouches = true
        scrollView.canCancelContentTouches = true
        
        // Set default properties - make them very explicit
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.bounces = true
        scrollView.isScrollEnabled = true
        scrollView.alwaysBounceVertical = true  // CRITICAL FIX: Allow bouncing vertically
        
        // CRITICAL FIX: Make sure the scroll view is actually scrollable
        scrollView.contentInsetAdjustmentBehavior = .automatic
        
        // Apply props to newly created view
        _ = updateView(scrollView, withProps: props)
        
        print("🔄 Created a new ScrollView with explicit scrolling behavior enabled")
        
        return scrollView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let scrollView = view as? UIScrollView else {
            print("⚠️ DCMauiScrollViewComponent: Attempting to update non-scrollview view")
            return false 
        }
        
        // CRITICAL FIX: Always ensure these properties are set before anything else
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        
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
        
        // CRITICAL FIX: Explicit bounce settings
        if let alwaysBounceVertical = props["alwaysBounceVertical"] as? Bool {
            scrollView.alwaysBounceVertical = alwaysBounceVertical
        }
        
        if let alwaysBounceHorizontal = props["alwaysBounceHorizontal"] as? Bool {
            scrollView.alwaysBounceHorizontal = alwaysBounceHorizontal
        }
        
        // Handle contentInset if specified
        if let topInset = props["contentInsetTop"] as? CGFloat,
           let leftInset = props["contentInsetLeft"] as? CGFloat,
           let bottomInset = props["contentInsetBottom"] as? CGFloat,
           let rightInset = props["contentInsetRight"] as? CGFloat {
            scrollView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
        
        // CRITICAL FIX: Make sure we're always explicitly enabling scrolling at the end
        // to override any potential style properties that might disable it
        if let scrollEnabled = props["scrollEnabled"] as? Bool {
            scrollView.isScrollEnabled = scrollEnabled
        } else {
            scrollView.isScrollEnabled = true
        }
        
        // Print status for debugging
        print("📊 Applying styles to UIScrollView: \(props)")
        
        return true
    }
    
    // Override applyLayout to set contentSize
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        guard let scrollView = view as? UIScrollView else {
            print("⚠️ DCFScrollViewComponent: applyLayout called on non-UIScrollView")
            return
        }

        // CRITICAL FIX: Ensure scroll view can be properly interacted with
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true

        // 1. Apply the frame calculated by Yoga to the ScrollView itself
        DispatchQueue.main.async {
            scrollView.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
            print("📏 Applied frame to ScrollView \(scrollView.accessibilityIdentifier ?? "unknown"): \(scrollView.frame)")

            // CRITICAL FIX: Delay contentSize calculation to ensure subviews have been laid out
            DispatchQueue.main.async {
                // 2. Calculate the content size based on subviews - FIXED to account for all content
                var maxRight: CGFloat = 0
                var maxBottom: CGFloat = 0
                var minLeft: CGFloat = CGFloat.greatestFiniteMagnitude
                var minTop: CGFloat = CGFloat.greatestFiniteMagnitude

                // First pass: find the extreme bounds
                for subview in scrollView.subviews {
                    minLeft = min(minLeft, subview.frame.minX)
                    minTop = min(minTop, subview.frame.minY)
                    maxRight = max(maxRight, subview.frame.maxX)
                    maxBottom = max(maxBottom, subview.frame.maxY)
                }
                
                // Adjust if no subviews were found
                if minLeft == CGFloat.greatestFiniteMagnitude {
                    minLeft = 0
                }
                
                if minTop == CGFloat.greatestFiniteMagnitude {
                    minTop = 0
                }

                // Calculate total content width and height including items with negative positioning
                let contentWidth = maxRight - minLeft
                let contentHeight = maxBottom - minTop

                // CRITICAL FIX: Make content height larger if needed to ensure scrollability
                // This ensures we always have scrollable content when items extend beyond viewport
                let finalContentWidth = contentWidth > 0 ? max(contentWidth, scrollView.bounds.width) : scrollView.bounds.width
                
                // CRITICAL FIX: Add a small buffer to ensure scrollability
                let finalContentHeight = contentHeight > 0 ? max(contentHeight + 1, scrollView.bounds.height) : scrollView.bounds.height
                
                let newContentSize = CGSize(width: finalContentWidth, height: finalContentHeight)
                
                print("📊 ScrollView calculation: minLeft=\(minLeft), minTop=\(minTop), maxRight=\(maxRight), maxBottom=\(maxBottom)")
                print("📊 ScrollView calculated size: \(contentWidth)×\(contentHeight), final: \(finalContentWidth)×\(finalContentHeight)")
                
                // Apply the calculated contentSize
                if scrollView.contentSize != newContentSize {
                    // CRITICAL FIX: Force content size update on main thread
                    DispatchQueue.main.async {
                        // Apply new content size
                        scrollView.contentSize = newContentSize
                        print("📐 Updated contentSize for ScrollView \(scrollView.accessibilityIdentifier ?? "unknown"): \(scrollView.contentSize)")
                        
                        // CRITICAL FIX: Also adjust content offset if we had negative positioned views
                        if minLeft < 0 || minTop < 0 {
                            // Adjust content offset to account for negative positioned views
                            var newOffset = scrollView.contentOffset
                            if minLeft < 0 {
                                newOffset.x += abs(minLeft)
                            }
                            if minTop < 0 {
                                newOffset.y += abs(minTop)
                            }
                            
                            // Apply adjusted offset
                            scrollView.contentOffset = newOffset
                            print("📏 Adjusted contentOffset for negative positioned content: \(scrollView.contentOffset)")
                        }
                        
                        // Debug information to verify scrollability
                        let isVerticallyScrollable = scrollView.contentSize.height > scrollView.bounds.height
                        let isHorizontallyScrollable = scrollView.contentSize.width > scrollView.bounds.width
                        print("🔍 ScrollView \(scrollView.accessibilityIdentifier ?? "unknown") scrollability: vertical=\(isVerticallyScrollable), horizontal=\(isHorizontallyScrollable)")
                        
                        // CRITICAL FIX: Force layout update after content size change
                        scrollView.setNeedsLayout()
                        scrollView.layoutIfNeeded()
                        
                        // CRITICAL TEST: Try scrolling programmatically to test scrollability
                        if isVerticallyScrollable {
                            let testOffset = CGPoint(x: scrollView.contentOffset.x, y: min(10, scrollView.contentSize.height - scrollView.bounds.height))
                            scrollView.setContentOffset(testOffset, animated: false)
                            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: false)
                            print("🧪 Performed scroll test on ScrollView \(scrollView.accessibilityIdentifier ?? "unknown")")
                        }
                    }
                } else {
                    print("📐 ContentSize for ScrollView \(scrollView.accessibilityIdentifier ?? "unknown") unchanged: \(scrollView.contentSize)")
                }
            }
        }
    }
    
    // CRITICAL FIX: Override to install a gesture recognizer for debugging
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        view.accessibilityIdentifier = nodeId
        
        if let scrollView = view as? UIScrollView {
            // Add a tap gesture recognizer to debug touches
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScrollViewTap(_:)))
            tapGesture.numberOfTapsRequired = 2  // Double-tap for debugging
            scrollView.addGestureRecognizer(tapGesture)
            
            print("🔍 Added debug tap gesture to ScrollView \(nodeId)")
        }
    }
    
    // Debug helper for tap gesture
    @objc func handleScrollViewTap(_ gesture: UITapGestureRecognizer) {
        guard let scrollView = gesture.view as? UIScrollView else { return }
        
        print("🔍 ScrollView DEBUG TAP - Current state:")
        print("   - contentSize: \(scrollView.contentSize)")
        print("   - bounds: \(scrollView.bounds)")
        print("   - isScrollEnabled: \(scrollView.isScrollEnabled)")
        print("   - isUserInteractionEnabled: \(scrollView.isUserInteractionEnabled)")
        print("   - contentOffset: \(scrollView.contentOffset)")
        print("   - subview count: \(scrollView.subviews.count)")
        
        // Test scrolling programmatically
        if scrollView.contentSize.height > scrollView.bounds.height {
            let halfwayY = (scrollView.contentSize.height - scrollView.bounds.height) / 2
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: halfwayY), animated: true)
            print("🔄 Attempted to scroll to halfway point: \(halfwayY)")
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
            // CRITICAL FIX: Make sure scrolling is enabled before trying to scroll
            view.isScrollEnabled = true
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
            // CRITICAL FIX: Make sure scrolling is enabled before trying to scroll
            view.isScrollEnabled = true
            view.setContentOffset(bottomOffset, animated: animated)
            
            // Log for debugging
            print("📜 Scrolling to end: \(bottomOffset.y) (content height: \(view.contentSize.height), view height: \(view.bounds.height))")
        }
    }
}
