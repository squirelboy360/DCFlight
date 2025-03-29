import UIKit
import yoga

class DCMauiScrollComponent: NSObject, DCMauiComponentProtocol {
    private static var scrollViewDelegates: [UIScrollView: ScrollViewDelegate] = [:]
    
    static func createView(props: [String: Any]) -> UIView {
        // Create DirectScrollView - our optimized implementation
        let scrollView = DirectScrollView()
        
        // Basic configuration
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = true
        scrollView.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        // Create yoga node for layout
        let _ = DCMauiLayoutManager.shared.createYogaNode(for: scrollView)
        
        // Apply properties
        updateView(scrollView, props: props)
        return scrollView
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        guard let scrollView = view as? DirectScrollView else { return }
        
        if let showsVertical = props["showsVerticalScrollIndicator"] as? Bool {
            scrollView.showsVerticalScrollIndicator = showsVertical
        }
        
        if let showsHorizontal = props["showsHorizontalScrollIndicator"] as? Bool {
            scrollView.showsHorizontalScrollIndicator = showsHorizontal
        }
        
        if let bounces = props["bounces"] as? Bool {
            scrollView.bounces = bounces
        }
        
        if let pagingEnabled = props["pagingEnabled"] as? Bool {
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        if let scrollEventThrottle = props["scrollEventThrottle"] as? Float {
            objc_setAssociatedObject(
                scrollView, 
                UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!,
                scrollEventThrottle,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        if let directionalLockEnabled = props["directionalLockEnabled"] as? Bool {
            scrollView.isDirectionalLockEnabled = directionalLockEnabled
        }
        
        if let alwaysBounceVertical = props["alwaysBounceVertical"] as? Bool {
            scrollView.alwaysBounceVertical = alwaysBounceVertical
        }
        
        if let alwaysBounceHorizontal = props["alwaysBounceHorizontal"] as? Bool {
            scrollView.alwaysBounceHorizontal = alwaysBounceHorizontal
        }
        
        let horizontal = props["horizontal"] as? Bool ?? false
        scrollView.isHorizontal = horizontal
        
        if horizontal {
            scrollView.alwaysBounceVertical = false
            scrollView.alwaysBounceHorizontal = true
        } else {
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = false
        }
        
        if let bgColorStr = props["backgroundColor"] as? String {
            scrollView.backgroundColor = UIColorFromHex(bgColorStr)
        }
        
        applyBorderStyling(to: scrollView, with: props)
        
        if let opacity = props["opacity"] as? CGFloat {
            scrollView.alpha = opacity
        }
        
        applyLayoutProps(scrollView, props: props)
        
        // Store flexWrap property for special handling in layout
        if let flexWrap = props["flexWrap"] as? String {
            objc_setAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "flexWrap".hashValue)!,
                flexWrap,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        scrollView.layoutSubviews()
    }
    
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let scrollView = view as? UIScrollView else { return }
        
        if eventTypes.contains("scroll") || eventTypes.contains("scrollBegin") || 
           eventTypes.contains("scrollEnd") || eventTypes.contains("momentumScrollBegin") || 
           eventTypes.contains("momentumScrollEnd") {
            
            let delegate = ScrollViewDelegate(viewId: viewId, callback: eventCallback)
            
            if let throttle = objc_getAssociatedObject(
                scrollView,
                UnsafeRawPointer(bitPattern: "scrollEventThrottle".hashValue)!
            ) as? Float {
                delegate.scrollEventThrottle = throttle
            }
            
            delegate.enabledEvents = eventTypes
            
            scrollView.delegate = delegate
            scrollViewDelegates[scrollView] = delegate
        }
    }
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let scrollView = view as? UIScrollView else { return }
        
        if eventTypes.contains("scroll") || eventTypes.contains("scrollEnd") {
            scrollView.delegate = nil
            scrollViewDelegates.removeValue(forKey: scrollView)
        } else if let delegate = scrollViewDelegates[scrollView] {
            delegate.enabledEvents = delegate.enabledEvents.filter { !eventTypes.contains($0) }
            
            if delegate.enabledEvents.isEmpty {
                scrollView.delegate = nil
                scrollViewDelegates.removeValue(forKey: scrollView)
            }
        }
    }
    
    private static func applyBorderStyling(to view: UIView, with props: [String: Any]) {
        if let borderRadius = props["borderRadius"] as? CGFloat {
            view.layer.cornerRadius = borderRadius
            view.clipsToBounds = true
        }
        
        if let borderWidth = props["borderWidth"] as? CGFloat {
            view.layer.borderWidth = borderWidth
        }
        
        if let borderColor = props["borderColor"] as? String {
            view.layer.borderColor = UIColorFromHex(borderColor).cgColor
        }
        
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
                view.layer.cornerRadius = radius
                view.layer.maskedCorners.insert(cornerMask)
            }
        }
        
