//
//  DCImageBackground.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// ImageBackground component that matches React Native's ImageBackground
class DCImageBackground: DCImage {
    private let contentContainer = UIView()
    
    override func setupView() {
        super.setupView()
        
        // Set up content container to hold children
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.backgroundColor = .clear
        
        // Add container above the image view
        addSubview(contentContainer)
        
        // Constrain content container to fill the view
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        // Update image props via super class implementation
        super.updateProps(props: props)
        
        // Apply any specific ImageBackground properties
        if let style = props["style"] as? [String: Any],
           let overlayColor = style["overlayColor"] as? String, 
           overlayColor.hasPrefix("#") {
            contentContainer.backgroundColor = UIColor(hexString: overlayColor)
        }
    }
    
    // Override addSubview to add children to the content container rather than directly to the view
    override func addSubview(_ view: UIView) {
        if view == contentContainer || view == imageView {
            super.addSubview(view)
        } else {
            contentContainer.addSubview(view)
        }
    }
}
