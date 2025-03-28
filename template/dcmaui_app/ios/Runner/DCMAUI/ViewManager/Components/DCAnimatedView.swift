//
//  DCAnimatedView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Component for handling animated properties, similar to React Native's Animated.View
class DCAnimatedView: DCBaseView {
    // Map of active animations by property name
    private var activeAnimations: [String: CAAnimation] = [:]
    
    override func setupView() {
        super.setupView()
        layer.masksToBounds = false
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle animated styles
        if let animatedStyles = props["animatedStyles"] as? [String: Any] {
            processAnimatedStyles(animatedStyles)
        }
    }
    
    private func processAnimatedStyles(_ animatedStyles: [String: Any]) {
        // Process each animated property
        for (propertyName, propertyValue) in animatedStyles {
            guard let animationDetails = propertyValue as? [String: Any],
                  let toValue = animationDetails["animatedValue"] as? CGFloat,
                  let animationId = animationDetails["animationId"] as? String else {
                continue
            }
            
            // Process animation configuration
            let config = animationDetails["config"] as? [String: Any]
            let duration = (config?["duration"] as? Double) ?? 500.0 / 1000.0
            let delay = (config?["delay"] as? Double) ?? 0.0 / 1000.0
            let easing = config?["easing"] as? String ?? "easeInOut"
            
            // Create and apply the animation
            createAnimation(
                forProperty: propertyName,
                toValue: toValue,
                animationId: animationId,
                duration: duration,
                delay: delay,
                easing: easing
            )
        }
    }
    
    private func createAnimation(forProperty property: String, toValue: CGFloat, 
                                animationId: String, duration: Double, 
                                delay: Double, easing: String) {
        // Map property name to CALayer keyPath
        let keyPath = mapPropertyToKeyPath(property)
        guard !keyPath.isEmpty else { return }
        
        // Create basic animation
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.toValue = toValue
        animation.duration = duration
        animation.beginTime = CACurrentMediaTime() + delay
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        // Apply easing function
        animation.timingFunction = getTimingFunction(easing)
        
        // Remove any existing animation for this property
        if let existingAnimation = activeAnimations[property] {
            layer.removeAnimation(forKey: existingAnimation.description)
        }
        
        // Add the new animation
        let animationKey = "animation_\(property)_\(animationId)"
        layer.add(animation, forKey: animationKey)
        activeAnimations[property] = animation
        
        // Also update the model layer value for when animation completes
        updateLayerProperty(keyPath, toValue: toValue)
        
        // Notify about animation start
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onAnimationStart",
            params: [
                "property": property,
                "toValue": toValue,
                "animationId": animationId
            ]
        )
        
        // Schedule completion notification
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + delay) { [weak self] in
            guard let self = self else { return }
            DCViewCoordinator.shared?.sendEvent(
                viewId: self.viewId,
                eventName: "onAnimationComplete",
                params: [
                    "property": property,
                    "toValue": toValue,
                    "animationId": animationId
                ]
            )
        }
    }
    
    private func mapPropertyToKeyPath(_ property: String) -> String {
        switch property {
        case "opacity":
            return "opacity"
        case "translateX":
            return "transform.translation.x"
        case "translateY":
            return "transform.translation.y"
        case "scale":
            return "transform.scale"
        case "scaleX":
            return "transform.scale.x"
        case "scaleY":
            return "transform.scale.y"
        case "rotation", "rotate":
            return "transform.rotation"
        case "backgroundColor":
            return "backgroundColor"
        case "borderColor":
            return "borderColor"
        case "borderWidth":
            return "borderWidth"
        case "borderRadius", "cornerRadius":
            return "cornerRadius"
        case "shadowOpacity":
            return "shadowOpacity"
        case "shadowRadius":
            return "shadowRadius"
        default:
            print("DC MAUI: Unsupported animation property: \(property)")
            return ""
        }
    }
    
    private func getTimingFunction(_ easing: String) -> CAMediaTimingFunction {
        switch easing {
        case "linear":
            return CAMediaTimingFunction(name: .linear)
        case "easeIn":
            return CAMediaTimingFunction(name: .easeIn)
        case "easeOut":
            return CAMediaTimingFunction(name: .easeOut)
        case "easeInOut":
            return CAMediaTimingFunction(name: .easeInEaseOut)
        case "spring":
            // Approximation of spring using cubic bezier
            return CAMediaTimingFunction(controlPoints: 0.5, 1.8, 0.9, 0.9)
        default:
            return CAMediaTimingFunction(name: .easeInEaseOut)
        }
    }
    
    private func updateLayerProperty(_ keyPath: String, toValue: CGFloat) {
        // For properties that can be directly set
        switch keyPath {
        case "opacity":
            layer.opacity = Float(toValue)
        case "cornerRadius":
            layer.cornerRadius = toValue
        case "borderWidth":
            layer.borderWidth = toValue
        case "shadowOpacity":
            layer.shadowOpacity = Float(toValue)
        case "shadowRadius":
            layer.shadowRadius = toValue
        default:
            break // Transform properties are handled by animations
        }
    }
}
