//
//  DCPressable.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Pressable component that matches React Native's Pressable
class DCPressable: DCBaseView {
    // Configuration
    private var hitSlop: UIEdgeInsets = .zero
    private var pressRetentionOffset: UIEdgeInsets = .zero
    private var disabled: Bool = false
    private var delayLongPress: TimeInterval = 0.5
    private var minPressDuration: TimeInterval = 0.05
    
    // State tracking
    private var isPressed: Bool = false
    private var pressStartTime: TimeInterval = 0
    private var longPressTimer: Timer?
    private var delayedPressTimer: Timer?
    private var touchActivationPosition: CGPoint?
    
    override func setupView() {
        super.setupView()
        
        // Setup basic properties
        isUserInteractionEnabled = true
        clipsToBounds = true
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle disabled state
        if let disabled = props["disabled"] as? Bool {
            self.disabled = disabled
            isUserInteractionEnabled = !disabled
        }
        
        // Handle hit slop
        if let hitSlopDict = props["hitSlop"] as? [String: CGFloat] {
            let top = hitSlopDict["top"] ?? 0
            let left = hitSlopDict["left"] ?? 0
            let bottom = hitSlopDict["bottom"] ?? 0
            let right = hitSlopDict["right"] ?? 0
            hitSlop = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        // Handle pressure retention offset
        if let retentionOffsetDict = props["pressRetentionOffset"] as? [String: CGFloat] {
            let top = retentionOffsetDict["top"] ?? 0
            let left = retentionOffsetDict["left"] ?? 0
            let bottom = retentionOffsetDict["bottom"] ?? 0
            let right = retentionOffsetDict["right"] ?? 0
            pressRetentionOffset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
        }
        
        // Handle long press delay
        if let delayLongPress = props["delayLongPress"] as? TimeInterval {
            self.delayLongPress = delayLongPress / 1000.0 // Convert ms to seconds
        }
        
        // Handle minimum press duration
        if let minPressDuration = props["minPressDuration"] as? TimeInterval {
            self.minPressDuration = minPressDuration / 1000.0 // Convert ms to seconds
        }
        
        // Handle button-like style
        if let style = props["style"] as? [String: Any] {
            applyStyles(style)
        }
    }
    
    private func applyStyles(_ style: [String: Any]) {
        // Implement like other components
        if let backgroundColor = style["backgroundColor"] as? String, backgroundColor.hasPrefix("#") {
            self.backgroundColor = UIColor(hexString: backgroundColor)
        }
        
        if let borderRadius = style["borderRadius"] as? CGFloat {
            layer.cornerRadius = borderRadius
        }
        
        if let borderWidth = style["borderWidth"] as? CGFloat {
            layer.borderWidth = borderWidth
        }
        
        if let borderColor = style["borderColor"] as? String, borderColor.hasPrefix("#") {
            layer.borderColor = UIColor(hexString: borderColor).cgColor
        }
    }
    
    // MARK: - Touch Handling
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Expand touch area with hit slop
        let hitFrame = bounds.inset(by: UIEdgeInsets(
            top: -hitSlop.top,
            left: -hitSlop.left,
            bottom: -hitSlop.bottom,
            right: -hitSlop.right
        ))
        return hitFrame.contains(point)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if disabled { return }
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        touchActivationPosition = touchLocation
        pressStartTime = Date().timeIntervalSince1970
        
        // Cancel any existing timers
        delayedPressTimer?.invalidate()
        longPressTimer?.invalidate()
        
        // Schedule press handling based on minPressDuration
        if minPressDuration > 0 {
            delayedPressTimer = Timer.scheduledTimer(withTimeInterval: minPressDuration, repeats: false) { [weak self] _ in
                self?.handlePressIn(touchLocation)
            }
        } else {
            handlePressIn(touchLocation)
        }
        
        // Schedule long press detection
        longPressTimer = Timer.scheduledTimer(withTimeInterval: delayLongPress, repeats: false) { [weak self] _ in
            self?.handleLongPress(touchLocation)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if disabled { return }
        
        guard let touch = touches.first,
              let activationPosition = touchActivationPosition else { return }
        
        let touchLocation = touch.location(in: self)
        
        // Determine if touch is inside the view plus retention offset
        let retentionFrame = bounds.inset(by: UIEdgeInsets(
            top: -pressRetentionOffset.top,
            left: -pressRetentionOffset.left,
            bottom: -pressRetentionOffset.bottom,
            right: -pressRetentionOffset.right
        ))
        
        let isInside = retentionFrame.contains(touchLocation)
        
        // Update pressed state
        if isInside != isPressed {
            if isInside {
                handlePressIn(touchLocation)
            } else {
                handlePressOut(touchLocation)
                
                // Cancel long press if we moved out
                longPressTimer?.invalidate()
                longPressTimer = nil
            }
        }
        
        // Send move event
        sendEvent(
            eventName: "onPressMove",
            touchLocation: touchLocation,
            activationPosition: activationPosition
        )
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if disabled { return }
        
        // Cancel scheduled timers
        delayedPressTimer?.invalidate()
        longPressTimer?.invalidate()
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        // Only trigger press if ending inside view bounds
        if bounds.contains(touchLocation) && isPressed {
            handlePress(touchLocation)
        }
        
        handlePressOut(touchLocation)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        // Cancel scheduled timers
        delayedPressTimer?.invalidate()
        longPressTimer?.invalidate()
        
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: self)
        
        handlePressOut(touchLocation)
    }
    
