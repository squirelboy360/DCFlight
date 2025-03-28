//
//  DCButton.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Button component that matches React Native's Button
class DCButton: DCBaseView {
    // UI Components
    private let button = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .white)
    
    // Button properties
    private var isLoading = false
    private var titleText: String?
    private var titleColor: UIColor = .systemBlue
    private var disabledTitleColor: UIColor = .lightGray
    private var disabledBackgroundColor: UIColor?
    private var borderRadius: CGFloat = 8.0
    private var fontWeight: UIFont.Weight = .regular
    private var fontSize: CGFloat = 17.0
    private var buttonType: String = "solid" // solid, outline, clear
    
    // Change from stored property to computed property
    private var buttonBackgroundColor: UIColor = .systemBlue

    // Use a computed property to override backgroundColor
    override var backgroundColor: UIColor? {
        get {
            return buttonBackgroundColor
        }
        set {
            buttonBackgroundColor = newValue ?? .systemBlue
            button.backgroundColor = buttonBackgroundColor
            super.backgroundColor = .clear  // Keep container clear
        }
    }

    override func setupView() {
        super.setupView()
        
        // Set up button
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = borderRadius
        button.clipsToBounds = true
        button.setTitle("Button", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        button.setTitleColor(titleColor, for: .normal)
        button.setTitleColor(disabledTitleColor, for: .disabled)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        // Set up activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        
        // Add subviews
        addSubview(button)
        addSubview(activityIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Title
        if let title = props["title"] as? String {
            titleText = title
            button.setTitle(title, for: .normal)
        }
        
        // Disabled state
        if let disabled = props["disabled"] as? Bool {
            button.isEnabled = !disabled
        }
        
        // Loading state
        if let loading = props["loading"] as? Bool {
            isLoading = loading
            updateLoadingState()
        }
        
        // Color
        if let colorStr = props["color"] as? String, colorStr.hasPrefix("#") {
            titleColor = UIColor(hexString: colorStr)
            button.setTitleColor(titleColor, for: .normal)
            
            // Also set activity indicator color to match
            if colorStr != "#FFFFFF" && colorStr != "#ffffff" {
                activityIndicator.color = titleColor
            }
        }
        
        // Button type
        if let type = props["type"] as? String {
            buttonType = type
            applyButtonType()
        }
        
        // Style properties
        if let style = props["style"] as? [String: Any] {
            applyStyles(style)
        }
    }
    
    private func applyStyles(_ style: [String: Any]) {
        // Font size
        if let fontSize = style["fontSize"] as? CGFloat {
            self.fontSize = fontSize
            updateFont()
        }
        
        // Font weight
        if let fontWeightStr = style["fontWeight"] as? String {
            switch fontWeightStr {
            case "bold", "700", "800", "900":
                fontWeight = .bold
            case "100":
                fontWeight = .ultraLight
            case "200":
                fontWeight = .thin
            case "300":
                fontWeight = .light
            case "400":
                fontWeight = .regular
            case "500":
                fontWeight = .medium
            case "600":
                fontWeight = .semibold
            default:
                fontWeight = .regular
            }
            updateFont()
        }
        
        // Background color
        if let backgroundColorStr = style["backgroundColor"] as? String, backgroundColorStr.hasPrefix("#") {
            backgroundColor = UIColor(hexString: backgroundColorStr)
            applyButtonType()
        }
        
        // Border radius
        if let borderRadius = style["borderRadius"] as? CGFloat {
            self.borderRadius = borderRadius
            button.layer.cornerRadius = borderRadius
        }
        
        // Text color - can also be in style
        if let colorStr = style["color"] as? String, colorStr.hasPrefix("#") {
            titleColor = UIColor(hexString: colorStr)
            button.setTitleColor(titleColor, for: .normal)
        }
        
        // Padding
        if let padding = style["padding"] as? CGFloat {
            button.contentEdgeInsets = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        } else {
            // Set individual padding values
            var topPadding: CGFloat = 10
            var leftPadding: CGFloat = 16
            var bottomPadding: CGFloat = 10
            var rightPadding: CGFloat = 16
            
            if let paddingTop = style["paddingTop"] as? CGFloat { topPadding = paddingTop }
            if let paddingLeft = style["paddingLeft"] as? CGFloat { leftPadding = paddingLeft }
            if let paddingBottom = style["paddingBottom"] as? CGFloat { bottomPadding = paddingBottom }
            if let paddingRight = style["paddingRight"] as? CGFloat { rightPadding = paddingRight }
            
            button.contentEdgeInsets = UIEdgeInsets(
                top: topPadding,
                left: leftPadding,
                bottom: bottomPadding,
                right: rightPadding
            )
        }
    }
    
    private func updateFont() {
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
    }
    
    private func applyButtonType() {
        switch buttonType {
        case "outline":
            button.backgroundColor = .clear
            button.layer.borderWidth = 1.0
            button.layer.borderColor = (backgroundColor ?? titleColor).cgColor
            button.setTitleColor(backgroundColor ?? titleColor, for: .normal)
            
        case "clear":
            button.backgroundColor = .clear
            button.layer.borderWidth = 0.0
            button.setTitleColor(backgroundColor ?? titleColor, for: .normal)
            
        case "solid", _:
            button.backgroundColor = backgroundColor ?? .systemBlue
            button.layer.borderWidth = 0.0
            button.setTitleColor(.white, for: .normal)
        }
    }
    
    private func updateLoadingState() {
        if isLoading {
            activityIndicator.startAnimating()
            button.setTitle("", for: .normal)
        } else {
            activityIndicator.stopAnimating()
            button.setTitle(titleText, for: .normal)
        }
        button.isEnabled = !isLoading
    }
    
    @objc private func buttonPressed() {
        // Send press event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onPress",
            params: [
                "target": viewId,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ]
        )
    }
    
    override var intrinsicContentSize: CGSize {
        // Default height for iOS buttons
        let minHeight: CGFloat = 44.0
        let buttonSize = button.intrinsicContentSize
        
        // Make sure height is at least 44pts (good touch target size)
        return CGSize(
            width: buttonSize.width,
            height: max(buttonSize.height, minHeight)
        )
    }
}
