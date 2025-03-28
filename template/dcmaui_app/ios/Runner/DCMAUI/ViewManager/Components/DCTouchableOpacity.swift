//
//  DCTouchableOpacity.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Touchable component that implements opacity feedback like React Native's TouchableOpacity
class DCTouchableOpacity: DCBaseView {
    // Touchable properties
    private var activeOpacity: CGFloat = 0.2
    private var disabled: Bool = false
    private var pressInDelay: TimeInterval = 0
    private var pressOutDelay: TimeInterval = 0
    
    // Gesture state tracking
    private var isPressed = false
    private var pressInTimeout: Timer?
    private var pressOutTimeout: Timer?
    private var originalAlpha: CGFloat = 1.0
    
    override func setupView() {
        super.setupView()
        
        // Set up defaults
        isUserInteractionEnabled = true
        originalAlpha = alpha
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Store the original alpha when not disabled
        if !disabled {
            originalAlpha = alpha
        }
        
        // Handle touchable specific properties
        if let opacity = props["activeOpacity"] as? CGFloat {
            activeOpacity = opacity
        }
        
        if let disabled = props["disabled"] as? Bool {
            self.disabled = disabled
            isUserInteractionEnabled = !disabled
            alpha = disabled ? 0.5 * originalAlpha : originalAlpha
        }
        
        if let delayPressIn = props["delayPressIn"] as? TimeInterval {
            pressInDelay = delayPressIn / 1000.0  // Convert from ms to seconds
        }
        
        if let delayPressOut = props["delayPressOut"] as? TimeInterval {
            pressOutDelay = delayPressOut / 1000.0  // Convert from ms to seconds
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if disabled { return }
        
        // Cancel any existing timers
        pressInTimeout?.invalidate()
        pressOutTimeout?.invalidate()
        
        // Handle press-in with optional delay
        if pressInDelay > 0 {
            pressInTimeout = Timer.scheduledTimer(withTimeInterval: pressInDelay, repeats: false) { [weak self] _ in
                self?.handlePressIn(touches.first)
            }
        } else {
            handlePressIn(touches.first)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if disabled { return }
        
        // Cancel any existing timers
        pressInTimeout?.invalidate()
        
        // Check if touch ended inside the bounds (for press event)
        let isInside = touches.first.map { touch in
            bounds.contains(touch.location(in: self))
        } ?? false
        
        // Handle press-out with optional delay
        if pressOutDelay > 0 {
            pressOutTimeout = Timer.scheduledTimer(withTimeInterval: pressOutDelay, repeats: false) { [weak self] _ in
                self?.handlePressOut(touches.first)
                
                // Only trigger press event if touch ended inside bounds
                if isInside {
                    self?.handlePress(touches.first)
                }
            }
        } else {
            handlePressOut(touches.first)
            
            // Only trigger press event if touch ended inside bounds
            if isInside {
                handlePress(touches.first)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        if disabled { return }
        
        // Cancel any existing timers
        pressInTimeout?.invalidate()
        pressOutTimeout?.invalidate()
        
        // Immediately handle press-out on touch cancel
        handlePressOut(touches.first)
    }
    
    // MARK: - Event Handlers
    
    private func handlePressIn(_ touch: UITouch?) {
        if isPressed { return }
        isPressed = true
        
        // Apply opacity animation
        UIView.animate(withDuration: 0.15) {
            self.alpha = self.activeOpacity * self.originalAlpha
        }
        
        // Send press-in event
        sendTouchEvent("onPressIn", touch: touch)
    }
    
    private func handlePressOut(_ touch: UITouch?) {
        if !isPressed { return }
        isPressed = false
        
        // Restore original opacity
        UIView.animate(withDuration: 0.15) {
            self.alpha = self.disabled ? 0.5 * self.originalAlpha : self.originalAlpha
        }
        
        // Send press-out event
        sendTouchEvent("onPressOut", touch: touch)
    }
    
    private func handlePress(_ touch: UITouch?) {
        // Send press event
        sendTouchEvent("onPress", touch: touch)
    }
    
    private func sendTouchEvent(_ eventName: String, touch: UITouch?) {
        // Create event data with touch info if available
        var eventData: [String: Any] = [
            "target": viewId,
            "timestamp": Date().timeIntervalSince1970 * 1000
        ]
        
        if let touch = touch {
            let point = touch.location(in: self)
            let pagePoint = touch.location(in: nil)
            
            eventData["locationX"] = point.x
            eventData["locationY"] = point.y
            eventData["pageX"] = pagePoint.x
            eventData["pageY"] = pagePoint.y
        }
        
        // Send the event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: eventName,
            params: eventData
        )
    }
}