        if hasCustomCornerRadius {
            view.clipsToBounds = true
        }
    }
}

// Optimized ScrollView that manages content directly
class DirectScrollView: UIScrollView {
    // Flag to track scroll direction
    var isHorizontal: Bool = false
    
    // Track content elements for cleanup
    private var contentElements: [UIView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func addSubview(_ view: UIView) {
        // Add the view directly to the scroll view
        super.addSubview(view)
        
        // Track content elements for size calculation
        contentElements.append(view)
        
        // Force layout update
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // CRITICAL: Calculate content size based on subview frames
        var contentWidth: CGFloat = 0
        var contentHeight: CGFloat = 0
        
        // Let Yoga calculate layout for all subviews
        for view in self.subviews {
            DCMauiLayoutManager.shared.calculateAndApplyLayout(
                for: view,
                width: isHorizontal ? CGFloat.greatestFiniteMagnitude : self.bounds.width,
                height: isHorizontal ? self.bounds.height : CGFloat.greatestFiniteMagnitude
            )
            
            // Update content dimensions based on view position and size - NO PADDING AT ALL
            contentWidth = max(contentWidth, view.frame.maxX)
            contentHeight = max(contentHeight, view.frame.maxY)
        }
        
        // NO MINIMUM PADDING - exactness is key for percentage layouts
        
        // Set content size based on direction - EXACT SIZE OF CONTENTS
        if isHorizontal {
            self.contentSize = CGSize(
                width: max(contentWidth, bounds.width),
                height: self.bounds.height
            )
            self.alwaysBounceHorizontal = contentWidth > self.bounds.width
        } else {
            self.contentSize = CGSize(
                width: self.bounds.width,
                height: max(contentHeight, bounds.height)
            )
            self.alwaysBounceVertical = contentHeight > self.bounds.height
        }
        
        print("📏 EXACT ScrollView content size: \(self.contentSize) based on content: \(contentWidth) x \(contentHeight)")
        
        // Special handling for flexWrap cases - these need extra attention
        if self.subviews.count > 0 {
            if let wrapProp = objc_getAssociatedObject(
                self,
                UnsafeRawPointer(bitPattern: "flexWrap".hashValue)!
            ) as? String, wrapProp == "wrap" {
                // For wrapped content, trust our calculated size completely
                print("📏 Using exact content height for wrapped content: \(contentHeight)")
            }
        }
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        return true // Helps scrolling work better
    }
    
    // Clear out content elements when removed
    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        if let index = contentElements.firstIndex(of: subview) {
            contentElements.remove(at: index)
        }
    }
}

// Keep ScrollViewDelegate separate - it implements UIScrollViewDelegate
class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
    let viewId: String
    let callback: (String, String, [String: Any]) -> Void
    
    var enabledEvents: [String] = []
    var scrollEventThrottle: Float = 0
    private var lastScrollEventTime: TimeInterval = 0
    
    init(viewId: String, callback: @escaping (String, String, [String: Any]) -> Void) {
        self.viewId = viewId
        self.callback = callback
        super.init()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard enabledEvents.contains("scroll") else { return }
        
        let now = Date().timeIntervalSince1970 * 1000
        
        if scrollEventThrottle > 0 {
            if (now - lastScrollEventTime) < Double(scrollEventThrottle) {
                return
            }
        }
        
        lastScrollEventTime = now
        
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard enabledEvents.contains("scrollBegin") else { return }
        
        callback(viewId, "scrollBegin", [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard enabledEvents.contains("scrollEnd") else { return }
        
        if !decelerate {
            callback(viewId, "scrollEnd", [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ])
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard enabledEvents.contains("scrollEnd") else { return }
        
        callback(viewId, "scrollEnd", [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        guard enabledEvents.contains("momentumScrollBegin") else { return }
        
        callback(viewId, "momentumScrollBegin", [
            "contentOffset": [
                "x": scrollView.contentOffset.x,
                "y": scrollView.contentOffset.y
            ]
        ])
    }
    
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
