import UIKit
import yoga

class DCMauiScrollViewComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        let scrollView = UIScrollView()
        
        // Create content view to hold children
        let contentView = UIView()
        contentView.tag = 1001 // Tag for identification
        
        // Add content view to scroll view
        scrollView.addSubview(contentView)
        
        // Set initial constraints for content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // These constraints will be updated based on content size
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        ])
        
        // Add width constraint depending on scroll direction
        let isHorizontal = props["horizontal"] as? Bool ?? false
        if isHorizontal {
            // For horizontal scrolling, content width depends on children
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        } else {
            // For vertical scrolling, content width equals scroll view width
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
        
        // Set scroll view delegate for event handling
        scrollView.delegate = ScrollViewDelegateHandler.shared
        
        // Apply properties
        _ = updateView(scrollView, withProps: props)
        
        return scrollView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let scrollView = view as? UIScrollView else {
            print("❌ ERROR: Not a scroll view")
            return false
        }
        
        // Apply standard styling to scroll view
        view.applyStyles(props: props)
        
        // Update scroll view configuration
        updateScrollViewConfiguration(scrollView, props: props)
        
        // Update content size if specified
        updateContentSize(scrollView, props: props)
        
        // Update content insets
        updateContentInsets(scrollView, props: props)
        
        // Register scroll events if needed
        setupScrollEvents(scrollView, props: props)
        
        return true
    }
    
    // Update scroll view configuration
    private func updateScrollViewConfiguration(_ scrollView: UIScrollView, props: [String: Any]) {
        // Horizontal scrolling
        if let horizontal = props["horizontal"] as? Bool {
            scrollView.isDirectionalLockEnabled = true
            updateScrollDirection(scrollView, isHorizontal: horizontal)
        }
        
        // Show/hide scroll indicators
        if let showsHorizontalScrollIndicator = props["showsHorizontalScrollIndicator"] as? Bool {
            scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
        
        if let showsVerticalScrollIndicator = props["showsVerticalScrollIndicator"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
        
        // Bouncing behavior
        if let bounces = props["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        // Paging behavior
        if let pagingEnabled = props["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        // Enable/disable scrolling
        if let scrollEnabled = props["scrollEnabled"] as? Bool {
            scrollView.isScrollEnabled = scrollEnabled
        }
    }
    
    // Update scroll direction and constraints
    private func updateScrollDirection(_ scrollView: UIScrollView, isHorizontal: Bool) {
        guard let contentView = scrollView.viewWithTag(1001) else { return }
        
        // Remove existing constraints first
        contentView.constraints.forEach { constraint in
            if (constraint.firstItem === contentView && constraint.secondItem === scrollView &&
                (constraint.firstAttribute == .width || constraint.firstAttribute == .height)) {
                contentView.removeConstraint(constraint)
            }
        }
        
        // Apply constraints based on direction
        if isHorizontal {
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
        } else {
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        }
    }
    
    // Update content size
    private func updateContentSize(_ scrollView: UIScrollView, props: [String: Any]) {
        let isHorizontal = props["horizontal"] as? Bool ?? false
        
        // Update content size if specified
        if let contentWidth = props["contentWidth"] as? CGFloat,
           let contentHeight = props["contentHeight"] as? CGFloat {
            scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        } else if isHorizontal {
            // For horizontal scrolling, set reasonable content width if not specified
            if let contentWidth = props["contentWidth"] as? CGFloat {
                scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)
            }
        } else {
            // For vertical scrolling, set reasonable content height if not specified
            if let contentHeight = props["contentHeight"] as? CGFloat {
                scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
            }
        }
    }
    
    // Update content insets
    private func updateContentInsets(_ scrollView: UIScrollView, props: [String: Any]) {
        var insets = UIEdgeInsets.zero
        
        if let top = props["contentInsetTop"] as? CGFloat {
            insets.top = top
        }
        
        if let bottom = props["contentInsetBottom"] as? CGFloat {
            insets.bottom = bottom
        }
        
        if let left = props["contentInsetLeft"] as? CGFloat {
            insets.left = left
        }
        
        if let right = props["contentInsetRight"] as? CGFloat {
            insets.right = right
        }
        
        if insets != .zero {
            scrollView.contentInset = insets
        }
    }
    
    // Setup scroll events
    private func setupScrollEvents(_ scrollView: UIScrollView, props: [String: Any]) {
        // Use proper type casting with 'is Any' instead of 'is Function'
        if let onScroll = props["onScroll"], onScroll is Any {
            // Store scroll event throttle
            let throttle = props["scrollEventThrottle"] as? CGFloat ?? 16 // Default to 60fps
            objc_setAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!,
                throttle,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            // Register scroll view with delegate handler
            ScrollViewDelegateHandler.shared.registerScrollView(scrollView)
        } else {
            // Unregister if no onScroll provided
            ScrollViewDelegateHandler.shared.unregisterScrollView(scrollView)
        }
    }
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        // Apply layout to scroll view
        view.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
        
        // Get content view
        guard let scrollView = view as? UIScrollView,
              let contentView = scrollView.viewWithTag(1001) else { return }
        
        // Update content view size based on children
        let isHorizontal = (objc_getAssociatedObject(scrollView, 
                                                     UnsafeRawPointer(bitPattern: "horizontal".hashValue)!) as? Bool) ?? false
        
        // Set content view frame
        if isHorizontal {
            // For horizontal scrolling
            var contentWidth: CGFloat = 0
            
            // Calculate total width of all children
            for subview in contentView.subviews {
                contentWidth = max(contentWidth, subview.frame.maxX)
            }
            
            // Ensure minimum content width
            contentWidth = max(contentWidth, scrollView.frame.width)
            
            // Set content size
            scrollView.contentSize = CGSize(width: contentWidth, height: scrollView.frame.height)
        } else {
            // For vertical scrolling
            var contentHeight: CGFloat = 0
            
            // Calculate total height of all children
            for subview in contentView.subviews {
                contentHeight = max(contentHeight, subview.frame.maxY)
            }
            
            // Ensure minimum content height
            contentHeight = max(contentHeight, scrollView.frame.height)
            
            // Set content size
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: contentHeight)
        }
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        // For scroll views, use the frame size or defined dimensions
        if let width = props["width"] as? CGFloat, let height = props["height"] as? CGFloat {
            return CGSize(width: width, height: height)
        }
        
        // Fallback to default size
        return CGSize(width: 300, height: 200)
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        view.accessibilityIdentifier = nodeId
        
        // Store node ID
        view.setNodeId(nodeId)
        
        // Also set on content view
        if let contentView = view.viewWithTag(1001) {
            contentView.accessibilityIdentifier = "\(nodeId)_content"
        }
    }
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // Store view ID and callback for scroll events
        ScrollViewDelegateHandler.shared.registerEventCallback(
            for: scrollView,
            viewId: viewId,
            callback: eventCallback
        )
        
        print("📜 Registered scroll view events for \(viewId): \(eventTypes)")
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // Unregister from delegate handler
        ScrollViewDelegateHandler.shared.unregisterScrollView(scrollView)
        
        print("📜 Unregistered scroll view events for \(viewId)")
    }
}

