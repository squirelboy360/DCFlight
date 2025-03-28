//
//  DCScrollView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// ScrollView component that matches React Native's ScrollView
class DCScrollView: DCBaseView {
    // The actual scroll view
    private let scrollView = UIScrollView()
    
    // Content container
    private let contentView = UIView()
    
    // Refresh control
    private var refreshControl: UIRefreshControl?
    
    // Properties
    private var horizontal: Bool = false
    private var showsVerticalScrollIndicator: Bool = true
    private var showsHorizontalScrollIndicator: Bool = true
    private var scrollEnabled: Bool = true
    private var bounces: Bool = true
    private var pagingEnabled: Bool = false
    private var scrollsToTop: Bool = true
    private var keyboardDismissMode: UIScrollView.KeyboardDismissMode = .none
    private var scrollEventThrottle: CGFloat = 0
    private var lastScrollOffset: CGPoint = .zero
    private var onEndReachedThreshold: CGFloat = 0.5
    private var contentInset: UIEdgeInsets = .zero
    private var scrollIndicatorInsets: UIEdgeInsets = .zero
    
    // Event throttling
    private var lastScrollEventTimestamp: TimeInterval = 0
    private let minScrollEventInterval: TimeInterval = 0.016  // ~60fps
    
    override func setupView() {
        super.setupView()
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        scrollView.isScrollEnabled = scrollEnabled
        scrollView.bounces = bounces
        scrollView.isPagingEnabled = pagingEnabled
        scrollView.scrollsToTop = scrollsToTop
        scrollView.keyboardDismissMode = keyboardDismissMode
        
        // Configure content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        
        // Add subviews
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Set up constraints for scroll view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set up constraints for content view
        setupContentViewConstraints()
    }
    
    private func setupContentViewConstraints() {
        // Remove any existing constraints first
        contentView.removeFromSuperview()
        scrollView.addSubview(contentView)
        
        // Basic constraints that apply regardless of scroll direction
        let contentViewConstraints = [
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ]
        NSLayoutConstraint.activate(contentViewConstraints)
        
        // Constraint content view width and height based on scroll direction
        if horizontal {
            // For horizontal scrolling:
            // - Content view should be as high as the scroll view
            // - But width can be larger (determined by its content)
            let heightConstraint = contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            heightConstraint.priority = .required
            heightConstraint.isActive = true
        } else {
            // For vertical scrolling:
            // - Content view should be as wide as the scroll view
            // - But height can be larger (determined by its content)
            let widthConstraint = contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            widthConstraint.priority = .required
            widthConstraint.isActive = true
        }
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        let needsLayoutUpdate = updateScrollViewProperties(props)
        
        if needsLayoutUpdate {
            setupContentViewConstraints()
        }
    }
    
    private func updateScrollViewProperties(_ props: [String: Any]) -> Bool {
        var needsLayoutUpdate = false
        
        // Handle scroll direction
        if let horizontal = props["horizontal"] as? Bool {
            if horizontal != self.horizontal {
                self.horizontal = horizontal
                needsLayoutUpdate = true
            }
        }
        
        // Handle scroll indicators
        if let showsVerticalScrollIndicator = props["showsVerticalScrollIndicator"] as? Bool {
            self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
            scrollView.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        }
        
        if let showsHorizontalScrollIndicator = props["showsHorizontalScrollIndicator"] as? Bool {
            self.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
            scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        }
        
        // Handle scroll behavior
        if let scrollEnabled = props["scrollEnabled"] as? Bool {
            self.scrollEnabled = scrollEnabled
            scrollView.isScrollEnabled = scrollEnabled
        }
        
        if let bounces = props["bounces"] as? Bool {
            self.bounces = bounces
            scrollView.bounces = bounces
        }
        
        if let pagingEnabled = props["pagingEnabled"] as? Bool {
            self.pagingEnabled = pagingEnabled
            scrollView.isPagingEnabled = pagingEnabled
        }
        
        if let scrollsToTop = props["scrollsToTop"] as? Bool {
            self.scrollsToTop = scrollsToTop
            scrollView.scrollsToTop = scrollsToTop
        }
        
        // Handle keyboard dismiss mode
        if let keyboardDismissMode = props["keyboardDismissMode"] as? String {
            switch keyboardDismissMode {
            case "on-drag":
                self.keyboardDismissMode = .onDrag
            case "interactive":
                self.keyboardDismissMode = .interactive
            default:
                self.keyboardDismissMode = .none
            }
            scrollView.keyboardDismissMode = self.keyboardDismissMode
        }
        
        // Handle scroll event throttling
        if let scrollEventThrottle = props["scrollEventThrottle"] as? CGFloat {
            self.scrollEventThrottle = scrollEventThrottle
        }
        
        // Handle onEndReached threshold
        if let onEndReachedThreshold = props["onEndReachedThreshold"] as? CGFloat {
            self.onEndReachedThreshold = onEndReachedThreshold
        }
        
        // Handle content offset
        if let contentOffset = props["contentOffset"] as? [String: Any],
           let x = contentOffset["x"] as? CGFloat,
           let y = contentOffset["y"] as? CGFloat,
           let animated = props["scrollToOffsetAnimated"] as? Bool {
            let offset = CGPoint(x: x, y: y)
            scrollView.setContentOffset(offset, animated: animated)
        }
        
        // Handle refresh control
        if let refreshing = props["refreshing"] as? Bool {
            setupRefreshControl(refreshing: refreshing)
        }
        
        // Handle content insets
        if let contentInsetDict = props["contentInset"] as? [String: CGFloat] {
            let top = contentInsetDict["top"] ?? 0
            let left = contentInsetDict["left"] ?? 0
            let bottom = contentInsetDict["bottom"] ?? 0
            let right = contentInsetDict["right"] ?? 0
            
            self.contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
            scrollView.contentInset = self.contentInset
        }
        
        // Handle scroll indicator insets
        if let scrollIndicatorInsetsDict = props["scrollIndicatorInsets"] as? [String: CGFloat] {
            let top = scrollIndicatorInsetsDict["top"] ?? 0
            let left = scrollIndicatorInsetsDict["left"] ?? 0
            let bottom = scrollIndicatorInsetsDict["bottom"] ?? 0
            let right = scrollIndicatorInsetsDict["right"] ?? 0
            
            self.scrollIndicatorInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
            scrollView.scrollIndicatorInsets = self.scrollIndicatorInsets
        }
        
        return needsLayoutUpdate
    }
    
