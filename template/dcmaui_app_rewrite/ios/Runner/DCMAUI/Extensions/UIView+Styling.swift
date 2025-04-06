import UIKit
import yoga

extension UIView {
    // MARK: - Style Application
    
    /// Apply common visual styles to a UIView based on provided properties dictionary
    func applyStyles(props: [String: Any]) {
        // Background & appearance styling
        if let backgroundColor = props["backgroundColor"] as? String {
            self.backgroundColor = ColorUtilities.color(fromHexString: backgroundColor)
        }
        
        if let opacity = props["opacity"] as? CGFloat {
            self.alpha = opacity
        }
        
        // Apply visual styling by category
        applyBorderStyles(props: props)
        applyShadowStyles(props: props)
        applyTransformStyles(props: props)
        applyOverflowStyles(props: props)
        
        // Accessibility is not visual styling but affects all components
        applyAccessibilityStyles(props: props)
        
        // Note: We're NOT applying Yoga percentage styles directly on iOS
        // These will be handled through the Dart FFI bindings
    }
    
    // MARK: - Border Styles
    
    /// Apply border styling including border radius, width, and color
    private func applyBorderStyles(props: [String: Any]) {
        let parentWidth = superview?.bounds.width ?? UIScreen.main.bounds.width
        let parentHeight = superview?.bounds.height ?? UIScreen.main.bounds.height
        
        // Border radius
        if let borderRadius = props["borderRadius"] {
            if let actualRadius = parsePercentageValue(borderRadius, relativeTo: parentWidth) {
                layer.cornerRadius = actualRadius
                clipsToBounds = true
            } else if let directRadius = borderRadius as? CGFloat {
                layer.cornerRadius = directRadius
                clipsToBounds = true
            }
        }
        
        // Corner radii - check if all individual corners are specified
        let topLeftRadius = getActualValue(props["borderTopLeftRadius"], relativeTo: min(parentWidth, parentHeight) / 2)
        let topRightRadius = getActualValue(props["borderTopRightRadius"], relativeTo: min(parentWidth, parentHeight) / 2)
        let bottomLeftRadius = getActualValue(props["borderBottomLeftRadius"], relativeTo: min(parentWidth, parentHeight) / 2)
        let bottomRightRadius = getActualValue(props["borderBottomRightRadius"], relativeTo: min(parentWidth, parentHeight) / 2)
        
        applyCornerRadii(topLeft: topLeftRadius, topRight: topRightRadius,
                         bottomLeft: bottomLeftRadius, bottomRight: bottomRightRadius)
        
        // Border color
        if let borderColor = props["borderColor"] as? String {
            layer.borderColor = ColorUtilities.color(fromHexString: borderColor)?.cgColor
        }
        
        // Border width
        if let borderWidth = props["borderWidth"] {
            if let percentValue = parsePercentageValue(borderWidth, relativeTo: min(parentWidth, parentHeight) / 10) {
                layer.borderWidth = percentValue
            } else if let directWidth = borderWidth as? CGFloat {
                layer.borderWidth = directWidth
            }
        }
    }
    
    /// Apply corner radii to all four corners or individual corners
    private func applyCornerRadii(topLeft: CGFloat?, topRight: CGFloat?, bottomLeft: CGFloat?, bottomRight: CGFloat?) {
        if let topLeft = topLeft, let topRight = topRight, let bottomLeft = bottomLeft, let bottomRight = bottomRight {
            // All corners specified, create a custom mask
            let maskLayer = CAShapeLayer()
            
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: 0, height: 0)
            )
            
            // Create a rounded rect for each corner with the specific radius
            let topLeftRect = CGRect(x: 0, y: 0, width: topLeft * 2, height: topLeft * 2)
            let topRightRect = CGRect(x: bounds.width - topRight * 2, y: 0, 
                                    width: topRight * 2, height: topRight * 2)
            let bottomLeftRect = CGRect(x: 0, y: bounds.height - bottomLeft * 2, 
                                      width: bottomLeft * 2, height: bottomLeft * 2)
            let bottomRightRect = CGRect(x: bounds.width - bottomRight * 2, 
                                       y: bounds.height - bottomRight * 2,
                                       width: bottomRight * 2, height: bottomRight * 2)
            
            // Add corners to the path
            path.append(UIBezierPath(roundedRect: topLeftRect, cornerRadius: topLeft))
            path.append(UIBezierPath(roundedRect: topRightRect, cornerRadius: topRight))
            path.append(UIBezierPath(roundedRect: bottomLeftRect, cornerRadius: bottomLeft))
            path.append(UIBezierPath(roundedRect: bottomRightRect, cornerRadius: bottomRight))
            
