//
//  DCDrawer.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Drawer component that provides side menu functionality (similar to DrawerLayoutAndroid)
class DCDrawer: DCBaseView {
    // Drawer properties
    private var drawerPosition: String = "left" // left or right
    private var drawerWidth: CGFloat = 280.0
    private var drawerBackgroundColor: UIColor = .white
    private var contentBackgroundColor: UIColor = .white
    private var statusBarBackgroundColor: UIColor?
    private var openDrawerThreshold: CGFloat = 0.2
    private var closeDrawerThreshold: CGFloat = 0.5
    private var drawerLockMode: String = "unlocked" // unlocked, locked-closed, locked-open
    private var keyboardDismissMode: String = "none" // none, on-drag
    private var enableGestureInteraction: Bool = true
    private var hideStatusBar: Bool = false
    
    // Internal state
    private var drawerIsOpen: Bool = false
    private var originalDrawerPosition: CGPoint = .zero
    
    // Drawer Views
    private let contentView = UIView()
    private let drawerView = UIView()
    private let dimmedView = UIView()
    
    // Gesture recognizers
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    
    // For tracking drawer position during pan
    private var initialDrawerCenter: CGPoint = .zero
    private var initialTouchLocation: CGPoint = .zero
    
    override func setupView() {
        super.setupView()
        
        // Set up content view (main view)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = contentBackgroundColor
        addSubview(contentView)
        
        // Set up dimmed view (overlay when drawer is open)
        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmedView.alpha = 0
        addSubview(dimmedView)
        
        // Set up drawer view
        drawerView.translatesAutoresizingMaskIntoConstraints = false
        drawerView.backgroundColor = drawerBackgroundColor
        addSubview(drawerView)
        
        // Set up constraints for content view (fills the entire parent)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set up constraints for dimmed view (overlay)
        NSLayoutConstraint.activate([
            dimmedView.topAnchor.constraint(equalTo: topAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Set up initial drawer position (off-screen)
        updateDrawerPosition(animated: false)
        
        // Set up gesture recognizers
        setupGestureRecognizers()
        
        // Make drawer view and content view clip to bounds
        drawerView.clipsToBounds = true
        contentView.clipsToBounds = true
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        var needsLayout = false
        
        // Handle drawer position
        if let position = props["drawerPosition"] as? String {
            if drawerPosition != position {
                drawerPosition = position
                needsLayout = true
            }
        }
        
        // Handle drawer width
        if let width = props["drawerWidth"] as? CGFloat {
            if drawerWidth != width {
                drawerWidth = width
                needsLayout = true
            }
        }
        
        // Handle colors
        if let bgColorStr = props["drawerBackgroundColor"] as? String, bgColorStr.hasPrefix("#") {
            drawerBackgroundColor = UIColor(hexString: bgColorStr)
            drawerView.backgroundColor = drawerBackgroundColor
        }
        
        if let contentBgColorStr = props["contentBackgroundColor"] as? String, contentBgColorStr.hasPrefix("#") {
            contentBackgroundColor = UIColor(hexString: contentBgColorStr)
            contentView.backgroundColor = contentBackgroundColor
        }
        
        if let statusBarBgColorStr = props["statusBarBackgroundColor"] as? String, statusBarBgColorStr.hasPrefix("#") {
            statusBarBackgroundColor = UIColor(hexString: statusBarBgColorStr)
            updateStatusBarBackground()
        }
        
        // Handle gesture and interaction props
        if let threshold = props["openDrawerThreshold"] as? CGFloat {
            openDrawerThreshold = threshold
        }
        
        if let threshold = props["closeDrawerThreshold"] as? CGFloat {
            closeDrawerThreshold = threshold
        }
        
        if let lockMode = props["drawerLockMode"] as? String {
            drawerLockMode = lockMode
            updateGestureRecognizers()
        }
        
        if let keyboardMode = props["keyboardDismissMode"] as? String {
            keyboardDismissMode = keyboardMode
        }
        
        if let enableGesture = props["enableGestureInteraction"] as? Bool {
            enableGestureInteraction = enableGesture
            updateGestureRecognizers()
        }
        
        if let hideStatusBar = props["hideStatusBar"] as? Bool {
            self.hideStatusBar = hideStatusBar
            
            if drawerIsOpen {
                updateStatusBarVisibility()
            }
        }
        
        // Handle drawer open state
        if let open = props["open"] as? Bool {
            if open != drawerIsOpen {
                drawerIsOpen = open
                animateDrawerPosition()
            }
        }
        
        // Update layout if needed
        if needsLayout {
            updateDrawerPosition(animated: false)
        }
    }
    
    private func setupGestureRecognizers() {
        // Pan gesture for opening/closing the drawer
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        if let panGesture = panGestureRecognizer {
            addGestureRecognizer(panGesture)
        }
        
        // Tap gesture for closing the drawer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        if let tapGesture = tapGestureRecognizer {
            dimmedView.addGestureRecognizer(tapGesture)
        }
        
        // Update gesture recognizers based on current settings
        updateGestureRecognizers()
    }
    
    private func updateGestureRecognizers() {
        let shouldEnableGestures = enableGestureInteraction && drawerLockMode != "locked-closed" && drawerLockMode != "locked-open"
        
        panGestureRecognizer?.isEnabled = shouldEnableGestures
        tapGestureRecognizer?.isEnabled = shouldEnableGestures
    }
    
    private func updateDrawerPosition(animated: Bool = true) {
        // Calculate drawer frame based on position and width
        let parentWidth = bounds.width
        var drawerFrame = CGRect(x: 0, y: 0, width: drawerWidth, height: bounds.height)
        
        if drawerPosition == "right" {
            drawerFrame.origin.x = parentWidth - drawerWidth
        }
        
        // Position the drawer view
        if !animated {
            // Set frame directly for non-animated updates
            drawerView.frame = drawerFrame
            
            // Position off-screen when closed
            if !drawerIsOpen {
                if drawerPosition == "left" {
                    drawerView.transform = CGAffineTransform(translationX: -drawerWidth, y: 0)
                } else {
                    drawerView.transform = CGAffineTransform(translationX: drawerWidth, y: 0)
                }
            } else {
                drawerView.transform = .identity
                dimmedView.alpha = 1.0
            }
        }
        
        // Save original position for use with gestures
        originalDrawerPosition = drawerView.frame.origin
    }
    
    private func animateDrawerPosition() {
        // Calculate the translation needed
        let translationX: CGFloat
        if drawerIsOpen {
            translationX = 0 // No translation when open (drawer is fully visible)
        } else {
            // Translate off-screen when closed
            translationX = drawerPosition == "left" ? -drawerWidth : drawerWidth
        }
        
        // Animate the drawer position
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.drawerView.transform = CGAffineTransform(translationX: translationX, y: 0)
            self.dimmedView.alpha = self.drawerIsOpen ? 1.0 : 0.0
        }, completion: { _ in
            // Update status bar visibility after animation
            if self.drawerIsOpen {
                self.updateStatusBarVisibility()
            }
            
            // Send event when drawer finishes opening/closing
            DCViewCoordinator.shared?.sendEvent(
                viewId: self.viewId,
                eventName: self.drawerIsOpen ? "onDrawerOpen" : "onDrawerClose",
                params: ["target": self.viewId]
            )
        })
        
        // Hide keyboard if needed
        if keyboardDismissMode == "on-drag" {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
        // Send drawer slide event for current state
        sendDrawerSlideEvent(offset: self.drawerIsOpen ? 1.0 : 0.0)
    }
    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        // Check if gestures are allowed and drawer is not locked
        if drawerLockMode == "locked-closed" || drawerLockMode == "locked-open" || !enableGestureInteraction {
            return
        }
        
        let translation = gestureRecognizer.translation(in: self)
        let velocity = gestureRecognizer.velocity(in: self)
        
        switch gestureRecognizer.state {
        case .began:
            // Store initial positions
            initialTouchLocation = gestureRecognizer.location(in: self)
            initialDrawerCenter = drawerView.center
            
            // Automatically dismiss keyboard on drag
            if keyboardDismissMode == "on-drag" {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            
        case .changed:
            // Calculate how much the drawer should move
            let dx = drawerPosition == "left" ? translation.x : -translation.x
            let maxDx = drawerIsOpen ? drawerWidth : 0
            
            // Constrain movement
            var newDx = drawerIsOpen ? max(-drawerWidth, min(0, dx)) : max(0, min(drawerWidth, dx))
            
            // Apply resistance when trying to move past limits
            if (drawerIsOpen && dx > 0) || (!drawerIsOpen && dx < 0) {
                newDx *= 0.5 // Apply resistance
            }
            
            // Calculate new transform
            let translationX = drawerPosition == "left" ? newDx - (drawerIsOpen ? 0 : drawerWidth) : -newDx + (drawerIsOpen ? 0 : drawerWidth)
            drawerView.transform = CGAffineTransform(translationX: translationX, y: 0)
            
            // Calculate slide percentage for dimming and events
            let openPercentage = drawerPosition == "left" ? 
                1.0 - (-translationX / drawerWidth) : 
                1.0 - (translationX / drawerWidth)
            
            // Update dimmed view alpha
            dimmedView.alpha = openPercentage
            
            // Send drawer slide event
            sendDrawerSlideEvent(offset: openPercentage)
            
        case .ended, .cancelled:
            // Calculate velocity direction
            let velocityDirection = drawerPosition == "left" ? velocity.x : -velocity.x
            
            // Determine whether to open or close based on velocity and position
            let threshold = drawerIsOpen ? closeDrawerThreshold : openDrawerThreshold
            let currentOffset = drawerPosition == "left" ? 
                -drawerView.transform.tx / drawerWidth : 
                drawerView.transform.tx / drawerWidth
            
            let shouldOpen: Bool
            
            // If velocity is significant, use it to determine direction
            if abs(velocityDirection) > 500 {
                shouldOpen = velocityDirection > 0
            } else {
                // Otherwise use position threshold
                shouldOpen = drawerIsOpen ? currentOffset < threshold : currentOffset > (1.0 - threshold)
            }
            
            // Update drawer state
            drawerIsOpen = shouldOpen
            
            // Animate to final position
            animateDrawerPosition()
            
        default:
            break
        }
    }
    
    @objc private func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        // Close drawer when tapping the dimmed background
        if drawerIsOpen && enableGestureInteraction && drawerLockMode != "locked-open" {
            drawerIsOpen = false
            animateDrawerPosition()
        }
    }
    