    // MARK: - Event Handlers
    
    private func handlePressIn(_ touchLocation: CGPoint) {
        if isPressed { return }
        isPressed = true
        
        // Apply pressed state
        updatePressedStyle(true)
        
        // Send press-in event
        sendEvent(eventName: "onPressIn", touchLocation: touchLocation)
    }
    
    private func handlePressOut(_ touchLocation: CGPoint) {
        if !isPressed { return }
        isPressed = false
        
        // Reset pressed state
        updatePressedStyle(false)
        
        // Send press-out event
        sendEvent(eventName: "onPressOut", touchLocation: touchLocation)
    }
    
    private func handlePress(_ touchLocation: CGPoint) {
        // Calculate press duration
        let pressDuration = Date().timeIntervalSince1970 - pressStartTime
        
        // Send press event
        sendEvent(
            eventName: "onPress",
            touchLocation: touchLocation,
            extraParams: ["pressDuration": pressDuration * 1000] // Convert to ms
        )
    }
    
    private func handleLongPress(_ touchLocation: CGPoint) {
        // Send long press event
        sendEvent(eventName: "onLongPress", touchLocation: touchLocation)
    }
    
    private func updatePressedStyle(_ isPressed: Bool) {
        // Dynamic style update will be handled via the JS-side based on pressed state
        // This is a key difference from other touchables
        
        // We send the pressure state and let the styling be handled via the state callbacks
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onPressStateChange",
            params: [
                "pressed": isPressed,
                "target": viewId
            ]
        )
    }
    
    private func sendEvent(
        eventName: String,
        touchLocation: CGPoint,
        activationPosition: CGPoint? = nil,
        extraParams: [String: Any] = [:]
    ) {
        var params: [String: Any] = [
            "locationX": touchLocation.x,
            "locationY": touchLocation.y,
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "target": viewId
        ]
        
        // Add activation position if available (for move events)
        if let activationPosition = activationPosition {
            params["initialLocationX"] = activationPosition.x
            params["initialLocationY"] = activationPosition.y
        }
        
        // Add any additional parameters
        for (key, value) in extraParams {
            params[key] = value
        }
        
        // Send the event
        DCViewCoordinator.shared?.sendEvent(viewId: viewId, eventName: eventName, params: params)
    }
}
