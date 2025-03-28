import UIKit
import yoga

class DCMauiViewComponent: NSObject, DCMauiComponentProtocol {
    static func createView(props: [String: Any]) -> UIView {
        let view = UIView()
        
        // Set default frame
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 400)
        
        // Explicitly set a default background color
        view.backgroundColor = .white
        
        // Create and configure yoga node
        let layoutManager = DCMauiLayoutManager.shared
        let yogaNode = layoutManager.createYogaNode(for: view)
        
        // Apply all props including layout
        updateView(view, props: props)
        
        print("DEBUG: Created view with backgroundColor=\(view.backgroundColor?.description ?? "nil")")
        
        return view
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        // Process standard visual properties
        
        // Background color - handle both string and Color object from Dart
        if let bgColorStr = props["backgroundColor"] as? String {
            view.backgroundColor = UIColorFromHex(bgColorStr)
        }
        
        // Apply opacity
        if let opacity = props["opacity"] as? CGFloat {
            view.alpha = opacity
        }
        
        // Apply border radius (cornerRadius in UIKit)
        if let borderRadius = props["borderRadius"] as? CGFloat {
            view.layer.cornerRadius = borderRadius
            view.layer.masksToBounds = true
        }
        
        // Apply individual corner radii if specified
        let corners: [(String, CACornerMask)] = [
            ("borderTopLeftRadius", .layerMinXMinYCorner),
            ("borderTopRightRadius", .layerMaxXMinYCorner),
            ("borderBottomLeftRadius", .layerMinXMaxYCorner),
            ("borderBottomRightRadius", .layerMaxXMaxYCorner)
        ]
        
        var hasCustomCornerRadius = false
        var cornerRadius: CGFloat = 0
        
        for (propName, cornerMask) in corners {
            if let radius = props[propName] as? CGFloat {
                hasCustomCornerRadius = true
                cornerRadius = max(cornerRadius, radius)
                view.layer.cornerRadius = radius
                view.layer.maskedCorners.insert(cornerMask)
            }
        }
        
        if hasCustomCornerRadius {
            view.layer.masksToBounds = true
        }
        
        // Apply borders
        if let borderWidth = props["borderWidth"] as? CGFloat {
            view.layer.borderWidth = borderWidth
        }
        
        if let borderColor = props["borderColor"] as? String {
            view.layer.borderColor = UIColorFromHex(borderColor).cgColor
        }
        
        // Handle shadow properties - these need masksToBounds = false
        let hasShadow = props["shadowColor"] != nil || 
                        props["shadowOpacity"] != nil || 
                        props["shadowRadius"] != nil || 
                        props["shadowOffset"] != nil
        
        // For views with both shadows and corner radius/clipping, we need a container approach
        if hasShadow && (props["borderRadius"] != nil || hasCustomCornerRadius) {
            // This is a best-effort solution for the shadow + corner radius conflict
            // Full solution would involve nested views
            
            if let shadowColorStr = props["shadowColor"] as? String {
                view.layer.shadowColor = UIColorFromHex(shadowColorStr).cgColor
                
                // We'll prioritize shadows over clipping in this simple implementation
                view.layer.masksToBounds = false
            }
            
            if let shadowOpacity = props["shadowOpacity"] as? Float {
                view.layer.shadowOpacity = shadowOpacity
            } else {
                // Default shadow opacity if color is set but opacity isn't
                if props["shadowColor"] != nil {
                    view.layer.shadowOpacity = 0.5
                }
            }
            
            if let shadowRadius = props["shadowRadius"] as? CGFloat {
                view.layer.shadowRadius = shadowRadius
            }
            
            if let shadowOffset = props["shadowOffset"] as? [String: CGFloat],
               let width = shadowOffset["width"],
               let height = shadowOffset["height"] {
                view.layer.shadowOffset = CGSize(width: width, height: height)
            }
            
            // Create a shadow path to improve performance
            if view.layer.cornerRadius > 0 {
                view.layer.shadowPath = UIBezierPath(
                    roundedRect: view.bounds,
                    cornerRadius: view.layer.cornerRadius
                ).cgPath
            }
        } else if hasShadow {
            // Simple case - just shadow without corner radius conflict
            if let shadowColorStr = props["shadowColor"] as? String {
                view.layer.shadowColor = UIColorFromHex(shadowColorStr).cgColor
            }
            
            if let shadowOpacity = props["shadowOpacity"] as? Float {
                view.layer.shadowOpacity = shadowOpacity
            } else if props["shadowColor"] != nil {
                view.layer.shadowOpacity = 0.5 // Default
            }
            
            if let shadowRadius = props["shadowRadius"] as? CGFloat {
                view.layer.shadowRadius = shadowRadius
            }
            
            if let shadowOffset = props["shadowOffset"] as? [String: CGFloat],
               let width = shadowOffset["width"],
               let height = shadowOffset["height"] {
                view.layer.shadowOffset = CGSize(width: width, height: height)
            }
        }
        
        // Other visual properties
        if let overflow = props["overflow"] as? Bool {
            view.clipsToBounds = overflow
        }
        
        if let zIndex = props["zIndex"] as? CGFloat {
            view.layer.zPosition = zIndex
        }
        