            maskLayer.path = path.cgPath
            layer.mask = maskLayer
            clipsToBounds = true
        } else {
            // Apply individual corners if specified
            if let radius = topLeft {
                layer.maskedCorners.insert(.layerMinXMinYCorner)
                layer.cornerRadius = radius
                clipsToBounds = true
            }
            
            if let radius = topRight {
                layer.maskedCorners.insert(.layerMaxXMinYCorner)
                layer.cornerRadius = radius
                clipsToBounds = true
            }
            
            if let radius = bottomLeft {
                layer.maskedCorners.insert(.layerMinXMaxYCorner)
                layer.cornerRadius = radius
                clipsToBounds = true
            }
            
            if let radius = bottomRight {
                layer.maskedCorners.insert(.layerMaxXMaxYCorner)
                layer.cornerRadius = radius
                clipsToBounds = true
            }
        }
    }
    
    // MARK: - Shadow Styles
    
    /// Apply shadow styling including shadow radius, color, offset, and opacity
    private func applyShadowStyles(props: [String: Any]) {
        let parentWidth = superview?.bounds.width ?? UIScreen.main.bounds.width
        let parentHeight = superview?.bounds.height ?? UIScreen.main.bounds.height
        
        // Determine if we should apply shadows
        let hasShadow = props["shadowRadius"] != nil || 
                       props["shadowColor"] != nil || 
                       props["shadowOpacity"] != nil || 
                       props["shadowOffsetX"] != nil || 
                       props["shadowOffsetY"] != nil
        
        if hasShadow {
            // Default shadow values if not specified
            let shadowRadius = getActualValue(props["shadowRadius"], relativeTo: min(parentWidth, parentHeight) / 10) ?? 3.0
            let shadowOpacity = props["shadowOpacity"] as? Float ?? 0.3
            let shadowOffsetX = getActualValue(props["shadowOffsetX"], relativeTo: parentWidth / 20) ?? 0
            let shadowOffsetY = getActualValue(props["shadowOffsetY"], relativeTo: parentHeight / 20) ?? 2
            
            // Set shadow properties
            layer.shadowRadius = shadowRadius
            layer.shadowOpacity = shadowOpacity
            layer.shadowOffset = CGSize(width: shadowOffsetX, height: shadowOffsetY)
            
            if let shadowColor = props["shadowColor"] as? String,
               let color = ColorUtilities.color(fromHexString: shadowColor) {
                layer.shadowColor = color.cgColor
            } else {
                // Default shadow color is black
                layer.shadowColor = UIColor.black.cgColor
            }
            
            // Create a shadow path for better performance
            layer.shadowPath = UIBezierPath(roundedRect: bounds, 
                                           cornerRadius: layer.cornerRadius).cgPath
        }
        // Android-specific elevation mapping
        else if let elevation = props["elevation"] {
            let elevationValue: CGFloat
            
            if let percentValue = parsePercentageValue(elevation, relativeTo: min(parentWidth, parentHeight) / 10) {
                elevationValue = percentValue
            } else if let directValue = elevation as? CGFloat {
                elevationValue = directValue
            } else if let intValue = elevation as? Int {
                elevationValue = CGFloat(intValue)
            } else {
                elevationValue = 0
            }
            
            if elevationValue > 0 {
                // Convert elevation to iOS shadow values
                let shadowRadius = elevationValue * 0.5
                let shadowOpacity = Float(0.2 + Float(elevationValue) * 0.03)
                let shadowOffsetY = elevationValue * 0.3
                
                layer.shadowRadius = shadowRadius
                layer.shadowOpacity = shadowOpacity
                layer.shadowOffset = CGSize(width: 0, height: shadowOffsetY)
                layer.shadowColor = UIColor.black.cgColor
                
                // Create a shadow path for better performance
                layer.shadowPath = UIBezierPath(roundedRect: bounds, 
                                               cornerRadius: layer.cornerRadius).cgPath
            }
        }
    }
    
    // MARK: - Transform Styles
    
    /// Apply transform styling including translate, scale, and rotate
    private func applyTransformStyles(props: [String: Any]) {
        if let transform = props["transform"] as? [String: Any] {
            let parentWidth = superview?.bounds.width ?? UIScreen.main.bounds.width
            let parentHeight = superview?.bounds.height ?? UIScreen.main.bounds.height
            var transform3D = CATransform3DIdentity
            
            // Apply translate with percentage support
            if let translateX = transform["translateX"], let translateY = transform["translateY"] {
                let txValue = getActualValue(translateX, relativeTo: parentWidth) ?? 0
                let tyValue = getActualValue(translateY, relativeTo: parentHeight) ?? 0
                
                transform3D = CATransform3DTranslate(transform3D, txValue, tyValue, 0)
            }
            
            // Apply scale with percentage support
            if let scale = transform["scale"] {
                var scaleValue: CGFloat = 1.0
                
                if let percentString = scale as? String, percentString.hasSuffix("%") {
                    if let percentValue = Float(percentString.dropLast()) {
                        scaleValue = CGFloat(percentValue / 100.0)
                    }
                } else if let directValue = scale as? CGFloat {
                    scaleValue = directValue
                }
                
                transform3D = CATransform3DScale(transform3D, scaleValue, scaleValue, 1.0)
            } else {
                // Apply separate X and Y scales
                if let scaleX = transform["scaleX"] {
                    let sxValue = getScaleValue(from: scaleX)
                    transform3D = CATransform3DScale(transform3D, sxValue, 1.0, 1.0)
                }
                
                if let scaleY = transform["scaleY"] {
                    let syValue = getScaleValue(from: scaleY)
                    transform3D = CATransform3DScale(transform3D, 1.0, syValue, 1.0)
                }
            }
            
            // Apply rotation - percentage of 360 degrees
            if let rotateZ = transform["rotate"] {
                var angleValue: CGFloat = 0.0
                
                if let percentString = rotateZ as? String, percentString.hasSuffix("%") {
                    if let percentValue = Float(percentString.dropLast()) {
                        // Treat percentage as percentage of full rotation (360 degrees)
                        angleValue = CGFloat(percentValue / 100.0) * 360.0
                    }
                } else if let directValue = rotateZ as? CGFloat {
                    angleValue = directValue
                }
                
                // Convert degrees to radians
                let angle = angleValue * .pi / 180.0
                transform3D = CATransform3DRotate(transform3D, angle, 0, 0, 1)
            }
            
            layer.transform = transform3D
        }
    }
    
    /// Get scale value from either percentage or direct value
    private func getScaleValue(from value: Any) -> CGFloat {
        var scaleValue: CGFloat = 1.0
        
        if let percentString = value as? String, percentString.hasSuffix("%") {
            if let percentValue = Float(percentString.dropLast()) {
                scaleValue = CGFloat(percentValue / 100.0)
            }
        } else if let directValue = value as? CGFloat {
            scaleValue = directValue
        }
        
        return scaleValue
    }
    
    // MARK: - Accessibility Styles
    
    /// Apply accessibility properties
    private func applyAccessibilityStyles(props: [String: Any]) {
        // Additional visibility properties
        if let pointerEvents = props["pointerEvents"] as? Bool {
            isUserInteractionEnabled = !pointerEvents  // false means allow events
        }
        
        // Accessibility properties
        if let accessible = props["accessible"] as? Bool {
            isAccessibilityElement = accessible
        }
        
        if let accessibilityLabel = props["accessibilityLabel"] as? String {
            self.accessibilityLabel = accessibilityLabel
        }
        
        if let testID = props["testID"] as? String {
            accessibilityIdentifier = testID
        }
    }
    
    // MARK: - Overflow Styles
    
    /// Apply overflow properties
    private func applyOverflowStyles(props: [String: Any]) {
        if let overflow = props["overflow"] as? String {
            switch overflow {
            case "visible":
                clipsToBounds = false
            case "hidden", "scroll":
                clipsToBounds = true
            default:
                clipsToBounds = false
            }
        }
    }
    
    // MARK: - Yoga Percentage Properties
    
    /// Apply percentage-based Yoga properties
    /// This is now handled through Dart FFI for better performance
    private func applyYogaPercentageStyles(props: [String: Any]) {
        // We intentionally do nothing here
        // All Yoga layout properties are now handled through Dart FFI bindings
    }
    
    // MARK: - Percentage Value Helpers
    
    /// Parse percentage value from string and calculate actual value based on reference size
    func parsePercentageValue(_ value: Any, relativeTo referenceSize: CGFloat) -> CGFloat? {
        if let percentString = value as? String, percentString.hasSuffix("%") {
            if let percentValue = Float(percentString.dropLast()) {
                return CGFloat(percentValue / 100.0) * referenceSize
            }
        }
        return nil
    }
    
    /// Get actual value from either percentage or direct value
    func getActualValue(_ value: Any?, relativeTo referenceSize: CGFloat) -> CGFloat? {
        guard let value = value else { return nil }
        
        if let percentValue = parsePercentageValue(value, relativeTo: referenceSize) {
            return percentValue
        } else if let directValue = value as? CGFloat {
            return directValue
        } else if let intValue = value as? Int {
            return CGFloat(intValue)
        }
        
        return nil
    }
}
