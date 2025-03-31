import UIKit
import yoga

/// Manages layout for DCMAUI components
/// Note: Primary layout calculations occur on the Dart side
/// This class primarily handles applying calculated layouts and handling absolute positioning
class DCMauiLayoutManager {
    // Singleton instance
    static let shared = DCMauiLayoutManager()
    
    // Set of views using absolute layout (controlled by Dart)
    private var absoluteLayoutViews = Set<UIView>()
    
    // Map view IDs to actual UIViews for direct access
    private var viewRegistry = [String: UIView]()
    
    private init() {}
    
    // Register a view with an ID
    func registerView(_ view: UIView, withId viewId: String) {
        viewRegistry[viewId] = view
    }
    
    // Unregister a view
    func unregisterView(withId viewId: String) {
        viewRegistry.removeValue(forKey: viewId)
    }
    
    // Get view by ID
    func getView(withId viewId: String) -> UIView? {
        return viewRegistry[viewId]
    }
    
    // Apply layout directly to a view
    func applyLayout(to viewId: String, left: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat) -> Bool {
        guard let view = viewRegistry[viewId] else {
            print("⚠️ Cannot apply layout: View with ID \(viewId) not found")
            return false
        }
        
        // Ensure values are valid
        guard !left.isNaN && !top.isNaN && !width.isNaN && !height.isNaN else {
            print("⚠️ Invalid layout values: \(left), \(top), \(width), \(height)")
            return false
        }
        
        // Set absolute positioning flag
        setViewUsingAbsoluteLayout(view: view)
        
        // Apply the frame
        view.frame = CGRect(x: left, y: top, width: width, height: height)
        print("📏 Applied layout to \(viewId): \(view.frame)")
        
        return true
    }
    
    // Mark a view as using absolute layout (controlled by Dart side)
    func setViewUsingAbsoluteLayout(view: UIView) {
        absoluteLayoutViews.insert(view)
    }
    
    // Check if a view uses absolute layout
    func isUsingAbsoluteLayout(_ view: UIView) -> Bool {
        return absoluteLayoutViews.contains(view)
    }
    
    // Clean up resources for a view
    func cleanUp(viewId: String) {
        if let view = viewRegistry[viewId] {
            absoluteLayoutViews.remove(view)
        }
        viewRegistry.removeValue(forKey: viewId)
    }
    
    // Apply styles to a view (non-layout properties)
    func applyStyles(to view: UIView, props: [String: Any]) {
        // Common styling properties that work for all UIView types
        // Background color
        if let backgroundColor = props["backgroundColor"] as? String {
            view.backgroundColor = ColorUtilities.color(fromHexString: backgroundColor)
        }
        
        // Opacity
        if let opacity = props["opacity"] as? CGFloat {
            view.alpha = opacity
        }
        
        // Border properties
        if let borderRadius = props["borderRadius"] as? CGFloat {
            view.layer.cornerRadius = borderRadius
            view.clipsToBounds = true
        }
        
        // Individual corner radii - these override borderRadius if present
        if let topLeftRadius = props["borderTopLeftRadius"] as? CGFloat,
           let topRightRadius = props["borderTopRightRadius"] as? CGFloat,
           let bottomLeftRadius = props["borderBottomLeftRadius"] as? CGFloat,
           let bottomRightRadius = props["borderBottomRightRadius"] as? CGFloat {
            
            // Create a mask layer for custom corner radii
            let maskLayer = CAShapeLayer()
            
            // Create a path with the custom corner radii
            let path = UIBezierPath(
                roundedRect: view.bounds,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: 0, height: 0) // Will be modified by custom corners
            )
            
            // Create a rounded rect for each corner with the specific radius
            let topLeftRect = CGRect(x: 0, y: 0, width: topLeftRadius * 2, height: topLeftRadius * 2)
            let topRightRect = CGRect(x: view.bounds.width - topRightRadius * 2, y: 0, 
                                    width: topRightRadius * 2, height: topRightRadius * 2)
            let bottomLeftRect = CGRect(x: 0, y: view.bounds.height - bottomLeftRadius * 2, 
                                      width: bottomLeftRadius * 2, height: bottomLeftRadius * 2)
            let bottomRightRect = CGRect(x: view.bounds.width - bottomRightRadius * 2, 
                                       y: view.bounds.height - bottomRightRadius * 2,
                                       width: bottomRightRadius * 2, height: bottomRightRadius * 2)
            
            // Add corners to the path
            path.append(UIBezierPath(roundedRect: topLeftRect, cornerRadius: topLeftRadius))
            path.append(UIBezierPath(roundedRect: topRightRect, cornerRadius: topRightRadius))
            path.append(UIBezierPath(roundedRect: bottomLeftRect, cornerRadius: bottomLeftRadius))
            path.append(UIBezierPath(roundedRect: bottomRightRect, cornerRadius: bottomRightRadius))
            
            maskLayer.path = path.cgPath
            view.layer.mask = maskLayer
            view.clipsToBounds = true
        }
        // Individual corner radii - handle partial definitions
        else {
            if let topLeftRadius = props["borderTopLeftRadius"] as? CGFloat {
                view.layer.maskedCorners.insert(.layerMinXMinYCorner)
                view.layer.cornerRadius = topLeftRadius
                view.clipsToBounds = true
            }
            
            if let topRightRadius = props["borderTopRightRadius"] as? CGFloat {
                view.layer.maskedCorners.insert(.layerMaxXMinYCorner)
                view.layer.cornerRadius = topRightRadius
                view.clipsToBounds = true
            }
            
            if let bottomLeftRadius = props["borderBottomLeftRadius"] as? CGFloat {
                view.layer.maskedCorners.insert(.layerMinXMaxYCorner)
                view.layer.cornerRadius = bottomLeftRadius
                view.clipsToBounds = true
            }
            
            if let bottomRightRadius = props["borderBottomRightRadius"] as? CGFloat {
                view.layer.maskedCorners.insert(.layerMaxXMaxYCorner)
                view.layer.cornerRadius = bottomRightRadius
                view.clipsToBounds = true
            }
        }
        