        // Apply transforms if provided - CRITICAL FOR ANIMATIONS
        if let transform = props["transform"] as? [String: Any] {
            var transforms = [CATransform3D]()
            
            // Start with identity transform
            var combinedTransform = CATransform3DIdentity
            
            // Process scale transforms
            if let scale = transform["scale"] as? CGFloat {
                let scaleTransform = CATransform3DMakeScale(scale, scale, 1.0)
                transforms.append(scaleTransform)
                print("DEBUG: Applied scale transform: \(scale) to \(view)")
            } else {
                // Handle individual axis scaling
                let scaleX = transform["scaleX"] as? CGFloat ?? 1.0
                let scaleY = transform["scaleY"] as? CGFloat ?? 1.0
                
                if scaleX != 1.0 || scaleY != 1.0 {
                    let scaleTransform = CATransform3DMakeScale(scaleX, scaleY, 1.0)
                    transforms.append(scaleTransform)
                    print("DEBUG: Applied scaleX: \(scaleX), scaleY: \(scaleY) to \(view)")
                }
            }
            
            // Process rotation transforms (in degrees, convert to radians)
            if let rotateDeg = transform["rotate"] as? CGFloat {
                let rotateRad = rotateDeg * .pi / 180.0
                let rotateTransform = CATransform3DMakeRotation(rotateRad, 0, 0, 1.0)
                transforms.append(rotateTransform)
                print("DEBUG: Applied rotation transform: \(rotateDeg) degrees to \(view)")
            }
            
            // Process translation transforms
            let translateX = transform["translateX"] as? CGFloat ?? 0.0
            let translateY = transform["translateY"] as? CGFloat ?? 0.0
            
            if translateX != 0.0 || translateY != 0.0 {
                let translateTransform = CATransform3DMakeTranslation(translateX, translateY, 0.0)
                transforms.append(translateTransform)
                print("DEBUG: Applied translation transform - X: \(translateX), Y: \(translateY) to \(view)")
            }
            
            // Combine all transforms
            combinedTransform = transforms.reduce(CATransform3DIdentity) { result, transform in
                CATransform3DConcat(result, transform)
            }
            
            // Apply the combined transform to the view's layer
            view.layer.transform = combinedTransform
            
            // Set animation properties
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.15) // 150ms matches the animation timing in Dart
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
            // The actual transform is applied when the transaction ends
            CATransaction.commit()
            
            print("DEBUG: Applied combined transform with animation to \(view)")
        } else {
            // Reset transform to identity if not specified
            view.layer.transform = CATransform3DIdentity
        }
        
        // Track margin changes for animation
        if let marginTop = props["marginTop"] as? CGFloat {
            // Apply margin through frame manipulation
            var frame = view.frame
            frame.origin.y = marginTop
            
            // Animate margin change
            UIView.animate(withDuration: 0.15, // 150ms to match Dart timing
                          delay: 0,
                          options: .curveEaseInOut,
                          animations: {
                              view.frame = frame
                          })
            print("DEBUG: Applied marginTop: \(marginTop) with animation to \(view)")
        }
        
        // Position properties for absolute positioning
        if let position = props["position"] as? String, position == "absolute" {
            // These are handled by the yoga layout system, but in case we're
            // manually positioning, we can use these values
            if let top = props["top"] as? CGFloat {
                var frame = view.frame
                frame.origin.y = top
                view.frame = frame
            }
            
            if let left = props["left"] as? CGFloat {
                var frame = view.frame
                frame.origin.x = left
                view.frame = frame
            }
            
            if let right = props["right"] as? CGFloat,
               let superview = view.superview {
                var frame = view.frame
                frame.origin.x = superview.bounds.width - frame.width - right
                view.frame = frame
            }
            
            if let bottom = props["bottom"] as? CGFloat,
               let superview = view.superview {
                var frame = view.frame
                frame.origin.y = superview.bounds.height - frame.height - bottom
                view.frame = frame
            }
        }
        
        // Apply layout properties - this will handle positioning and sizing
        applyLayoutProps(view, props: props)
    }
    
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // View components typically don't have events, but we could add tap gestures here
        if eventTypes.contains("press") || eventTypes.contains("tap") {
            // Add tap gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: nil, action: nil)
            tapGesture.addTarget { gestureRecognizer in
                let location = gestureRecognizer.location(in: view)
                eventCallback(viewId, "press", [
                    "x": location.x,
                    "y": location.y
                ])
            }
            view.addGestureRecognizer(tapGesture)
            view.isUserInteractionEnabled = true
        }
    }
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        if eventTypes.contains("press") || eventTypes.contains("tap") {
            // Remove all gesture recognizers
            if let recognizers = view.gestureRecognizers {
                for recognizer in recognizers {
                    view.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
}

// Helper extension for gesture handling
extension UITapGestureRecognizer {
    private class ActionHandler {
        let action: (UITapGestureRecognizer) -> Void
        
        init(action: @escaping (UITapGestureRecognizer) -> Void) {
            self.action = action
        }
        
        @objc func handleTap(sender: UITapGestureRecognizer) {
            action(sender)
        }
    }
    
    private struct AssociatedKeys {
        static var actionHandler = "ActionHandler"
    }
    
    private var actionHandler: ActionHandler? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.actionHandler) as? ActionHandler
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.actionHandler, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTarget(action: @escaping (UITapGestureRecognizer) -> Void) {
        actionHandler = ActionHandler(action: action)
        addTarget(actionHandler, action: #selector(ActionHandler.handleTap))
    }
}
