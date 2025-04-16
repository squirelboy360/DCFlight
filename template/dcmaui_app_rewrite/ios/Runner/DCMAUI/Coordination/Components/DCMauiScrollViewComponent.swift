import UIKit
import yoga

class DCMauiScrollViewComponent: NSObject, DCMauiComponent, UIScrollViewDelegate {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create the main scroll view
        let scrollView = CustomScrollView()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.bounces = true
        
        // Create a content view that will contain child views
        let contentView = UIView()
        contentView.tag = 1001 // Tag for easy access
        
        // Add content view to scroll view
        scrollView.addSubview(contentView)
        
        // Apply properties
        _ = updateView(scrollView, withProps: props)
        
        print("📜 Created ScrollView with initial props: \(props)")
        return scrollView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let scrollView = view as? UIScrollView else {
            print("⚠️ DCMauiScrollViewComponent: Attempted to update non-scrollview")
            return false
        }
        
        // Get content view reference
        let contentView = scrollView.viewWithTag(1001) as? UIView
        
        // Apply common styles to the scroll view
        view.applyStyles(props: props)
        
        // ScrollView-specific properties
        if let horizontal = props["horizontal"] as? Bool {
            scrollView.isDirectionalLockEnabled = !horizontal
            
            if horizontal {
                // Configure for horizontal scrolling
                scrollView.alwaysBounceHorizontal = true
                scrollView.alwaysBounceVertical = false
            } else {
                // Configure for vertical scrolling
                scrollView.alwaysBounceVertical = true
                scrollView.alwaysBounceHorizontal = false
            }
        }
        
        // Content size - will be updated when children are laid out
        if let contentWidth = props["contentWidth"] as? CGFloat {
            if contentView != nil && contentWidth > 0 {
                contentView?.frame.size.width = contentWidth
                scrollView.contentSize.width = contentWidth
            }
        }
        
        if let contentHeight = props["contentHeight"] as? CGFloat {
            if contentView != nil && contentHeight > 0 {
                contentView?.frame.size.height = contentHeight
                scrollView.contentSize.height = contentHeight
            }
        }
        
