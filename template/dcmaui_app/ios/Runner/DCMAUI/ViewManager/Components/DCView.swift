//
//  DCView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// View component that matches React Native's View
class DCView: DCBaseView {
    // MARK: - Properties
    private var borderWidth: CGFloat = 0
    private var borderColor: UIColor = .clear
    private var cornerRadius: CGFloat = 0
    private var shadowColor: UIColor = .black
    private var shadowOpacity: Float = 0
    private var shadowRadius: CGFloat = 0
    private var shadowOffset: CGSize = .zero
    
    // MARK: - Setup
    override func setupView() {
        super.setupView()
        
        // Basic setup for view
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    // MARK: - Props Handling
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle style properties if present
        if let style = props["style"] as? [String: Any] {
            applyStyles(style)
        }
    }
    
    private func applyStyles(_ style: [String: Any]) {
        // Background color
        if let colorString = style["backgroundColor"] as? String, colorString.hasPrefix("#") {
            backgroundColor = UIColor(hexString: colorString)
        }
        
        // Border properties
        if let borderWidth = style["borderWidth"] as? CGFloat {
            self.borderWidth = borderWidth
            layer.borderWidth = borderWidth
        }
        
        if let borderColorString = style["borderColor"] as? String, borderColorString.hasPrefix("#") {
            borderColor = UIColor(hexString: borderColorString)
            layer.borderColor = borderColor.cgColor
        }
        
        // Process border radius
        if let cornerRadius = style["borderRadius"] as? CGFloat {
            self.cornerRadius = cornerRadius
            layer.cornerRadius = cornerRadius
        } else {
            // Handle individual corner radii
            var topLeft = self.cornerRadius
            var topRight = self.cornerRadius
            var bottomLeft = self.cornerRadius
            var bottomRight = self.cornerRadius
            
            if let tl = style["borderTopLeftRadius"] as? CGFloat { topLeft = tl }
            if let tr = style["borderTopRightRadius"] as? CGFloat { topRight = tr }
            if let bl = style["borderBottomLeftRadius"] as? CGFloat { bottomLeft = bl }
            if let br = style["borderBottomRightRadius"] as? CGFloat { bottomRight = br }
            
            // Apply corner radii if they all match
            if topLeft == topRight && topLeft == bottomLeft && topLeft == bottomRight {
                layer.cornerRadius = topLeft
            } else {
                // Apply masked corners for iOS 11+
                if #available(iOS 11.0, *) {
                    var maskedCorners: CACornerMask = []
                    if topLeft > 0 { maskedCorners.insert(.layerMinXMinYCorner) }
                    if topRight > 0 { maskedCorners.insert(.layerMaxXMinYCorner) }
                    if bottomLeft > 0 { maskedCorners.insert(.layerMinXMaxYCorner) }
                    if bottomRight > 0 { maskedCorners.insert(.layerMaxXMaxYCorner) }
                    
                    layer.cornerRadius = max(topLeft, topRight, bottomLeft, bottomRight)
                    layer.maskedCorners = maskedCorners
                } else {
                    // For older iOS, we can't do individual corners easily
                    layer.cornerRadius = (topLeft + topRight + bottomLeft + bottomRight) / 4
                }
            }
        }
        
        // Shadow properties - only visible if clipsToBounds is false
        if let shadowOpacity = style["shadowOpacity"] as? Float {
            self.shadowOpacity = shadowOpacity
            layer.shadowOpacity = shadowOpacity
            clipsToBounds = shadowOpacity <= 0
        }
        
        if shadowOpacity > 0 {
            // We have a shadow, so configure shadow properties
            if let shadowColorString = style["shadowColor"] as? String, shadowColorString.hasPrefix("#") {
                shadowColor = UIColor(hexString: shadowColorString)
                layer.shadowColor = shadowColor.cgColor
            }
            
            if let shadowRadius = style["shadowRadius"] as? CGFloat {
                self.shadowRadius = shadowRadius
                layer.shadowRadius = shadowRadius
            }
            
            if let shadowOffset = style["shadowOffset"] as? [String: Any] {
                let width = shadowOffset["width"] as? CGFloat ?? 0
                let height = shadowOffset["height"] as? CGFloat ?? 0
                self.shadowOffset = CGSize(width: width, height: height)
                layer.shadowOffset = self.shadowOffset
            }
            
            // Optimize shadow rendering
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        }
        
        // Opacity
        if let opacity = style["opacity"] as? CGFloat {
            alpha = opacity
        }
        
        // Overflow
        if let overflow = style["overflow"] as? String {
            clipsToBounds = (overflow == "hidden")
        }
        
        // Apply transforms if specified
        if let transform = style["transform"] as? [[String: Any]] {
            applyTransforms(transform)
        }
    }
    
    private func applyTransforms(_ transforms: [[String: Any]]) {
        var transform = CGAffineTransform.identity
        
        for transformItem in transforms {
            if let translateX = transformItem["translateX"] as? CGFloat,
               let translateY = transformItem["translateY"] as? CGFloat {
                transform = transform.translatedBy(x: translateX, y: translateY)
            } else if let scale = transformItem["scale"] as? CGFloat {
                transform = transform.scaledBy(x: scale, y: scale)
            } else if let scaleX = transformItem["scaleX"] as? CGFloat {
                transform = transform.scaledBy(x: scaleX, y: 1.0)
            } else if let scaleY = transformItem["scaleY"] as? CGFloat {
                transform = transform.scaledBy(x: 1.0, y: scaleY)
            } else if let rotate = transformItem["rotate"] as? CGFloat {
                transform = transform.rotated(by: rotate * .pi / 180.0)
            }
        }
        
        self.transform = transform
    }
    
    // Optimize shadow paths when the view bounds change
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowOpacity > 0 {
            layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        }
    }
}
