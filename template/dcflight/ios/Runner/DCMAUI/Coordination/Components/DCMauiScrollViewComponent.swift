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

        // REMOVED contentWidth and contentHeight handling
        
        // Handle contentInset if specified
        if let topInset = props["contentInsetTop"] as? CGFloat,
           let leftInset = props["contentInsetLeft"] as? CGFloat,
           let bottomInset = props["contentInsetBottom"] as? CGFloat,
           let rightInset = props["contentInsetRight"] as? CGFloat {
            scrollView.contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        }
        
        // Handle scrollEnabled
        if let scrollEnabled = props["scrollEnabled"] as? Bool {
            scrollView.isScrollEnabled = scrollEnabled
        }

        // Handle scroll event throttle
        if let throttle = props["scrollEventThrottle"] as? Double {
            // Store throttle value on the view using associated object
            objc_setAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!,
                throttle,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }

        // Register/Unregister delegate based on event listeners
        let eventProps = props.filter { $0.key.starts(with: "onScroll") || $0.key.starts(with: "onMomentum") }
        if !eventProps.isEmpty {
            ScrollViewDelegateHandler.shared.registerScrollView(scrollView)
        } else {
            // Consider if unregistering is needed if props are removed later
            // ScrollViewDelegateHandler.shared.unregisterScrollView(scrollView)
        }
        
        return true
    }
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        guard let scrollView = view as? UIScrollView else { return }

        // Apply frame layout to the scroll view itself
        scrollView.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)

        // Calculate content size based on the layout of children
        // This assumes the direct child of the ScrollView in Yoga represents the content
        var contentWidth: CGFloat = 0
        var contentHeight: CGFloat = 0

        // Find the immediate child view (assuming one content container view)
        if let contentView = scrollView.subviews.first {
            // Use the frame calculated by Yoga for the content view
            // The frame's origin might not be (0,0) relative to the scrollview,
            // so contentSize needs bottom-right corner.
            contentWidth = contentView.frame.origin.x + contentView.frame.width
            contentHeight = contentView.frame.origin.y + contentView.frame.height
        } else {
            // Fallback if no child view, use scrollview's bounds (no scrolling)
            contentWidth = layout.width
            contentHeight = layout.height
        }
        
        // Ensure contentSize is at least the size of the scroll view's bounds
        contentWidth = max(contentWidth, layout.width)
        contentHeight = max(contentHeight, layout.height)

        // Update contentSize if it has changed
        if scrollView.contentSize.width != contentWidth || scrollView.contentSize.height != contentHeight {
            print("🔄 Updating ScrollView contentSize: w=\(contentWidth), h=\(contentHeight)")
            // Apply contentSize update on the main thread
            DispatchQueue.main.async {
                 scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
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
        
        print("📜 Scrolling to position: (\(x), \(y)), animated: \(animated)")
        
        // Apply scroll on main thread
        if Thread.isMainThread {
            view.setContentOffset(CGPoint(x: x, y: y), animated: animated)
        } else {
            DispatchQueue.main.async {
                view.setContentOffset(CGPoint(x: x, y: y), animated: animated)
            }
        }
    }
    
    /// Handle scrollToEnd method calls from Dart (scroll to bottom)
    func scrollToEnd(view: UIScrollView, args: [String: Any]) {
        let animated = args["animated"] as? Bool ?? true
        
        // Calculate the bottom offset
        let bottomOffset = CGPoint(
            x: 0,
            y: max(0, view.contentSize.height - view.bounds.height + view.contentInset.bottom)
        )
        
        print("📜 Scrolling to bottom: \(bottomOffset.y), animated: \(animated)")
        
        // Apply scroll on main thread
        if Thread.isMainThread {
            view.setContentOffset(bottomOffset, animated: animated)
        } else {
            DispatchQueue.main.async {
                view.setContentOffset(bottomOffset, animated: animated)
            }
        }
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Set accessibility identifier for easier debugging
        view.accessibilityIdentifier = nodeId
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
        print("📞 Registered event callback for ScrollView \(viewId)")
    }
    
    // UIScrollViewDelegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let (viewId, callback) = scrollViewCallbacks[scrollView] else { return }

        // Get throttle value (expecting Double now)
        let throttle = objc_getAssociatedObject(
            scrollView,
            UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!
        ) as? Double ?? 16.0 // Default throttle in ms

        let currentTime = Date().timeIntervalSince1970 * 1000 // Current time in ms

        // Check if we should send an event based on throttle
        if let lastTime = lastEventTimes[scrollView], currentTime - lastTime < throttle {
            return // Throttled
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
            "layoutMeasurement": [ // Bounds of the scrollview
                "width": scrollView.bounds.width,
                "height": scrollView.bounds.height
            ],
            "zoomScale": scrollView.zoomScale, // Added zoomScale
            "timestamp": currentTime
        ]

        // Send event using the registered callback with "onScroll"
        callback(viewId, "onScroll", eventData)
    }
}
