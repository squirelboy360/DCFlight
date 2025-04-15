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
        contentView.backgroundColor = .clear // Make background clear initially
        scrollView.addSubview(contentView)
        
        // Tag the content view for identification
        contentView.tag = 1001
        
        // Default configuration with better defaults
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = false
        scrollView.clipsToBounds = true
        
        // Set up content view constraints - much simpler approach
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            
            // These are critical for proper sizing - will be modified based on scroll direction
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        // Apply styles and props
        _ = updateView(scrollView, withProps: props)
        
        return scrollView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let scrollView = view as? UIScrollView else { return false }
        
        // Get content view
        let contentView = scrollView.viewWithTag(1001)
        
        // Apply style properties first - FIX: explicitly handle backgroundColor for content view
        if let backgroundColorStr = props["backgroundColor"] as? String {
            // Apply background color directly to content view for ScrollView
            if let contentView = contentView {
                let color = ColorUtilities.color(fromHexString: backgroundColorStr)
                contentView.backgroundColor = color
                
                // The scroll view itself should keep transparent background
                scrollView.backgroundColor = .clear
            } else {
                // Fallback if content view not found
                scrollView.backgroundColor = ColorUtilities.color(fromHexString: backgroundColorStr)
            }
            
            // Remove from props to prevent double application
            var modifiedProps = props
            modifiedProps.removeValue(forKey: "backgroundColor")
            scrollView.applyStyles(props: modifiedProps)
        } else {
            // Apply remaining styles if no background color was specified
            scrollView.applyStyles(props: props)
        }
        
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
    
    // FIXED: Removed incorrect override keyword
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // Store the common event data using the protocol extension's implementation
        (self as DCMauiComponent).addEventListeners(to: view, viewId: viewId, eventTypes: eventTypes, eventCallback: eventCallback)
        
        guard let scrollView = view as? UIScrollView else { return }
        
        // Handle specific events
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
            
            // Set up callback using the generic triggerEvent
            delegate.onScroll = { [weak self] (scrollView: UIScrollView) in
                guard let self = self else { return }
                
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
                
                // Use the generic trigger event method
                self.triggerEvent(on: scrollView, eventType: "scroll", eventData: eventData)
            }
            
            // Store delegate and assign to scrollView
            DCMauiScrollComponent.scrollViewDelegates[scrollView] = delegate
            scrollView.delegate = delegate
        }
    }
    
    // FIXED: Removed incorrect override keyword
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        if eventTypes.contains("scroll") {
            // Remove delegate
            DCMauiScrollComponent.scrollViewDelegates.removeValue(forKey: scrollView)
            scrollView.delegate = nil
        }
        
        // Call the protocol extension's implementation
        (self as DCMauiComponent).removeEventListeners(from: view, viewId: viewId, eventTypes: eventTypes)
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
            ]
        ]
        
        // Use the generic trigger event method
        triggerEvent(on: scrollView, eventType: "scroll", eventData: eventData)
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
