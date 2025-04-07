import UIKit

/// Manages styling for DCMAUI components
class DCMauiStyleManager {
    // Singleton instance
    static let shared = DCMauiStyleManager()
    
    // Private initializer for singleton
    private init() {}
    
    /// Apply style properties to a view
    func applyStyles(to view: UIView, props: [String: Any]) {
        // Apply standard UI styles
        view.applyStyles(props: props)
    }
    
    /// Extract only style-related properties from props
    func extractStyleProps(from props: [String: Any]) -> [String: Any] {
        // Style property names list
        let styleProps = [
            "borderRadius",
            "borderTopLeftRadius",
            "borderTopRightRadius",
            "borderBottomLeftRadius",
            "borderBottomRightRadius",
            "borderColor",
            "borderWidth",
            "backgroundColor",
            "opacity",
            "shadowColor",
            "shadowOpacity",
            "shadowRadius",
            "shadowOffsetX",
            "shadowOffsetY",
            "elevation",
            "transform",
            "hitSlop",
            "accessible",
            "accessibilityLabel",
            "testID",
            "pointerEvents",
        ]
        
        return props.filter { styleProps.contains($0.key) }
    }
}

// UIView extension for style application
extension UIView {
    /// Apply style properties to this view
    func applyStyles(props: [String: Any]) {
        // Border styles
        if let borderRadius = props["borderRadius"] as? CGFloat {
            layer.cornerRadius = borderRadius
            clipsToBounds = true
        }
        
        // Per-corner radius
        let corners: [(String, CACornerMask)] = [
            ("borderTopLeftRadius", .layerMinXMinYCorner),
            ("borderTopRightRadius", .layerMaxXMinYCorner),
            ("borderBottomLeftRadius", .layerMinXMaxYCorner),
            ("borderBottomRightRadius", .layerMaxXMaxYCorner)
        ]
        
        var cornerMask: CACornerMask = []
        var hasCustomCorners = false
        
        for (propName, cornerValue) in corners {
            if let radius = props[propName] as? CGFloat, radius > 0 {
                cornerMask.insert(cornerValue)
                hasCustomCorners = true
            }
        }
        
        if hasCustomCorners {
            layer.maskedCorners = cornerMask
        }
        
        // Border color and width
        if let borderColorStr = props["borderColor"] as? String {
            layer.borderColor = UIColor(named: borderColorStr)?.cgColor
        }
        
        if let borderWidth = props["borderWidth"] as? CGFloat {
            layer.borderWidth = borderWidth
        }
        
        // Background color and opacity
        if let backgroundColorStr = props["backgroundColor"] as? String,
           let backgroundColor = UIColor(named: backgroundColorStr) {
            self.backgroundColor = backgroundColor
        }
        
        if let opacity = props["opacity"] as? CGFloat {
            self.alpha = opacity
        }
        
        // Shadow properties
        if let shadowColorStr = props["shadowColor"] as? String,
           let shadowColor = UIColor(named: shadowColorStr) {
            layer.shadowColor = shadowColor.cgColor
        }
        
        if let shadowOpacity = props["shadowOpacity"] as? Float {
            layer.shadowOpacity = shadowOpacity
        }
        
        if let shadowRadius = props["shadowRadius"] as? CGFloat {
            layer.shadowRadius = shadowRadius
        }
        
        if let shadowOffsetX = props["shadowOffsetX"] as? CGFloat,
           let shadowOffsetY = props["shadowOffsetY"] as? CGFloat {
            layer.shadowOffset = CGSize(width: shadowOffsetX, height: shadowOffsetY)
        }
        
        // Transform - simple 2D transforms only for now
        if let transform = props["transform"] as? [String: Any] {
            var transformMatrix = CGAffineTransform.identity
            
            if let translateX = transform["translateX"] as? CGFloat,
               let translateY = transform["translateY"] as? CGFloat {
                transformMatrix = transformMatrix.translatedBy(x: translateX, y: translateY)
            }
            
            if let scale = transform["scale"] as? CGFloat {
                transformMatrix = transformMatrix.scaledBy(x: scale, y: scale)
            }
            
            if let scaleX = transform["scaleX"] as? CGFloat,
               let scaleY = transform["scaleY"] as? CGFloat {
                transformMatrix = transformMatrix.scaledBy(x: scaleX, y: scaleY)
            }
            
            if let rotation = transform["rotate"] as? CGFloat {
                transformMatrix = transformMatrix.rotated(by: rotation * .pi / 180.0)
            }
            
            self.transform = transformMatrix
        }
        
        // Accessibility properties
        if let accessible = props["accessible"] as? Bool {
            self.isAccessibilityElement = accessible
        }
        
        if let label = props["accessibilityLabel"] as? String {
            self.accessibilityLabel = label
        }
        
        if let testID = props["testID"] as? String {
            self.accessibilityIdentifier = testID
        }
    }
}