    private func sendDrawerSlideEvent(offset: CGFloat) {
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onDrawerSlide",
            params: [
                "offset": offset,
                "target": viewId
            ]
        )
    }
    
    private func updateStatusBarVisibility() {
        if hideStatusBar {
            // Hide status bar when drawer is open
            UIApplication.shared.isStatusBarHidden = drawerIsOpen
        }
    }
    
    private func updateStatusBarBackground() {
        if let statusBarBgColor = statusBarBackgroundColor {
            // Create or update status bar background view
            let statusBarHeight = UIApplication.shared.statusBarFrame.height
            let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: statusBarHeight))
            statusBarView.backgroundColor = statusBarBgColor
            statusBarView.autoresizingMask = [.flexibleWidth]
            statusBarView.tag = 38483 // Unique tag for finding later
            
            // Remove existing status bar view if present
            drawerView.viewWithTag(38483)?.removeFromSuperview()
            
            // Add to drawer view at the top
            drawerView.addSubview(statusBarView)
        }
    }
    
    // Override to add children to the appropriate parent view
    override func addSubview(_ view: UIView) {
        // Specific views we manage ourselves
        if view == contentView || view == drawerView || view == dimmedView {
            super.addSubview(view)
        } else {
            // Add all other subviews to the content view or drawer view
            // based on tag or other property
            if let dcView = view as? DCBaseView, dcView.viewId.hasSuffix("_drawer") {
                drawerView.addSubview(view)
            } else {
                contentView.addSubview(view)
            }
        }
    }
    
    // Public methods that can be called from Dart
    
    /// Open the drawer
    func openDrawer() {
        if !drawerIsOpen && drawerLockMode != "locked-closed" {
            drawerIsOpen = true
            animateDrawerPosition()
        }
    }
    
    /// Close the drawer
    func closeDrawer() {
        if drawerIsOpen && drawerLockMode != "locked-open" {
            drawerIsOpen = false
            animateDrawerPosition()
        }
    }
}