        // Scroll indicators
        if let showsHorizontalScrollIndicator = props["showsHorizontalScrollIndicator"] as? Bool {
            scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
        
        if let showsVerticalScrollIndicator = props["showsVerticalScrollIndicator"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
        
        // Bounce behavior
        if let bounces = props["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        // Paging
        if let pagingEnabled = props["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        // Scroll event throttle
        if let scrollEventThrottle = props["scrollEventThrottle"] as? Double {
            objc_setAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!,
                scrollEventThrottle,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        // Content insets
        var insets = scrollView.contentInset
        
        if let insetTop = props["contentInsetTop"] as? CGFloat {
            insets.top = insetTop
        }
        
        if let insetBottom = props["contentInsetBottom"] as? CGFloat {
            insets.bottom = insetBottom
        }
        
        if let insetLeft = props["contentInsetLeft"] as? CGFloat {
            insets.left = insetLeft
        }
        
        if let insetRight = props["contentInsetRight"] as? CGFloat {
            insets.right = insetRight
        }
        
        scrollView.contentInset = insets
        
        // Enable/disable scrolling
        if let scrollEnabled = props["scrollEnabled"] as? Bool {
            scrollView.isScrollEnabled = scrollEnabled
        }
        
        return true
    }
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        // Apply layout to the scroll view itself
        view.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
        
        // Ensure content view matches scroll view width/height based on scrolling direction
        guard let scrollView = view as? UIScrollView,
              let contentView = scrollView.viewWithTag(1001) else {
            return
        }
        
        // Set the content view frame - default to scroll view bounds
        contentView.frame.origin = .zero
        
        // Horizontal scrolling - height matches scroll view, width can be larger
        if scrollView.alwaysBounceHorizontal && !scrollView.alwaysBounceVertical {
            contentView.frame.size.height = scrollView.bounds.height
            
            // Use either explicit content width or match to scroll view width (minimum)
            if contentView.frame.width < scrollView.bounds.width {
                contentView.frame.size.width = scrollView.bounds.width
            }
        } 
        // Vertical scrolling - width matches scroll view, height can be larger
        else {
            contentView.frame.size.width = scrollView.bounds.width
            
            // Use either explicit content height or match to scroll view height (minimum)
            if contentView.frame.height < scrollView.bounds.height {
                contentView.frame.size.height = scrollView.bounds.height
            }
        }
        
        // Update the content size of the scroll view to match its content view
        scrollView.contentSize = contentView.frame.size
        
        print("📜 ScrollView layout applied: frame=\(view.frame), contentSize=\(scrollView.contentSize)")
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        // ScrollView typically takes the size given to it
        return .zero
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Set accessibility identifier for easier debugging
        view.accessibilityIdentifier = nodeId
        
        // Register as a scroll view specifically
        objc_setAssociatedObject(
            view,
            UnsafeRawPointer(bitPattern: "scrollViewNodeId".hashValue)!,
            nodeId,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        print("📜 ScrollView registered with node ID: \(nodeId)")
    }
    
    // MARK: - Event Handling
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // Store event information with the scroll view
        objc_setAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollViewId".hashValue)!,
            viewId,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        objc_setAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollEventTypes".hashValue)!,
            eventTypes,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        objc_setAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollEventCallback".hashValue)!,
            eventCallback,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        // Ensure scroll view's delegate is set to self
        if scrollView.delegate == nil {
            scrollView.delegate = self
        }
        
        print("📜 Added event listeners to ScrollView \(viewId): \(eventTypes)")
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // Get currently stored event types
        if let existingTypes = objc_getAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollEventTypes".hashValue)!
        ) as? [String] {
            // Filter out the removed event types
            let remainingTypes = existingTypes.filter { !eventTypes.contains($0) }
            
            if remainingTypes.isEmpty {
                // If no events remain, clean up completely
                objc_setAssociatedObject(
                    scrollView,
                    UnsafeRawPointer(bitPattern: "scrollViewId".hashValue)!,
                    nil,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                
                objc_setAssociatedObject(
                    scrollView,
                    UnsafeRawPointer(bitPattern: "scrollEventTypes".hashValue)!,
                    nil,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                
                objc_setAssociatedObject(
                    scrollView,
                    UnsafeRawPointer(bitPattern: "scrollEventCallback".hashValue)!,
                    nil,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                
                // Remove delegate reference
                if scrollView.delegate === self {
                    scrollView.delegate = nil
                }
            } else {
                // Update remaining event types
                objc_setAssociatedObject(
                    scrollView,
                    UnsafeRawPointer(bitPattern: "scrollEventTypes".hashValue)!,
                    remainingTypes,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
        
        print("📜 Removed event listeners from ScrollView \(viewId): \(eventTypes)")
    }
    
    // MARK: - UIScrollViewDelegate
    
    // Store the last time a scroll event was sent to implement throttling
    private var lastScrollEventTime: [UIScrollView: TimeInterval] = [:]
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Get stored data for this scroll view
        guard let viewId = objc_getAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollViewId".hashValue)!
        ) as? String,
        
        let eventTypes = objc_getAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollEventTypes".hashValue)!
        ) as? [String],
        
        let callback = objc_getAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollEventCallback".hashValue)!
        ) as? (String, String, [String: Any]) -> Void,
        
        eventTypes.contains("onScroll") else {
            return
        }
        
        // Implement scroll event throttling
        let now = Date().timeIntervalSince1970
        let throttleTime = objc_getAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!
        ) as? Double ?? 16.0 // Default to 16ms throttle (roughly 60fps)
        
        // Convert throttle from milliseconds to seconds
        let throttleSeconds = throttleTime / 1000.0
        
        if let lastTime = lastScrollEventTime[scrollView],
           now - lastTime < throttleSeconds {
            // Skip this event due to throttling
            return
        }
        
        // Update last event time
        lastScrollEventTime[scrollView] = now
        
        // Create event data
        let eventData: [String: Any] = [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ],
            "contentSize": [
                "width": scrollView.contentSize.width,
                "height": scrollView.contentSize.height
            ],
            "layoutMeasurement": [
                "width": scrollView.bounds.width,
                "height": scrollView.bounds.height
            ],
            "timestamp": now
        ]
        
        // Trigger event
        callback(viewId, "onScroll", eventData)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        triggerScrollEvent(scrollView, eventType: "onScrollBeginDrag")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        triggerScrollEvent(scrollView, eventType: "onScrollEndDrag", extraData: ["decelerate": decelerate])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        triggerScrollEvent(scrollView, eventType: "onScrollEndDecelerating")
        
        // Also trigger onMomentumEnd when scrolling stops completely
        if !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating {
            triggerScrollEvent(scrollView, eventType: "onMomentumEnd")
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        triggerScrollEvent(scrollView, eventType: "onScrollAnimationEnd")
    }
    
    private func triggerScrollEvent(_ scrollView: UIScrollView, eventType: String, extraData: [String: Any] = [:]) {
        // Get stored data for this scroll view
        guard let viewId = objc_getAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollViewId".hashValue)!
        ) as? String,
        
        let eventTypes = objc_getAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollEventTypes".hashValue)!
        ) as? [String],
        
        let callback = objc_getAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollEventCallback".hashValue)!
        ) as? (String, String, [String: Any]) -> Void,
        
        eventTypes.contains(eventType) else {
            return
        }
        
        // Create event data
        var eventData: [String: Any] = [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ],
            "contentSize": [
                "width": scrollView.contentSize.width,
                "height": scrollView.contentSize.height
            ],
            "layoutMeasurement": [
                "width": scrollView.bounds.width,
                "height": scrollView.bounds.height
            ],
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Add any extra data
        for (key, value) in extraData {
            eventData[key] = value
        }
        
        // Trigger event
        callback(viewId, eventType, eventData)
    }
}

// MARK: - Custom ScrollView Class with improved debugging

class CustomScrollView: UIScrollView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
    }
    
    private func setupScrollView() {
        // Set default properties
        self.backgroundColor = .clear
        
        // Improve scroll detection
        self.delaysContentTouches = false
        self.canCancelContentTouches = true
    }
    
    // For debugging, print touch/scroll events in verbose mode
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Uncomment for debugging:
        // print("📜 CustomScrollView touchesBegan")
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Uncomment for debugging:
        // print("📜 CustomScrollView touchesMoved")
        super.touchesMoved(touches, with: event)
    }
    
    // Override to improve scroll handling
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        return result
    }
}