// Singleton delegate handler for scroll views
class ScrollViewDelegateHandler: NSObject, UIScrollViewDelegate {
    // Singleton instance
    static let shared = ScrollViewDelegateHandler()
    
    // Event callback type
    typealias ScrollEventCallback = (String, String, [String: Any]) -> Void
    
    // Track scroll views and their callbacks
    private var scrollViewCallbacks = [UIScrollView: (viewId: String, callback: ScrollEventCallback)]()
    
    // Track last event time for throttling
    private var lastEventTimes = [UIScrollView: TimeInterval]()
    
    private override init() {
        super.init()
    }
    
    // Register a scroll view for event handling
    func registerScrollView(_ scrollView: UIScrollView) {
        scrollView.delegate = self
    }
    
    // Unregister a scroll view
    func unregisterScrollView(_ scrollView: UIScrollView) {
        if scrollView.delegate === self {
            scrollView.delegate = nil
        }
        scrollViewCallbacks.removeValue(forKey: scrollView)
        lastEventTimes.removeValue(forKey: scrollView)
    }
    
    // Register event callback for a scroll view
    func registerEventCallback(for scrollView: UIScrollView, viewId: String, 
                              callback: @escaping ScrollEventCallback) {
        scrollViewCallbacks[scrollView] = (viewId, callback)
    }
    
    // UIScrollViewDelegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let (viewId, callback) = scrollViewCallbacks[scrollView] else { return }
        
        // Get throttle value
        let throttle = objc_getAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!
        ) as? CGFloat ?? 16
        
        let currentTime = Date().timeIntervalSince1970 * 1000
        
        // Check if we should send an event based on throttle
        if let lastTime = lastEventTimes[scrollView], currentTime - lastTime < Double(throttle) {
            return
        }
        
        // Update last event time
        lastEventTimes[scrollView] = currentTime
        
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
                "width": scrollView.frame.width,
                "height": scrollView.frame.height
            ],
            "timestamp": currentTime
        ]
        
        // Send event
        callback(viewId, "onScroll", eventData)
    }
    
    // Add other scroll view delegate methods as needed
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        sendScrollEvent(scrollView, eventName: "onScrollBeginDrag")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        sendScrollEvent(scrollView, eventName: "onScrollEndDrag", additionalData: ["decelerate": decelerate])
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        sendScrollEvent(scrollView, eventName: "onScrollEndDecelerating")
    }
    
    // Helper to send scroll events
    private func sendScrollEvent(_ scrollView: UIScrollView, eventName: String, additionalData: [String: Any] = [:]) {
        guard let (viewId, callback) = scrollViewCallbacks[scrollView] else { return }
        
        // Create base event data
        var eventData: [String: Any] = [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ],
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]
        
        // Add additional data
        for (key, value) in additionalData {
            eventData[key] = value
        }
        
        // Send event
        callback(viewId, eventName, eventData)
    }
}
