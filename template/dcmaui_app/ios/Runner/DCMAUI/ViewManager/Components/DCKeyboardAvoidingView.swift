//
//  DCKeyboardAvoidingView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// KeyboardAvoidingView component that matches React Native's KeyboardAvoidingView
class DCKeyboardAvoidingView: DCBaseView {
    // Configuration
    private var behavior: String = "padding" // padding, height, position
    private var enabled: Bool = true
    private var keyboardVerticalOffset: CGFloat = 0
    private var contentContainerStyle: [String: Any]?
    
    // Keyboard tracking
    private var keyboardHeight: CGFloat = 0
    private var currentViewHeight: CGFloat = 0  // Renamed from viewHeight to avoid conflict
    private var initialFrameHeight: CGFloat = 0
    private var isKeyboardVisible = false
    
    // Original constraints
    private var originalConstraints: [NSLayoutConstraint] = []
    private var bottomConstraint: NSLayoutConstraint?
    
    // Content container
    private let contentContainer = UIView()
    
    override func setupView() {
        super.setupView()
        
        // Set up content container
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainer)
        
        // Set default constraints
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        // Create bottom constraint - will be adjusted when keyboard shows/hides
        bottomConstraint = contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint?.isActive = true
        
        // Store initial frame height
        initialFrameHeight = frame.height
        
        // Register for keyboard notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Update configuration
        if let behavior = props["behavior"] as? String {
            self.behavior = behavior
        }
        
        if let enabled = props["enabled"] as? Bool {
            self.enabled = enabled
        }
        
        if let keyboardVerticalOffset = props["keyboardVerticalOffset"] as? CGFloat {
            self.keyboardVerticalOffset = keyboardVerticalOffset
        }
        
        if let contentContainerStyle = props["contentContainerStyle"] as? [String: Any] {
            self.contentContainerStyle = contentContainerStyle
            applyContentContainerStyle()
        }
        
        // Update keyboard adjustment if keyboard is already visible
        if isKeyboardVisible {
            adjustForKeyboard()
        }
    }
    
    private func applyContentContainerStyle() {
        guard let style = contentContainerStyle else { return }
        
        // Apply padding
        if let padding = style["padding"] as? CGFloat {
            contentContainer.layoutMargins = UIEdgeInsets(
                top: padding,
                left: padding,
                bottom: padding,
                right: padding
            )
        } else {
            // Apply individual padding values
            var topPadding: CGFloat = 0
            var leftPadding: CGFloat = 0
            var bottomPadding: CGFloat = 0
            var rightPadding: CGFloat = 0
            
            if let paddingTop = style["paddingTop"] as? CGFloat { topPadding = paddingTop }
            if let paddingLeft = style["paddingLeft"] as? CGFloat { leftPadding = paddingLeft }
            if let paddingBottom = style["paddingBottom"] as? CGFloat { bottomPadding = paddingBottom }
            if let paddingRight = style["paddingRight"] as? CGFloat { rightPadding = paddingRight }
            
            contentContainer.layoutMargins = UIEdgeInsets(
                top: topPadding,
                left: leftPadding,
                bottom: bottomPadding,
                right: rightPadding
            )
        }
        
        // Background color
        if let backgroundColorString = style["backgroundColor"] as? String, backgroundColorString.hasPrefix("#") {
            contentContainer.backgroundColor = UIColor(hexString: backgroundColorString)
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !enabled { return }
        
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
        keyboardHeight = keyboardFrame.height
        
        adjustForKeyboard()
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        isKeyboardVisible = true
        
        // Send event to match React Native behavior
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onKeyboardShow",
            params: [
                "keyboardHeight": keyboardHeight,
                "target": viewId
            ]
        )
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if !enabled { return }
        
        keyboardHeight = 0
        resetViewFromKeyboard()
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        isKeyboardVisible = false
        
        // Send event to match React Native behavior
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onKeyboardHide",
            params: [
                "target": viewId
            ]
        )
    }
    
    private func adjustForKeyboard() {
        if !enabled { return }
        
        let adjustmentHeight = keyboardHeight - keyboardVerticalOffset
        
        switch behavior {
        case "padding":
            // Adjust the bottom constraint to make space for keyboard
            bottomConstraint?.constant = -adjustmentHeight
            
        case "height":
            // Resize the view to make space for keyboard
            currentViewHeight = frame.height  // Fixed: removed ".height"
            frame.size.height = max(initialFrameHeight - adjustmentHeight, 0)
            
        case "position":
            // Move the entire view up
            transform = CGAffineTransform(translationX: 0, y: -adjustmentHeight)
            
        default:
            // Default to padding behavior
            bottomConstraint?.constant = -adjustmentHeight
        }
        
        // Animate changes if part of a view hierarchy
        if let superview = superview {
            UIView.animate(withDuration: 0.25) {
                superview.layoutIfNeeded()
            }
        }
    }
    
    private func resetViewFromKeyboard() {
        switch behavior {
        case "padding":
            bottomConstraint?.constant = 0
            
        case "height":
            frame.size.height = currentViewHeight > 0 ? currentViewHeight : initialFrameHeight  // Fixed: removed "ialFrameHeight"
            
        case "position":
            transform = .identity
            
        default:
            bottomConstraint?.constant = 0
        }
        
        // Animate changes if part of a view hierarchy
        if let superview = superview {
            UIView.animate(withDuration: 0.25) {
                superview.layoutIfNeeded()
            }
        }
    }
    
    // Override to add children to the content container instead
    override func addSubview(_ view: UIView) {
        if view == contentContainer {
            super.addSubview(view)
        } else {
            contentContainer.addSubview(view)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
