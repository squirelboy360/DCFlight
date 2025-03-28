//
//  DCActivityIndicator.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// ActivityIndicator component that matches React Native's ActivityIndicator
class DCActivityIndicator: DCBaseView {
    // The actual activity indicator
    private let activityIndicator = UIActivityIndicatorView()
    
    // Properties
    private var animating: Bool = true
    private var hidesWhenStopped: Bool = true
    private var indicatorColor: UIColor = .gray
    private var indicatorSize: String = "small"
    
    override func setupView() {
        super.setupView()
        
        // Configure activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = hidesWhenStopped
        
        // Set default style - "small" or "large"
        if #available(iOS 13.0, *) {
            activityIndicator.style = .medium
        } else {
            activityIndicator.style = .gray
        }
        
        // Add to view
        addSubview(activityIndicator)
        
        // Center the indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Start animating by default
        if animating {
            activityIndicator.startAnimating()
        }
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle animating state
        if let animating = props["animating"] as? Bool {
            self.animating = animating
            if animating {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
        
        // Handle indicator color
        if let colorString = props["color"] as? String, colorString.hasPrefix("#") {
            indicatorColor = UIColor(hexString: colorString)
            activityIndicator.color = indicatorColor
        }
        
        // Handle size
        if let size = props["size"] as? String {
            indicatorSize = size
            
            // Apply the appropriate style based on size
            if #available(iOS 13.0, *) {
                if size == "large" {
                    activityIndicator.style = .large
                } else {
                    activityIndicator.style = .medium
                }
            } else {
                // Fallback for older iOS
                if size == "large" {
                    activityIndicator.style = .whiteLarge
                    activityIndicator.color = indicatorColor  // Have to reapply color for whiteLarge
                } else {
                    activityIndicator.style = .gray
                    activityIndicator.color = indicatorColor  // Have to reapply color for gray
                }
            }
        }
        
        // Handle hidesWhenStopped
        if let hidesWhenStopped = props["hidesWhenStopped"] as? Bool {
            self.hidesWhenStopped = hidesWhenStopped
            activityIndicator.hidesWhenStopped = hidesWhenStopped
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return activityIndicator.intrinsicContentSize
    }
}
