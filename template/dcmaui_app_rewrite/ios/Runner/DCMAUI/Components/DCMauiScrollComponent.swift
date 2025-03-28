import UIKit
import yoga

class DCMauiScrollComponent: NSObject, DCMauiComponentProtocol {
    private static var scrollViewDelegates: [UIScrollView: ScrollViewDelegate] = [:]
    
    static func createView(props: [String: Any]) -> UIView {
        let scrollView = UIScrollView()
        
        // Configure default properties
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        
        // Create Yoga node for layout management
        let _ = DCMauiLayoutManager.shared.createYogaNode(for: scrollView)
        
        // Apply all props
        updateView(scrollView, props: props)
        return scrollView
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // ScrollView-specific properties
        
        // Indicator visibility
        if let showsVertical = props["showsVerticalScrollIndicator"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsVertical
        }
        
        if let showsHorizontal = props["showsHorizontalScrollIndicator"] as? Bool {
            scrollView.showsHorizontalScrollIndicator = showsHorizontal
        }
        
        // Bouncing behavior
        if let bounces = props["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        // Paging behavior
        if let pagingEnabled = props["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        // Scroll event throttling
        if let scrollEventThrottle = props["scrollEventThrottle"] as? Float {
            // Store the throttle value as an associated object
            objc_setAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!,
                scrollEventThrottle,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        // Directional lock behavior
        if let directionalLockEnabled = props["directionalLockEnabled"] as? Bool {
            scrollView.isDirectionalLockEnabled = directionalLockEnabled
        }
        
        // iOS-specific scroll bounce behaviors
        if let alwaysBounceVertical = props["alwaysBounceVertical"] as? Bool {
            scrollView.alwaysBounceVertical = alwaysBounceVertical
        }
        
        if let alwaysBounceHorizontal = props["alwaysBounceHorizontal"] as? Bool {
            scrollView.alwaysBounceHorizontal = alwaysBounceHorizontal
        }
        
        // Background color
        if let bgColorStr = props["backgroundColor"] as? String {
            scrollView.backgroundColor = UIColorFromHex(bgColorStr)
        }
        
        // Apply border styling
        applyBorderStyling(to: scrollView, with: props)
        
        // Scrolling direction - allow horizontal, vertical or both
        let horizontal = props["horizontal"] as? Bool ?? false
        
        if horizontal {
            // For horizontal scrolling
            scrollView.alwaysBounceVertical = false
            scrollView.alwaysBounceHorizontal = true
        } else {
            // Default to vertical scrolling
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = false
        }
        
        // Apply opacity
        if let opacity = props["opacity"] as? CGFloat {
            scrollView.alpha = opacity
        }
        
        // Apply standard Yoga layout props
        applyLayoutProps(scrollView, props: props)
    }
    
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // If we need to handle events, create a delegate
        if eventTypes.contains("scroll") || eventTypes.contains("scrollBegin") || 
           eventTypes.contains("scrollEnd") || eventTypes.contains("momentumScrollBegin") || 
           eventTypes.contains("momentumScrollEnd") {
            
            // Create and store delegate that bridges to our callback
            let delegate = ScrollViewDelegate(viewId: viewId, callback: eventCallback)
            
            // Set throttle value if provided earlier
            if let throttle = objc_getAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!
            ) as? Float {
                delegate.scrollEventThrottle = throttle
            }
            
            // Track which events this delegate should handle
            delegate.enabledEvents = eventTypes
            
            scrollView.delegate = delegate
            scrollViewDelegates[scrollView] = delegate
            
            // Debug
            print("Added scroll event listeners for: \(eventTypes.joined(separator: ", "))")
        }
    }
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // If removing all scroll events, remove delegate entirely
        if eventTypes.contains("scroll") || eventTypes.contains("scrollEnd") {
            scrollView.delegate = nil
            scrollViewDelegates.removeValue(forKey: scrollView)
        } else if let delegate = scrollViewDelegates[scrollView] {
            // Otherwise, just update which events to track
            delegate.enabledEvents = delegate.enabledEvents.filter { !eventTypes.contains($0) }
            
            // If no events left, remove the delegate
            if delegate.enabledEvents.isEmpty {
                scrollView.delegate = nil
                scrollViewDelegates.removeValue(forKey: scrollView)
            }
        }
    }
    
    // Helper to apply border styling
    private static func applyBorderStyling(to view: UIView, with props: [String: Any]) {
        // Border radius
        if let borderRadius = props["borderRadius"] as? CGFloat {
            view.layer.cornerRadius = borderRadius
            view.clipsToBounds = true
        }
        
        // Border properties
        if let borderWidth = props["borderWidth"] as? CGFloat {
            view.layer.borderWidth = borderWidth
        }
        
        if let borderColor = props["borderColor"] as? String {
            view.layer.borderColor = UIColorFromHex(borderColor).cgColor
        }
        
        // Individual corner radii
        let corners: [(String, CACornerMask)] = [
            ("borderTopLeftRadius", .layerMinXMinYCorner),
            ("borderTopRightRadius", .layerMaxXMinYCorner),
            ("borderBottomLeftRadius", .layerMinXMaxYCorner),
            ("borderBottomRightRadius", .layerMaxXMaxYCorner)
        ]
        
        var hasCustomCornerRadius = false
        
        for (propName, cornerMask) in corners {
            if let radius = props[propName] as? CGFloat {
                hasCustomCornerRadius = true
                view.layer.cornerRadius = radius // This will be overridden if multiple corners have different values
                view.layer.maskedCorners.insert(cornerMask)
            }
        }
        
        if hasCustomCornerRadius {
            view.clipsToBounds = true
        }
    }
}

// Helper class to bridge UIScrollViewDelegate events to our callback system with throttling
class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    private let viewId: String
    private let callback: (String, String, [String: Any]) -> Void
    
    // Tracking which events this delegate should handle
    var enabledEvents: [String] = []
    
    // Scroll throttling state
    var scrollEventThrottle: Float = 0 // In milliseconds
    private var lastScrollEventTime: TimeInterval = 0
    
    init(viewId: String, callback: @escaping (String, String, [String: Any]) -> Void) {
        self.viewId = viewId
        self.callback = callback
        super.init()
    }
    
    // Called when scroll view is scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard enabledEvents.contains("scroll") else { return }
        
        let now = Date().timeIntervalSince1970 * 1000 // Current time in ms
        
        // Apply throttling if needed
        if scrollEventThrottle > 0 {
            if (now - lastScrollEventTime) < Double(scrollEventThrottle) {
                return // Skip this event due to throttle
            }
        }
        
        lastScrollEventTime = now
        
        // Send scroll event
        callback(viewId, "scroll", [
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
            "zoomScale": scrollView.zoomScale,
            "timestamp": now
        ])
    }
    
    // Called when user begins dragging scroll view
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard enabledEvents.contains("scrollBegin") else { return }
        
        callback(viewId, "scrollBegin", [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
    
    // Called when dragging ends and deceleration begins
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard enabledEvents.contains("scrollEnd") else { return }
        
        if !decelerate {
            callback(viewId, "scrollEnd", [
                "contentOffset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ]
            ])
        }
    }
    
    // Called when scroll view finishes decelerating
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard enabledEvents.contains("scrollEnd") else { return }
        
        callback(viewId, "scrollEnd", [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
    
    // Called when momentum scrolling begins
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard enabledEvents.contains("momentumScrollBegin") else { return }
        
        callback(viewId, "momentumScrollBegin", [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
    
    // Called when momentum scrolling ends
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard enabledEvents.contains("momentumScrollEnd") else { return }
        
        callback(viewId, "momentumScrollEnd", [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
}
