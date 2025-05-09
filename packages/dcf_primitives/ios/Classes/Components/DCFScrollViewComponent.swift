import UIKit
import dcflight

class DCFScrollViewComponent: NSObject, DCFComponent, ComponentMethodHandler, UIScrollViewDelegate {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a custom scroll view instead of standard UIScrollView
        let scrollView = DCFAutoContentScrollView()
        scrollView.delegate = self
        
        // Apply initial styling
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.bounces = true
        
        // Apply props
        updateView(scrollView, withProps: props)
        
        return scrollView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let scrollView = view as? UIScrollView else { return false }
        
        // Set shows indicator if specified
        if let showsIndicator = props["showsIndicator"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsIndicator
            scrollView.showsHorizontalScrollIndicator = showsIndicator
        }
        
        // Set bounces if specified
        if let bounces = props["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        // Set horizontal if specified
        if let horizontal = props["horizontal"] as? Bool {
            // Configure for horizontal or vertical scrolling
            if horizontal {
                scrollView.alwaysBounceHorizontal = true
                scrollView.alwaysBounceVertical = false
                scrollView.showsHorizontalScrollIndicator = scrollView.showsHorizontalScrollIndicator
                scrollView.showsVerticalScrollIndicator = false
            } else {
                scrollView.alwaysBounceHorizontal = false
                scrollView.alwaysBounceVertical = true
                scrollView.showsHorizontalScrollIndicator = false
                scrollView.showsVerticalScrollIndicator = scrollView.showsVerticalScrollIndicator
            }
        }
        
        // Set paging enabled if specified
        if let pagingEnabled = props["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        // Set scroll enabled if specified
        if let scrollEnabled = props["scrollEnabled"] as? Bool {
            scrollView.isScrollEnabled = scrollEnabled
        }
        
        // Set clipping if specified (default is true)
        if let clipsToBounds = props["clipsToBounds"] as? Bool {
            scrollView.clipsToBounds = clipsToBounds
        }
        
        // Handle background color through StyleSheet
        if let backgroundColor = props["backgroundColor"] as? String {
            scrollView.backgroundColor = ColorUtilities.color(fromHexString: backgroundColor)
        }
        
        // Set content inset if specified
        if let contentInset = props["contentInset"] as? [String: Any] {
            let top = (contentInset["top"] as? CGFloat) ?? 0
            let left = (contentInset["left"] as? CGFloat) ?? 0
            let bottom = (contentInset["bottom"] as? CGFloat) ?? 0
            let right = (contentInset["right"] as? CGFloat) ?? 0
            scrollView.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        // Automatically adjust content insets
        if let adjustAutomatically = props["automaticallyAdjustContentInsets"] as? Bool {
            if #available(iOS 11.0, *) {
                scrollView.contentInsetAdjustmentBehavior = adjustAutomatically ? .automatic : .never
            }
        }
        
        // Store content offset start value for later application
        if let offsetStart = props["contentOffsetStart"] as? CGFloat {
            objc_setAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "contentOffsetStart".hashValue)!,
                offsetStart,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            // Set initial offset after short delay to ensure content size is properly calculated
            if let customScrollView = scrollView as? DCFAutoContentScrollView {
                customScrollView.initialOffsetStart = offsetStart
            }
        }
        
        // After updating properties, recalculate content size if it's our custom scroll view
        if let customScrollView = scrollView as? DCFAutoContentScrollView {
            customScrollView.recalculateContentSize()
        }
        
        return true
    }
    
    // Custom layout for scroll view
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // Set the frame of the scroll view
        scrollView.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
        
        // Force layout of subviews first
        scrollView.layoutIfNeeded()
        