    private func setupRefreshControl(refreshing: Bool) {
        // Create the refresh control if it doesn't exist
        if refreshControl == nil {
            refreshControl = UIRefreshControl()
            refreshControl?.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
            scrollView.refreshControl = refreshControl
        }
        
        // Update refreshing state
        if refreshing {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    @objc func refreshControlValueChanged() {
        // Send onRefresh event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onRefresh",
            params: ["target": viewId]
        )
    }
    
    // Override addSubview to add views to the content view
    override func addSubview(_ view: UIView) {
        if view == scrollView {
            super.addSubview(view)
        } else {
            contentView.addSubview(view)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension DCScrollView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Throttle scroll events
        let currentTime = Date().timeIntervalSince1970
        if scrollEventThrottle > 0 {
            // If scroll event throttle is set, check if enough time has passed
            let timeElapsed = currentTime - lastScrollEventTimestamp
            if timeElapsed < (1.0 / Double(scrollEventThrottle)) {
                return
            }
        } else {
            // Otherwise use default throttling
            let timeElapsed = currentTime - lastScrollEventTimestamp
            if timeElapsed < minScrollEventInterval {
                return
            }
        }
        
        lastScrollEventTimestamp = currentTime
        
        // Create scroll event data
        let contentOffset = scrollView.contentOffset
        let contentSize = scrollView.contentSize
        let layoutMeasurements = scrollView.bounds.size
        
        let event: [String: Any] = [
            "contentOffset": [
                "x": contentOffset.x,
                "y": contentOffset.y
            ],
            "contentSize": [
                "width": contentSize.width,
                "height": contentSize.height
            ],
            "layoutMeasurement": [
                "width": layoutMeasurements.width,
                "height": layoutMeasurements.height
            ],
            "target": viewId
        ]
        
        // Send scroll event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onScroll",
            params: event
        )
        
        // Check if we've reached the end
        checkIfReachedEnd(contentOffset: contentOffset, 
                         contentSize: contentSize, 
                         layoutMeasurements: layoutMeasurements)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onScrollBeginDrag",
            params: ["target": viewId]
        )
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onScrollEndDrag",
            params: ["target": viewId]
        )
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onMomentumScrollBegin",
            params: ["target": viewId]
        )
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onMomentumScrollEnd",
            params: ["target": viewId]
        )
    }
    
    private func checkIfReachedEnd(contentOffset: CGPoint, contentSize: CGSize, layoutMeasurements: CGSize) {
        // Check if we've reached the end of the content
        if horizontal {
            let distanceFromEnd = contentSize.width - contentOffset.x - layoutMeasurements.width
            if distanceFromEnd < layoutMeasurements.width * onEndReachedThreshold {
                sendEndReachedEvent()
            }
        } else {
            let distanceFromEnd = contentSize.height - contentOffset.y - layoutMeasurements.height
            if distanceFromEnd < layoutMeasurements.height * onEndReachedThreshold {
                sendEndReachedEvent()
            }
        }
    }
    
    private func sendEndReachedEvent() {
        // Use a simple debounce to avoid multiple end-reached events
        let currentOffset = scrollView.contentOffset
        if currentOffset != lastScrollOffset {
            lastScrollOffset = currentOffset
            
            // Send the onEndReached event
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onEndReached",
                params: ["target": viewId]
            )
        }
    }
}
