import UIKit
import yoga

class DCMauiScrollComponent: NSObject, DCMauiComponent, UIScrollViewDelegate {
    // Required initializer
    required override init() {
        super.init()
    }
    
    // Use a dictionary instead of array
    private static var scrollViewDelegates = [UIScrollView: DCMauiScrollDelegate]()
    
    func createView(props: [String: Any]) -> UIView {
        // Create scroll view
        let scrollView = UIScrollView()
        scrollView.delegate = self
        
        // Content view to hold children and enforce proper sizing
        let contentView = UIView()
        contentView.backgroundColor = .clear // Make sure background is clear
        scrollView.addSubview(contentView)
        
        // Tag the content view for identification
        contentView.tag = 1001
        
        // Default configuration with better defaults
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = false // Changed to false by default
        scrollView.backgroundColor = .clear // Make scroll view transparent by default
        scrollView.clipsToBounds = true
        
        // Set up content view constraints - much simpler approach
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            
            // These are critical for proper sizing - will be modified based on scroll direction
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        // Apply styling from extension
        scrollView.applyStyles(props: props)
        
        // Apply scroll view specific properties
        updateView(scrollView, withProps: props)
        
        return scrollView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let scrollView = view as? UIScrollView else { return false }
        
        // Get content view
        let contentView = scrollView.viewWithTag(1001)
        
        // Configure scroll direction
        if let horizontal = props["horizontal"] as? Bool {
            scrollView.alwaysBounceHorizontal = horizontal
            scrollView.alwaysBounceVertical = !horizontal
            
            // Update constraints based on orientation
            if let contentView = contentView {
                // Remove all existing contentView constraints first
                contentView.constraints.forEach { constraint in
                    if constraint.firstItem === contentView && 
                       (constraint.firstAttribute == .width || constraint.firstAttribute == .height) {
                        contentView.removeConstraint(constraint)
                    }
                }
                
                if horizontal {
                    // For horizontal scrolling, make content view height match scroll view
                    contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
                } else {
                    // For vertical scrolling, make content view width match scroll view
                    contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
                }
            }
        }
        
        // Apply content size if provided
        if let contentWidth = props["contentWidth"] as? CGFloat,
           let contentHeight = props["contentHeight"] as? CGFloat {
            // Don't use zero or negative values
            let width = max(contentWidth, 1)
            let height = max(contentHeight, 1)
            
            print("📜 Setting explicit scroll content size: \(width) x \(height)")
            scrollView.contentSize = CGSize(width: width, height: height)
            
            // Ensure content view matches content size
            if let contentView = contentView {
                // Update content view size constraints
                if props["horizontal"] as? Bool == true {
                    // For horizontal, set width to content width
                    contentView.widthAnchor.constraint(equalToConstant: width).isActive = true
                } else {
                    // For vertical, set height to content height
                    contentView.heightAnchor.constraint(equalToConstant: height).isActive = true
                }
            }
        }
        
        // Configure scroll indicators
        if let showsHorizontalScrollIndicator = props["showsHorizontalScrollIndicator"] as? Bool {
            scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
        
        if let showsVerticalScrollIndicator = props["showsVerticalScrollIndicator"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
        
        // Configure bounce behavior
        if let bounces = props["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        // Configure paging
        if let pagingEnabled = props["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        // Configure scroll event throttle
        if let scrollEventThrottle = props["scrollEventThrottle"] as? Double {
            // Store for use in the scroll delegate
            objc_setAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!,
                scrollEventThrottle,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        // Content insets
        var contentInset = scrollView.contentInset
        
        if let contentInsetTop = props["contentInsetTop"] as? CGFloat {
            contentInset.top = contentInsetTop
        }
        
        if let contentInsetBottom = props["contentInsetBottom"] as? CGFloat {
            contentInset.bottom = contentInsetBottom
        }
        
        if let contentInsetLeft = props["contentInsetLeft"] as? CGFloat {
            contentInset.left = contentInsetLeft
        }
        
        if let contentInsetRight = props["contentInsetRight"] as? CGFloat {
            contentInset.right = contentInsetRight
        }
        
        scrollView.contentInset = contentInset
        
        // Configure scroll enabled state
        if let scrollEnabled = props["scrollEnabled"] as? Bool {
            scrollView.isScrollEnabled = scrollEnabled
        }
        
        // Apply non-layout styling
        DCMauiLayoutManager.shared.applyStyles(to: scrollView, props: props)
        
        // Ensure the content view receives background color if specified for ScrollView
        if let backgroundColor = props["backgroundColor"] as? String,
           let contentView = contentView,
           scrollView.backgroundColor == nil || scrollView.backgroundColor == .clear {
            contentView.backgroundColor = ColorUtilities.color(fromHexString: backgroundColor)
            scrollView.backgroundColor = .clear  // Ensure scroll view is transparent
        }
        
        return true
    }
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        // Apply frame to the scroll view
        view.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
        
        // Get content view
        guard let scrollView = view as? UIScrollView,
              let contentView = scrollView.viewWithTag(1001) else {
            return
        }
        
        // Determine if this is horizontal scrolling
        let isHorizontal = scrollView.showsHorizontalScrollIndicator &&
            !scrollView.showsVerticalScrollIndicator
        
        // Set content view size based on children
        var contentWidth: CGFloat = 0
        var contentHeight: CGFloat = 0
        
        // Find the furthest edge of any subview
        for subview in contentView.subviews {
            let rightEdge = subview.frame.origin.x + subview.frame.size.width
            let bottomEdge = subview.frame.origin.y + subview.frame.size.height
            
            contentWidth = max(contentWidth, rightEdge)
            contentHeight = max(contentHeight, bottomEdge)
        }
        
        // Ensure minimum content size
        contentWidth = max(contentWidth, scrollView.frame.width)
        contentHeight = max(contentHeight, scrollView.frame.height)
        
        // Update content size
        contentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
    }
    
    // Add event listeners to the scroll view
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                         eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let scrollView = view as? UIScrollView else { return }
        
        if eventTypes.contains("scroll") {
            // Get or create delegate
            let delegate = DCMauiScrollComponent.scrollViewDelegates[scrollView] ?? DCMauiScrollDelegate()
            
            // Configure throttling
            if let throttleInterval = objc_getAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!
            ) as? Double {
                delegate.throttleInterval = throttleInterval / 1000.0
            }
            
            // Set up callback
            delegate.onScroll = { (scrollView: UIScrollView) in
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
                    ]
                ]
                
                eventCallback(viewId, "scroll", eventData)
            }
            
            // Store delegate and assign to scrollView
            DCMauiScrollComponent.scrollViewDelegates[scrollView] = delegate
            scrollView.delegate = delegate
        }
        
        // Store callback and viewId for scroll events
        objc_setAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!, 
                               eventCallback, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(view, UnsafeRawPointer(bitPattern: "viewId".hashValue)!, 
                               viewId, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        if eventTypes.contains("scroll") {
            // Remove delegate
            DCMauiScrollComponent.scrollViewDelegates.removeValue(forKey: scrollView)
            scrollView.delegate = nil
        }
        
        // Remove stored event callback
        objc_setAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!, 
                               nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Get stored event callback if any
        guard let eventCallback = objc_getAssociatedObject(scrollView, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!) 
                              as? (String, String, [String: Any]) -> Void,
              let viewId = objc_getAssociatedObject(scrollView, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String 
        else { return }
        
        // Create scroll event data
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
            ]
        ]
        
        // Send event
        eventCallback(viewId, "scroll", eventData)
    }
}

/// Custom delegate class to handle scroll view events for DCMAUI
class DCMauiScrollDelegate: NSObject, UIScrollViewDelegate {
    var onScroll: ((UIScrollView) -> Void)?
    var throttleInterval: TimeInterval = 0.016 // ~60fps by default
    private var lastScrollTime: TimeInterval = 0
    
    override init() {
        super.init()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentTime = Date.timeIntervalSinceReferenceDate
        if currentTime - lastScrollTime >= throttleInterval {
            onScroll?(scrollView)
            lastScrollTime = currentTime
        }
    }
    
    // Also handle scroll end events - useful for many scroll interactions
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // If not decelerating, this is the final position
            onScroll?(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Final position after scrolling and decelerating
        onScroll?(scrollView)
    }
}
