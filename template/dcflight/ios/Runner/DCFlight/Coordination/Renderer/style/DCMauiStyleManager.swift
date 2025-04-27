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
        let styleProps = StyleSheet.allStyleProperties
        
        return props.filter { styleProps.contains($0.key) }
    }
}

// Style properties constants for consistency
class StyleSheet {
    // Define all style property names for consistency across the framework
    static let allStyleProperties = [
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
}

// UIView extension for style application
extension UIView {
    /// Apply style properties to this view
    func applyStyles(props: [String: Any]) {
        print("📊 Applying styles to \(type(of: self)): \(props)")
        
        // CRITICAL FIX: Special handling for ScrollView to preserve user interaction
        let isScrollView = self is UIScrollView
        
        if isScrollView {
            // Ensure these properties are always set correctly for ScrollView
            self.isUserInteractionEnabled = true
            
            // For scroll views, explicitly preserve scroll functionality
            if let scrollView = self as? UIScrollView {
                // Only apply isScrollEnabled if explicitly set in props
                if let scrollEnabled = props["scrollEnabled"] as? Bool {
                    scrollView.isScrollEnabled = scrollEnabled
                } else {
                    // Otherwise ensure scrolling is enabled
                    scrollView.isScrollEnabled = true
                }
            }
        }
        
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
            layer.borderColor = ColorUtilities.color(fromHexString: borderColorStr)?.cgColor
        }
        
        if let borderWidth = props["borderWidth"] as? CGFloat {
            layer.borderWidth = borderWidth
        }
        
        // Background color and opacity
        if let backgroundColorStr = props["backgroundColor"] as? String {
            self.backgroundColor = ColorUtilities.color(fromHexString: backgroundColorStr)
            print("🎨 Applied backgroundColor: \(backgroundColorStr) to \(type(of: self))")
        }
        
        if let opacity = props["opacity"] as? CGFloat {
            // CRITICAL FIX: Don't set alpha to 0 for ScrollView as it breaks touch handling
            if isScrollView && opacity == 0 {
                self.alpha = 0.01 // Barely visible but still receives touches
            } else {
                self.alpha = opacity
            }
        }
        
        // Shadow properties
        if let shadowColorStr = props["shadowColor"] as? String {
            layer.shadowColor = ColorUtilities.color(fromHexString: shadowColorStr)?.cgColor
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
        
        // CRITICAL FIX: Handle pointer events for scroll views differently
        if let pointerEvents = props["pointerEvents"] as? String {
            // For ScrollView, never disable user interaction completely
            if isScrollView {
                if pointerEvents == "none" {
                    // Enable user interaction but let subviews handle touches
                    self.isUserInteractionEnabled = true
                } else {
                    self.isUserInteractionEnabled = true
                }
            } else {
                // For non-ScrollView elements, handle normally
                switch pointerEvents {
                case "none": self.isUserInteractionEnabled = false
                case "box-none": 
                    self.isUserInteractionEnabled = false
                    for subview in self.subviews {
                        subview.isUserInteractionEnabled = true
                    }
                case "box-only":
                    self.isUserInteractionEnabled = true
                    for subview in self.subviews {
                        subview.isUserInteractionEnabled = false
                    }
                default: self.isUserInteractionEnabled = true
                }
            }
        }
        
        // CRITICAL FIX: Final check for ScrollView to ensure user interaction is enabled
        if isScrollView {
            self.isUserInteractionEnabled = true
            
            if let scrollView = self as? UIScrollView {
                // Check if we need to explicitly enable scrolling again
                if !scrollView.isScrollEnabled {
                    scrollView.isScrollEnabled = true
                    print("🔄 Explicitly re-enabled scrolling for ScrollView")
                }
            }
            
            print("✅ Ensured ScrollView user interaction is enabled")
        }
    }
}
