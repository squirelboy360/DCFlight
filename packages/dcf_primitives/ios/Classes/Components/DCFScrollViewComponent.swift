import UIKit
import yoga
import DCFlight

class DCFScrollViewComponent: NSObject, DCFComponent, ComponentMethodHandler, UIScrollViewDelegate {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a scroll view
        let scrollView = UIScrollView()
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
        
        return true
    }
    
    // Custom layout for scroll view
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        guard let scrollView = view as? UIScrollView else { return }
        
        // Set the frame of the scroll view
        scrollView.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
        
        // Update content size based on subviews
        var maxWidth: CGFloat = scrollView.bounds.width
        var maxHeight: CGFloat = scrollView.bounds.height
        
        for subview in scrollView.subviews {
            let right = subview.frame.origin.x + subview.frame.size.width
            let bottom = subview.frame.origin.y + subview.frame.size.height
            
            maxWidth = max(maxWidth, right)
            maxHeight = max(maxHeight, bottom)
        }
        
        // Determine if this is horizontal or vertical scrolling
        let isHorizontal = scrollView.alwaysBounceHorizontal
        
        if isHorizontal {
            scrollView.contentSize = CGSize(width: maxWidth, height: scrollView.bounds.height)
        } else {
            scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: maxHeight)
        }
    }
    
    // Handle scroll view delegate methods
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        triggerEvent(on: scrollView, eventType: "onScrollBegin", eventData: [:])
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