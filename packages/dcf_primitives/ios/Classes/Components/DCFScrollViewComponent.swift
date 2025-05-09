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
        
        // Get the farthest right and bottom edges
        for subview in scrollView.subviews {
            let right = subview.frame.origin.x + subview.frame.size.width
            let bottom = subview.frame.origin.y + subview.frame.size.height
            
            maxWidth = max(maxWidth, right)
            maxHeight = max(maxHeight, bottom)
        }
        
        // Add some padding to ensure content is fully scrollable
        maxWidth += 20
        maxHeight += 20
        
        // Ensure content size is at least as large as the scroll view bounds
        maxWidth = max(maxWidth, scrollView.bounds.width)
        maxHeight = max(maxHeight, scrollView.bounds.height)
        
        // Determine if this is horizontal or vertical scrolling
        let isHorizontal = scrollView.alwaysBounceHorizontal
        
        // Set different content sizes based on orientation
        if isHorizontal {
            scrollView.contentSize = CGSize(width: maxWidth, height: scrollView.bounds.height)
            print("📏 Set horizontal content size: \(maxWidth) x \(scrollView.bounds.height)")
        } else {
            scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: maxHeight)
            print("📏 Set vertical content size: \(scrollView.bounds.width) x \(maxHeight)")
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
        default:
            return false
        }
        
        return false
    }
}

// Custom scroll view that automatically manages its content size
class DCFAutoContentScrollView: UIScrollView {
    private var isUpdatingContentSize = false
    
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
    }
    
    // Called when the scroll view is registered with a node ID
    func didRegisterWithNodeId(_ nodeId: String) {
        print("📜 ScrollView registered with node ID: \(nodeId)")
        
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
        
        // Add some padding
        maxWidth += 20
        maxHeight += 20
        
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
        
        print("📐 Auto-calculated content size: \(contentSize.width) x \(contentSize.height) for frame \(frame.width) x \(frame.height)")
        isUpdatingContentSize = false
    }
    
    // Override layout methods to ensure content size is updated after layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Recalculate after layout completes
        DispatchQueue.main.async { [weak self] in
            self?.recalculateContentSize()
        }
    }
    
    // Override content size setter for debugging
    override var contentSize: CGSize {
        didSet {
            if contentSize.width == 0 || contentSize.height == 0 {
                print("⚠️ Zero contentSize detected, dimensions: \(contentSize.width) x \(contentSize.height)")
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
}
