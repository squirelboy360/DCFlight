import UIKit
import yoga

class DCMauiScrollComponent: NSObject, DCMauiComponent {
    // Required initializer
    required override init() {
        super.init()
    }
    
    // Use a dictionary instead of array
    private static var scrollViewDelegates = [UIScrollView: DCMauiScrollDelegate]()
    
    func createView(props: [String: Any]) -> UIView {
        // Create scroll view
        let scrollView = UIScrollView()
        
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
        
        // Set up content view constraints - much simpler approach
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            
            // These are critical for proper sizing
            contentView.widthAnchor.constraint(greaterThanOrEqualTo: scrollView.widthAnchor),
        ])
        
        // Apply provided props
        updateView(scrollView, withProps: props)
        
        return scrollView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let scrollView = view as? UIScrollView else { return false }
        
        // Configure scroll behavior
        if let horizontal = props["horizontal"] as? Bool {
            scrollView.alwaysBounceHorizontal = horizontal
            scrollView.alwaysBounceVertical = !horizontal
            
            let contentView = scrollView.viewWithTag(1001)
            
            if horizontal {
                // For horizontal scrolling, make content view height match scroll view
                contentView?.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
            } else {
                // For vertical scrolling, make content view width match scroll view
                contentView?.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
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
        
        // Apply non-layout styling
        DCMauiLayoutManager.shared.applyStyles(to: scrollView, props: props)
        
        // Ensure the content view receives background color if specified
        if let backgroundColor = props["backgroundColor"] as? String,
           let contentView = scrollView.viewWithTag(1001),
           scrollView.backgroundColor == nil || scrollView.backgroundColor == .clear {
            contentView.backgroundColor = ColorUtilities.color(fromHexString: backgroundColor)
            scrollView.backgroundColor = .clear  // Ensure scroll view is transparent
        }
        
        return true
    }
    
    // Apply content size from Dart layout calculations
    func updateContentSize(_ scrollView: UIScrollView, width: CGFloat, height: CGFloat) {
        // Make sure we're not setting a zero content size
        let finalWidth = max(width, scrollView.frame.width)
        let finalHeight = max(height, scrollView.frame.height)
        
        print("📜 Setting scroll content size: \(finalWidth) x \(finalHeight)")
        scrollView.contentSize = CGSize(width: finalWidth, height: finalHeight)
    }
    
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
            
            // Set up callback with explicit UIScrollView type
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
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        if eventTypes.contains("scroll") {
            // Remove delegate
            DCMauiScrollComponent.scrollViewDelegates.removeValue(forKey: scrollView)
            scrollView.delegate = nil
        }
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
}
