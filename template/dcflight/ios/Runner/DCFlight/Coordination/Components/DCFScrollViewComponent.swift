import UIKit
import yoga

class DCFScrollViewComponent: NSObject, DCFComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a UIScrollView with fixed configuration
        let scrollView = UIScrollView()
        
        // Critical configuration - these must never be modified elsewhere
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.canCancelContentTouches = true
        
        // Default property configuration
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        
        // Create a content view that will contain all children
        let contentView = UIView()
        contentView.tag = 1001 // Used to identify the content view
        scrollView.addSubview(contentView)
        
        // Turn off automatic inset adjustments which can break scrolling
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        // Apply additional props
        _ = updateView(scrollView, withProps: props)
        
        print("✅ Created a new ScrollView with proper scrolling behavior")
        
        return scrollView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let scrollView = view as? UIScrollView else {
            print("⚠️ DCFScrollViewComponent: Attempting to update non-scrollview view")
            return false 
        }
        
        // Ensure the scroll view is always interactive
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = props["scrollEnabled"] as? Bool ?? true
        
        // Ensure content view exists
        var contentView = scrollView.viewWithTag(1001)
        if contentView == nil {
            contentView = UIView()
            contentView!.tag = 1001
            scrollView.addSubview(contentView!)
            print("⚠️ Created missing content view in ScrollView")
        }
        
        // Apply scroll view specific properties
        if let showsVerticalScrollIndicator = props["showsVerticalScrollIndicator"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
        
        if let showsHorizontalScrollIndicator = props["showsHorizontalScrollIndicator"] as? Bool {
            scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
        
        if let bounces = props["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        if let alwaysBounceVertical = props["alwaysBounceVertical"] as? Bool {
            scrollView.alwaysBounceVertical = alwaysBounceVertical
        }
        
        if let alwaysBounceHorizontal = props["alwaysBounceHorizontal"] as? Bool {
            scrollView.alwaysBounceHorizontal = alwaysBounceHorizontal
        }
        
        if let pagingEnabled = props["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        if let directionalLockEnabled = props["directionalLockEnabled"] as? Bool {
            scrollView.isDirectionalLockEnabled = directionalLockEnabled
        }
        
        // Handle content insets
        if let contentInset = props["contentInset"] as? [String: Any] {
            let top = contentInset["top"] as? CGFloat ?? 0
            let left = contentInset["left"] as? CGFloat ?? 0
            let bottom = contentInset["bottom"] as? CGFloat ?? 0
            let right = contentInset["right"] as? CGFloat ?? 0
            scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        } else {
            // Handle individual inset properties
            let topInset = props["contentInsetTop"] as? CGFloat ?? scrollView.contentInset.top
            let leftInset = props["contentInsetLeft"] as? CGFloat ?? scrollView.contentInset.left
            let bottomInset = props["contentInsetBottom"] as? CGFloat ?? scrollView.contentInset.bottom
            let rightInset = props["contentInsetRight"] as? CGFloat ?? scrollView.contentInset.right
            
            let newInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
            scrollView.contentInset = newInsets
        }
        
        if #available(iOS 11.0, *) {
            if let contentInsetAdjustmentBehavior = props["contentInsetAdjustmentBehavior"] as? String {
                switch contentInsetAdjustmentBehavior {
                case "automatic":
                    scrollView.contentInsetAdjustmentBehavior = .automatic
                case "scrollableAxes":
                    scrollView.contentInsetAdjustmentBehavior = .scrollableAxes
                case "never":
                    scrollView.contentInsetAdjustmentBehavior = .never
                case "always":
                    scrollView.contentInsetAdjustmentBehavior = .always
                default:
                    scrollView.contentInsetAdjustmentBehavior = .never
                }
            } else {
                // Default to never to avoid scroll issues
                scrollView.contentInsetAdjustmentBehavior = .never
            }
            
            // Ensure scroll indicator insets aren't automatically adjusted (prevents scroll issues)
            if #available(iOS 13.0, *) {
                scrollView.automaticallyAdjustsScrollIndicatorInsets = false
            } else {
                // Fallback on earlier versions
            }
        }
        
        // Handle keyboard dismissal behavior
        if let keyboardDismissMode = props["keyboardDismissMode"] as? String {
            switch keyboardDismissMode {
            case "none":
                scrollView.keyboardDismissMode = .none
            case "on-drag":
                scrollView.keyboardDismissMode = .onDrag
            case "interactive":
                scrollView.keyboardDismissMode = .interactive
            default:
                scrollView.keyboardDismissMode = .none
            }
        }
        
        return true
    }
    
    // Apply layout to the scroll view and calculate proper content size
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // Always ensure these critical settings on layout
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        
        DispatchQueue.main.async {
            // Save current scroll position
            let savedContentOffset = scrollView.contentOffset
            let wasAtBottom = (scrollView.contentOffset.y + scrollView.bounds.height) >= scrollView.contentSize.height
            
            // Apply the frame from yoga layout
            scrollView.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
            
            // Force layout immediately to position all subviews
            scrollView.setNeedsLayout()
            scrollView.layoutIfNeeded()
            
            // Get the content view
            guard let contentView = scrollView.viewWithTag(1001) else {
                print("⚠️ Content view missing when applying scroll layout")
                return
            }
            
            // Calculate the real content size by examining all subviews
            var maxWidth: CGFloat = 0
            var maxHeight: CGFloat = 0
            
            for subview in scrollView.subviews {
                // Skip the content view itself when calculating
                if subview.tag != 1001 {
                    maxWidth = max(maxWidth, subview.frame.maxX)
                    maxHeight = max(maxHeight, subview.frame.maxY)
                }
            }
            
            // Ensure content is scrollable by using max of calculated size and scrollview bounds
            let contentWidth = max(maxWidth, scrollView.bounds.width) + 1  // Adding 1 to ensure scrollability
            let contentHeight = max(maxHeight, scrollView.bounds.height) + 1
            
            // Set the content view frame to match
            contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
            
            // Set the content size - this is critical for scrolling
            let newContentSize = CGSize(width: contentWidth, height: contentHeight)
            scrollView.contentSize = newContentSize
            
            // Maintenance of scroll position
            if wasAtBottom {
                // If we were at the bottom, stay at the bottom
                let newMaxY = max(0, scrollView.contentSize.height - scrollView.bounds.height)
                scrollView.contentOffset = CGPoint(x: savedContentOffset.x, y: newMaxY)
            } else if savedContentOffset != .zero {
                // Otherwise restore the previous position
                scrollView.contentOffset = savedContentOffset
            }
            
            // Debug information
            print("📊 ScrollView contentSize: \(scrollView.contentSize), frame: \(scrollView.frame)")
            print("📊 ScrollView scrollable: \(scrollView.contentSize.height > scrollView.bounds.height ? "YES" : "NO")")
        }
    }
    
    // MARK: - Method Handlers
    
    func scrollTo(view: UIScrollView, args: [String: Any]) {
        guard let x = args["x"] as? CGFloat, let y = args["y"] as? CGFloat else {
            print("❌ ScrollView.scrollTo: Missing coordinates")
            return
        }
        
        let animated = args["animated"] as? Bool ?? true
        
        DispatchQueue.main.async {
            // Ensure scrolling is enabled
            view.isScrollEnabled = true
            
            // Calculate safe coordinates (don't exceed content size)
            let safeX = min(max(0, x), max(0, view.contentSize.width - view.bounds.width))
            let safeY = min(max(0, y), max(0, view.contentSize.height - view.bounds.height))
            
            // Apply scroll
            view.setContentOffset(CGPoint(x: safeX, y: safeY), animated: animated)
            
            // Force layout immediately if not animated
            if !animated {
                view.layoutIfNeeded()
            }
            
            print("✅ ScrollView.scrollTo: (\(safeX), \(safeY)), animated: \(animated)")
        }
    }
    
    func scrollToEnd(view: UIScrollView, args: [String: Any]) {
        let animated = args["animated"] as? Bool ?? true
        
        DispatchQueue.main.async {
            // Ensure scrolling is enabled
            view.isScrollEnabled = true
            
            // Calculate bottom position
            let maxY = max(0, view.contentSize.height - view.bounds.height)
            let bottomOffset = CGPoint(x: 0, y: maxY)
            
            // Apply scroll
            view.setContentOffset(bottomOffset, animated: animated)
            
            // Force layout immediately if not animated
            if !animated {
                view.layoutIfNeeded()
            }
            
            print("✅ ScrollView.scrollToEnd: Y: \(maxY), animated: \(animated)")
        }
    }
    
    func flashScrollIndicators(view: UIScrollView, args: [String: Any]) {
        DispatchQueue.main.async {
            view.flashScrollIndicators()
        }
    }
    
    // MARK: - View Registration
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        view.accessibilityIdentifier = nodeId
        
        // Ensure scroll view properties are maintained
        if let scrollView = view as? UIScrollView {
            scrollView.isUserInteractionEnabled = true
            scrollView.isScrollEnabled = true
        }
    }
    
    // MARK: - Event Handling
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // Store the event information using associated objects
        objc_setAssociatedObject(
            view,
            UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
            viewId,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        objc_setAssociatedObject(
            view,
            UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!,
            eventCallback,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        // Create and set the delegate
        let delegate = ScrollViewDelegateHandler(viewId: viewId, eventCallback: eventCallback)
        scrollView.delegate = delegate
        
        // Store the delegate to keep it alive
        objc_setAssociatedObject(
            view,
            UnsafeRawPointer(bitPattern: "scrollDelegate".hashValue)!,
            delegate,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        print("✅ Added scroll event handlers for: \(eventTypes)")
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // Reset delegate
        scrollView.delegate = nil
        
        // Remove associated objects
        objc_setAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollDelegate".hashValue)!,
            nil,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }
}

// MARK: - ScrollView Delegate Handler
class ScrollViewDelegateHandler: NSObject, UIScrollViewDelegate {
    let viewId: String
    let eventCallback: (String, String, [String: Any]) -> Void
    
    init(viewId: String, eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        self.viewId = viewId
        self.eventCallback = eventCallback
        super.init()
    }
    
    // Scroll event
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Create event data with all relevant information
        let eventData: [String: Any] = [
            "contentOffset": ["x": scrollView.contentOffset.x, "y": scrollView.contentOffset.y],
            "contentSize": ["width": scrollView.contentSize.width, "height": scrollView.contentSize.height],
            "layoutMeasurement": ["width": scrollView.bounds.width, "height": scrollView.bounds.height]
        ]
        
        eventCallback(viewId, "onScroll", eventData)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let eventData: [String: Any] = [
            "contentOffset": ["x": scrollView.contentOffset.x, "y": scrollView.contentOffset.y]
        ]
        
        eventCallback(viewId, "onScrollBeginDrag", eventData)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let eventData: [String: Any] = [
            "contentOffset": ["x": scrollView.contentOffset.x, "y": scrollView.contentOffset.y],
            "decelerate": decelerate
        ]
        
        eventCallback(viewId, "onScrollEndDrag", eventData)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let eventData: [String: Any] = [
            "contentOffset": ["x": scrollView.contentOffset.x, "y": scrollView.contentOffset.y]
        ]
        
        eventCallback(viewId, "onMomentumScrollBegin", eventData)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let eventData: [String: Any] = [
            "contentOffset": ["x": scrollView.contentOffset.x, "y": scrollView.contentOffset.y]
        ]
        
        eventCallback(viewId, "onMomentumScrollEnd", eventData)
    }
    
    // Handle scrollsToTop behavior (status bar tap)
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        eventCallback(viewId, "onScrollToTop", [:])
        return true
    }
}
