//
//  DCTouchableHighlight.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Touchable component that implements highlight feedback like React Native's TouchableHighlight
class DCTouchableHighlight: DCBaseView {
    // Touchable specific properties
    private var underlayColor: UIColor = UIColor.lightGray.withAlphaComponent(0.5)
    private var disabled: Bool = false
    private var pressInDelay: TimeInterval = 0
    private var pressOutDelay: TimeInterval = 0
    
    // Underlay view for the highlight effect
    private let underlayView = UIView()
    
    // Gesture state tracking
    private var isPressed = false
    private var pressInTimeout: Timer?
    private var pressOutTimeout: Timer?
    
    override func setupView() {
        super.setupView()
        
        // Set up defaults
        isUserInteractionEnabled = true
        
        // Set up underlay view
        underlayView.translatesAutoresizingMaskIntoConstraints = false
        underlayView.isUserInteractionEnabled = false
        underlayView.alpha = 0
        underlayView.backgroundColor = underlayColor
        
        // Insert underlay view at the back
        insertSubview(underlayView, at: 0)
        
        // Constrain underlay view to fill this view
        underlayView.frame = bounds
        underlayView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle touchable specific properties
        if let colorStr = props["underlayColor"] as? String, colorStr.hasPrefix("#") {
            underlayColor = UIColor(hexString: colorStr)
            underlayView.backgroundColor = underlayColor
        }
        
        if let disabled = props["disabled"] as? Bool {
            self.disabled = disabled
            isUserInteractionEnabled = !disabled
            alpha = disabled ? 0.5 : 1.0
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
        
        // Show underlay with animation
        UIView.animate(withDuration: 0.15) {
            self.underlayView.alpha = 1.0
        }
        
        // Send press-in event
        sendTouchEvent("onPressIn", touch: touch)
    }
    
    private func handlePressOut(_ touch: UITouch?) {
        if !isPressed { return }
        isPressed = false
        
        // Hide underlay with animation
        UIView.animate(withDuration: 0.15) {
            self.underlayView.alpha = 0.0
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
    
    // Layout the underlay view to match parent bounds
    override func layoutSubviews() {
        super.layoutSubviews()
        underlayView.frame = bounds
    }
}