        // Update content size after layout completed
        if let customScrollView = scrollView as? DCFAutoContentScrollView {
            // Our custom subclass will handle this
            customScrollView.recalculateContentSize()
        } else {
            // For standard UIScrollView, calculate manually
            updateContentSize(scrollView)
        }
    }
    
    // Calculate and update content size based on subviews
    private func updateContentSize(_ scrollView: UIScrollView) {
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        // Get the farthest right and bottom edges of all subviews
        for subview in scrollView.subviews {
            let right = subview.frame.origin.x + subview.frame.size.width
            let bottom = subview.frame.origin.y + subview.frame.size.height
            
            maxWidth = max(maxWidth, right)
            maxHeight = max(maxHeight, bottom)
        }
        
        // Add some padding to ensure content is fully scrollable
        maxWidth += 40 // Increased padding for better visibility of first item
        maxHeight += 40
        
        // Ensure content size is at least as large as the scroll view bounds
        maxWidth = max(maxWidth, scrollView.bounds.width)
        maxHeight = max(maxHeight, scrollView.bounds.height)
        
        // Determine if this is horizontal or vertical scrolling
        let isHorizontal = scrollView.alwaysBounceHorizontal
        
        // Set different content sizes based on orientation
        if isHorizontal {
            scrollView.contentSize = CGSize(width: maxWidth, height: scrollView.bounds.height)
        } else {
            scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: maxHeight)
        }
        
        // Apply initial offset from contentOffsetStart if available
        if let offsetStart = objc_getAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "contentOffsetStart".hashValue)!
             ) as? CGFloat {
            // Apply with small delay to ensure content size is set
            DispatchQueue.main.async {
                let offset = isHorizontal ? 
                    CGPoint(x: offsetStart, y: 0) : 
                    CGPoint(x: 0, y: offsetStart)
                scrollView.setContentOffset(offset, animated: false)
            }
        }
    }
    
    // Add a custom view hook for when new children are added
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Store node ID on the view
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "nodeId".hashValue)!, 
                               nodeId, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Observe changes to the view hierarchy to update content size
        if let scrollView = view as? DCFAutoContentScrollView {
            scrollView.didRegisterWithNodeId(nodeId)
        }
    }
    
    // Handle scroll view delegate methods
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // Check for direct event callback first
        if let viewId = objc_getAssociatedObject(scrollView, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String,
           let callback = objc_getAssociatedObject(scrollView, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!) as? (String, String, [String: Any]) -> Void {
            callback(viewId, "onScrollBegin", [:])
        } else {
            // Fall back to generic event
            triggerEvent(on: scrollView, eventType: "onScrollBegin", eventData: [:])
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            triggerEvent(on: scrollView, eventType: "onScrollEnd", eventData: [
                "contentOffset": [
                    "x": scrollView.contentOffset.x,
                    "y": scrollView.contentOffset.y
                ]
            ])
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        triggerEvent(on: scrollView, eventType: "onScrollEnd", eventData: [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
    
    // Handle scroll events for continuous updates
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // This can be expensive, so we might want to throttle this in production
        triggerEvent(on: scrollView, eventType: "onScroll", eventData: [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
    
    // Handle component methods
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        guard let scrollView = view as? UIScrollView else { return false }
        
        switch methodName {
        case "scrollToPosition":
            if let x = args["x"] as? CGFloat, let y = args["y"] as? CGFloat {
                let animated = args["animated"] as? Bool ?? true
                scrollView.setContentOffset(CGPoint(x: x, y: y), animated: animated)
                return true
            }
        case "scrollToTop":
            let animated = args["animated"] as? Bool ?? true
            scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: 0), animated: animated)
            return true
        case "scrollToBottom":
            let animated = args["animated"] as? Bool ?? true
            let bottomOffset = CGPoint(x: scrollView.contentOffset.x, 
                                     y: scrollView.contentSize.height - scrollView.bounds.height)
            scrollView.setContentOffset(bottomOffset, animated: animated)
            return true
        case "flashScrollIndicators":
            scrollView.flashScrollIndicators()
            return true
        default:
            return false
        }
        
        return false
    }
}

// Custom scroll view that automatically manages its content size
class DCFAutoContentScrollView: UIScrollView {
    private var isUpdatingContentSize = false
    var initialOffsetStart: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupScrollView()
    }
    
    private func setupScrollView() {
        clipsToBounds = true
        backgroundColor = .clear
        
        // Fix for safe area handling
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .automatic
        }
    }
    
    // Called when the scroll view is registered with a node ID
    func didRegisterWithNodeId(_ nodeId: String) {
        // Force an initial content size calculation
        DispatchQueue.main.async { [weak self] in
            self?.recalculateContentSize()
        }
    }
    
    // Public method to recalculate content size
    func recalculateContentSize() {
        guard !isUpdatingContentSize else { return }
        isUpdatingContentSize = true
        
        // Calculate based on subview frames
        var maxWidth: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for subview in subviews {
            let right = subview.frame.origin.x + subview.frame.size.width
            let bottom = subview.frame.origin.y + subview.frame.size.height
            
            maxWidth = max(maxWidth, right)
            maxHeight = max(maxHeight, bottom)
        }
        
        // Add increased padding to ensure content is fully scrollable
        // This is essential for first item visibility - especially for the first items at the beginning
        maxWidth += 40  // Increased padding
        maxHeight += 40 // Increased padding
        
        // Set minimum content size to the scroll view's frame
        maxWidth = max(maxWidth, bounds.width)
        maxHeight = max(maxHeight, bounds.height)
        
        // Set based on scrolling direction
        let isHorizontal = alwaysBounceHorizontal
        
        // Use a meaningful minimum content size
        if isHorizontal {
            if maxWidth <= bounds.width {
                maxWidth = bounds.width + 1  // Force slightly larger than bounds to enable scrolling
            }
            contentSize = CGSize(width: maxWidth, height: bounds.height)
        } else {
            if maxHeight <= bounds.height {
                maxHeight = bounds.height + 1  // Force slightly larger than bounds to enable scrolling
            }
            contentSize = CGSize(width: bounds.width, height: maxHeight)
        }
        
        isUpdatingContentSize = false
        
        // Apply initial content offset if specified
        if let offsetStart = initialOffsetStart {
            let offset = isHorizontal ? 
                CGPoint(x: offsetStart, y: 0) : 
                CGPoint(x: 0, y: offsetStart)
            
            // Apply with a short delay to ensure content size is properly set
            DispatchQueue.main.async { [weak self] in
                self?.setContentOffset(offset, animated: false)
                self?.initialOffsetStart = nil  // Apply only once
            }
        }
    }
    
    // IMPORTANT: Add inset padding to avoid the issue with first items
    override var contentOffset: CGPoint {
        didSet {
            // For debugging - uncomment if needed
            // print("💠 Content offset changed: \(contentOffset)")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // When layout happens, ensure content offset is maintained
        // This is critical for preserving scroll position during layout changes
        let wasAtStart = (alwaysBounceHorizontal && contentOffset.x <= 0) || 
                        (!alwaysBounceHorizontal && contentOffset.y <= 0)
                        
        super.layoutSubviews()
        
        // Recalculate after layout completes
        DispatchQueue.main.async { [weak self] in
            self?.recalculateContentSize()
            
            // If we were at the start, ensure we can see the first item
            if wasAtStart, let self = self {
                // Fix issue where first item is not visible by adding a small offset
                let isHorizontal = self.alwaysBounceHorizontal
                
                // Ensure we can always see the beginning
                if isHorizontal && self.contentOffset.x > 0 {
                    self.contentOffset = CGPoint(x: 0, y: self.contentOffset.y)
                } else if !isHorizontal && self.contentOffset.y > 0 {
                    self.contentOffset = CGPoint(x: self.contentOffset.x, y: 0)
                }
            }
        }
    }
    
    // Override content size setter for fixing edge cases
    override var contentSize: CGSize {
        didSet {
            if contentSize.width == 0 || contentSize.height == 0 {
                // Prevent zero content size
                if contentSize.width == 0 {
                    contentSize.width = max(1, bounds.width)
                }
                if contentSize.height == 0 {
                    contentSize.height = max(1, bounds.height)
                }
            }
        }
    }
    
    // Override the method that is called when a subview is added
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        
        // Schedule content size update
        DispatchQueue.main.async { [weak self] in
            self?.recalculateContentSize()
        }
    }
    
    // Override method when frame changes
    override var frame: CGRect {
        didSet {
            if frame != oldValue {
                DispatchQueue.main.async { [weak self] in
                    self?.recalculateContentSize()
                }
            }
        }
    }
    
    // Add a slight offset at the beginning to ensure first item visibility
    func ensureFirstItemVisible() {
        let isHorizontal = alwaysBounceHorizontal
        
        if isHorizontal {
            // For horizontal scrolling, ensure contentInset has left padding
            if contentInset.left < 10 {
                var insets = contentInset
                insets.left = 10
                contentInset = insets
            }
        } else {
            // For vertical scrolling, ensure contentInset has top padding
            if contentInset.top < 10 {
                var insets = contentInset
                insets.top = 10
                contentInset = insets
            }
        }
    }
}
