import UIKit
import dcflight

/// Component that implements a page view (similar to UIPageViewController)
class DCFPageViewComponent: NSObject, DCFComponent, ComponentMethodHandler, UIScrollViewDelegate {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a custom page view
        let pageView = PageView()
        pageView.componentDelegate = self
        
        // Apply props
        updateView(pageView, withProps: props)
        
        return pageView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let pageView = view as? PageView else { return false }
        
        // Update initial page
        if let initialPage = props["initialPage"] as? Int {
            pageView.currentPage = initialPage
        }
        
        // Update indicator visibility
        if let showIndicator = props["showIndicator"] as? Bool {
            pageView.showsPageIndicator = showIndicator
        }
        
        // Update indicator colors
        if let indicatorColor = props["indicatorColor"] as? String {
            pageView.pageIndicatorColor = ColorUtilities.color(fromHexString: indicatorColor)
        }
        
        if let inactiveIndicatorColor = props["inactiveIndicatorColor"] as? String {
            pageView.inactivePageIndicatorColor = ColorUtilities.color(fromHexString: inactiveIndicatorColor)
        }
        
        // Update swipe behavior
        if let enableSwipe = props["enableSwipe"] as? Bool {
            pageView.isScrollEnabled = enableSwipe
        }
        
        // Update infinite scrolling
        if let infinite = props["infinite"] as? Bool {
            pageView.infiniteScrolling = infinite
        }
        
        return true
    }
    
    // MARK: - Component Methods
    
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        guard let pageView = view as? PageView else { return false }
        
        switch methodName {
        case "goToPage":
            if let pageIndex = args["index"] as? Int {
                let animated = args["animated"] as? Bool ?? true
                pageView.scrollToPage(pageIndex, animated: animated)
                return true
            }
        case "nextPage":
            let animated = args["animated"] as? Bool ?? true
            pageView.scrollToNextPage(animated: animated)
            return true
        case "previousPage":
            let animated = args["animated"] as? Bool ?? true
            pageView.scrollToPreviousPage(animated: animated)
            return true
        default:
            return false
        }
        
        return false
    }
    
    // MARK: - Scroll View Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let pageView = scrollView as? PageView else { return }
        
        // Update page indicator
        pageView.updatePageIndicator()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let pageView = scrollView as? PageView else { return }
        
        // Update current page
        let previousPage = pageView.currentPage
        pageView.updateCurrentPage()
        
        // Notify if page changed
        if previousPage != pageView.currentPage {
            triggerEvent(on: pageView, eventType: "onPageChanged", eventData: ["page": pageView.currentPage])
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // Same behavior as when decelerating ends
        scrollViewDidEndDecelerating(scrollView)
    }
    
    // MARK: - View Registration
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        if let pageView = view as? PageView {
            pageView.layoutSubviews()
            
            // Notify for initial page
            DispatchQueue.main.async {
                self.triggerEvent(on: pageView, eventType: "onPageChanged", eventData: ["page": pageView.currentPage])
                self.triggerEvent(on: pageView, eventType: "onViewId", eventData: ["id": nodeId])
            }
        }
    }
}

/// Custom page view implementation
class PageView: UIScrollView {
    // Current page index
    var currentPage: Int = 0 {
        didSet {
            updatePageIndicator()
        }
    }
    
    // Page indicator
    var showsPageIndicator: Bool = true {
        didSet {
            pageControl.isHidden = !showsPageIndicator
        }
    }
    
    // Page indicator colors
    var pageIndicatorColor: UIColor? {
        didSet {
            if let color = pageIndicatorColor {
                pageControl.currentPageIndicatorTintColor = color
            }
        }
    }
    
    var inactivePageIndicatorColor: UIColor? {
        didSet {
            if let color = inactivePageIndicatorColor {
                pageControl.pageIndicatorTintColor = color
            }
        }
    }
    
    // Infinite scrolling
    var infiniteScrolling: Bool = false
    
    // Component delegate
    weak var componentDelegate: DCFPageViewComponent?
    
    // Page control
    private let pageControl = UIPageControl()
    
    // Reusable content view
    private let contentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Set up scroll view
        isPagingEnabled = true
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        bounces = true
        
        // Set up content view
        addSubview(contentView)
        
        // Set up page control
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update content view frame
        contentView.frame = CGRect(x: 0, y: 0, width: frame.width * CGFloat(subviews.count), height: frame.height)
        
        // Position child views
        var pageIndex = 0
        for subview in subviews {
            if subview != pageControl && subview != contentView {
                let pageFrame = CGRect(
                    x: CGFloat(pageIndex) * frame.width,
                    y: 0,
                    width: frame.width,
                    height: frame.height
                )
                subview.frame = pageFrame
                pageIndex += 1
            }
        }
        
        // Update content size
        contentSize = CGSize(width: frame.width * CGFloat(pageIndex), height: frame.height)
        
        // Update page control
        pageControl.numberOfPages = pageIndex
        updatePageIndicator()
        
        // Scroll to current page
        scrollTo(page: currentPage, animated: false)
    }
    
    // MARK: - Page Navigation
    
    func scrollToPage(_ page: Int, animated: Bool) {
        currentPage = max(0, min(page, pageControl.numberOfPages - 1))
        scrollTo(page: currentPage, animated: animated)
    }
    
    func scrollToNextPage(animated: Bool) {
        let nextPage = currentPage + 1
        if nextPage < pageControl.numberOfPages {
            scrollToPage(nextPage, animated: animated)
        } else if infiniteScrolling {
            scrollToPage(0, animated: animated)
        }
    }
    
    func scrollToPreviousPage(animated: Bool) {
        let prevPage = currentPage - 1
        if prevPage >= 0 {
            scrollToPage(prevPage, animated: animated)
        } else if infiniteScrolling {
            scrollToPage(pageControl.numberOfPages - 1, animated: animated)
        }
    }
    
    private func scrollTo(page: Int, animated: Bool) {
        let offset = CGPoint(x: CGFloat(page) * frame.width, y: 0)
        setContentOffset(offset, animated: animated)
    }
    
    // MARK: - Page Tracking
    
    func updateCurrentPage() {
        let pageWidth = frame.width
        let pageIndex = Int(round(contentOffset.x / pageWidth))
        currentPage = max(0, min(pageIndex, pageControl.numberOfPages - 1))
    }
    
    func updatePageIndicator() {
        pageControl.currentPage = currentPage
    }
}