        if let borderColor = props["borderColor"] as? String {
            view.layer.borderColor = ColorUtilities.color(fromHexString: borderColor)?.cgColor
        }
        
        if let borderWidth = props["borderWidth"] as? CGFloat {
            view.layer.borderWidth = borderWidth
        }
        
        // Shadow properties - need to be applied as a group for performance
        let hasShadow = props["shadowRadius"] != nil || 
                      props["shadowColor"] != nil || 
                      props["shadowOpacity"] != nil || 
                      props["shadowOffsetX"] != nil || 
                      props["shadowOffsetY"] != nil
        
        if hasShadow {
            // Default shadow values if not specified
            let shadowRadius = props["shadowRadius"] as? CGFloat ?? 3.0
            let shadowOpacity = props["shadowOpacity"] as? Float ?? 0.3
            let shadowOffsetX = props["shadowOffsetX"] as? CGFloat ?? 0
            let shadowOffsetY = props["shadowOffsetY"] as? CGFloat ?? 2
            
            // Set shadow properties
            view.layer.shadowRadius = shadowRadius
            view.layer.shadowOpacity = shadowOpacity
            view.layer.shadowOffset = CGSize(width: shadowOffsetX, height: shadowOffsetY)
            
            if let shadowColor = props["shadowColor"] as? String,
               let color = ColorUtilities.color(fromHexString: shadowColor) {
                view.layer.shadowColor = color.cgColor
            } else {
                // Default shadow color is black
                view.layer.shadowColor = UIColor.black.cgColor
            }
            
            // Create a shadow path for better performance
            view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, 
                                               cornerRadius: view.layer.cornerRadius).cgPath
        }
        
        // Android-specific elevation (map to iOS shadow)
        if let elevation = props["elevation"] as? Int, elevation > 0 {
            // Only apply if no explicit shadow is defined
            if (!hasShadow) {
                // Convert elevation to iOS shadow values
                let shadowRadius = CGFloat(elevation) * 0.5
                let shadowOpacity = Float(0.2 + Float(elevation) * 0.03)
                let shadowOffsetY = CGFloat(elevation) * 0.3
                
                view.layer.shadowRadius = shadowRadius
                view.layer.shadowOpacity = shadowOpacity
                view.layer.shadowOffset = CGSize(width: 0, height: shadowOffsetY)
                view.layer.shadowColor = UIColor.black.cgColor
                
                // Create a shadow path for better performance
                view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, 
                                                   cornerRadius: view.layer.cornerRadius).cgPath
            }
        }
        
        // Transform properties
        if let transform = props["transform"] as? [String: Any] {
            var transform3D = CATransform3DIdentity
            
            if let translateX = transform["translateX"] as? CGFloat,
               let translateY = transform["translateY"] as? CGFloat {
                transform3D = CATransform3DTranslate(transform3D, translateX, translateY, 0)
            }
            
            if let scale = transform["scale"] as? CGFloat {
                transform3D = CATransform3DScale(transform3D, scale, scale, 1.0)
            } else {
                if let scaleX = transform["scaleX"] as? CGFloat {
                    transform3D = CATransform3DScale(transform3D, scaleX, 1.0, 1.0)
                }
                if let scaleY = transform["scaleY"] as? CGFloat {
                    transform3D = CATransform3DScale(transform3D, 1.0, scaleY, 1.0)
                }
            }
            
            if let rotateZ = transform["rotate"] as? CGFloat {
                // Convert degrees to radians
                let angle = rotateZ * .pi / 180.0
                transform3D = CATransform3DRotate(transform3D, angle, 0, 0, 1)
            }
            
            view.layer.transform = transform3D
        }
        
        // Additional visibility properties
        if let pointerEvents = props["pointerEvents"] as? Bool {
            view.isUserInteractionEnabled = !pointerEvents  // false means allow events
        }
        
        // Accessibility properties
        if let accessible = props["accessible"] as? Bool {
            view.isAccessibilityElement = accessible
        }
        
        if let accessibilityLabel = props["accessibilityLabel"] as? String {
            view.accessibilityLabel = accessibilityLabel
        }
        
        if let testID = props["testID"] as? String {
            view.accessibilityIdentifier = testID
        }
        
        // Handle overflow property
        if let overflow = props["overflow"] as? String {
            switch overflow {
            case "visible":
                view.clipsToBounds = false
            case "hidden":
                view.clipsToBounds = true
            case "scroll":
                view.clipsToBounds = true
            default:
                view.clipsToBounds = false
            }
        }
    }
}
