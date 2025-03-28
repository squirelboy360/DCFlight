//
//  DCGestureDetector.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// GestureDetector component that handles various touch/gesture events
class DCGestureDetector: DCBaseView {
    private var tapGesture: UITapGestureRecognizer?
    private var doubleTapGesture: UITapGestureRecognizer?
    private var panGesture: UIPanGestureRecognizer?
    private var pinchGesture: UIPinchGestureRecognizer?
    private var rotationGesture: UIRotationGestureRecognizer?
    private var longPressGesture: UILongPressGestureRecognizer?
    
    // Initial touch values for differentiating gestures
    private var initialTouchLocation: CGPoint?
    private var initialTouchTimestamp: TimeInterval?
    private var touchMovementThreshold: CGFloat = 10.0
    
    override func setupView() {
        super.setupView()
        
        // We don't add any gestures by default - we'll add them based on props
        isUserInteractionEnabled = true
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Enable/disable all gestures
        if let enabled = props["enabled"] as? Bool {
            isUserInteractionEnabled = enabled
        }
        
        // Configure tap gesture
        if props["onTap"] != nil && tapGesture == nil {
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            tapGesture?.requiresExclusiveTouchType = false
            addGestureRecognizer(tapGesture!)
            
            // If we also have a double tap, make single tap wait for double tap failure
            if props["onDoubleTap"] != nil {
                tapGesture?.require(toFail: doubleTapGesture!)
            }
        }
        
        // Configure double tap gesture
        if props["onDoubleTap"] != nil && doubleTapGesture == nil {
            doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
            doubleTapGesture?.numberOfTapsRequired = 2
            doubleTapGesture?.requiresExclusiveTouchType = false
            addGestureRecognizer(doubleTapGesture!)
        }
        
        // Configure pan (drag) gesture
        if (props["onPanStart"] != nil || props["onPanUpdate"] != nil || props["onPanEnd"] != nil) && panGesture == nil {
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            panGesture?.requiresExclusiveTouchType = false
            addGestureRecognizer(panGesture!)
        }
        
        // Configure pinch gesture
        if (props["onPinchStart"] != nil || props["onPinchUpdate"] != nil || props["onPinchEnd"] != nil) && pinchGesture == nil {
            pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            pinchGesture?.requiresExclusiveTouchType = false
            addGestureRecognizer(pinchGesture!)
        }
        
        // Configure rotation gesture
        if (props["onRotateStart"] != nil || props["onRotateUpdate"] != nil || props["onRotateEnd"] != nil) && rotationGesture == nil {
            rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
            rotationGesture?.requiresExclusiveTouchType = false
            addGestureRecognizer(rotationGesture!)
        }
        
        // Configure long press gesture
        if props["onLongPress"] != nil && longPressGesture == nil {
            longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
            
            // Allow customization of long press duration
            if let longPressDuration = props["longPressDuration"] as? TimeInterval {
                longPressGesture?.minimumPressDuration = longPressDuration
            } else {
                longPressGesture?.minimumPressDuration = 0.5 // Default duration
            }
            
            longPressGesture?.requiresExclusiveTouchType = false
            addGestureRecognizer(longPressGesture!)
        }
        
        // Set movement threshold if specified
        if let threshold = props["touchMovementThreshold"] as? CGFloat {
            touchMovementThreshold = threshold
        }
    }
    
    // MARK: - Gesture Handlers
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let location = gesture.location(in: self)
            
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onTap",
                params: [
                    "x": location.x,
                    "y": location.y,
                    "timestamp": Date().timeIntervalSince1970 * 1000,
                    "target": viewId
                ]
            )
        }
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            let location = gesture.location(in: self)
            
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onDoubleTap",
                params: [
                    "x": location.x,
                    "y": location.y,
                    "timestamp": Date().timeIntervalSince1970 * 1000,
                    "target": viewId
                ]
            )
        }
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let velocity = gesture.velocity(in: self)
        let translation = gesture.translation(in: self)
        
        var eventName: String
        
        switch gesture.state {
        case .began:
            eventName = "onPanStart"
        case .changed:
            eventName = "onPanUpdate"
        case .ended, .cancelled, .failed:
            eventName = "onPanEnd"
        default:
            return
        }
        
        let params: [String: Any] = [
            "x": location.x,
            "y": location.y,
            "deltaX": translation.x,
            "deltaY": translation.y,
            "velocityX": velocity.x,
            "velocityY": velocity.y,
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "target": viewId
        ]
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: eventName,
            params: params
        )
        
        if gesture.state == .ended || gesture.state == .cancelled {
            // Reset translation when gesture ends
            gesture.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        let location = gesture.location(in: self)
        
        var eventName: String
        
        switch gesture.state {
        case .began:
            eventName = "onPinchStart"
        case .changed:
            eventName = "onPinchUpdate"
        case .ended, .cancelled, .failed:
            eventName = "onPinchEnd"
        default:
            return
        }
        
        let params: [String: Any] = [
            "x": location.x,
            "y": location.y,
            "scale": gesture.scale,
            "velocity": gesture.velocity,
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "target": viewId
        ]
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: eventName,
            params: params
        )
        
        if gesture.state == .ended || gesture.state == .cancelled {
            // Reset scale when gesture ends
            gesture.scale = 1.0
        }
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        let location = gesture.location(in: self)
        
        var eventName: String
        
        switch gesture.state {
        case .began:
            eventName = "onRotateStart"
        case .changed:
            eventName = "onRotateUpdate"
        case .ended, .cancelled, .failed:
            eventName = "onRotateEnd"
        default:
            return
        }
        
        // Convert radians to degrees for easier use in JS
        let rotationDegrees = gesture.rotation * 180.0 / .pi
        
        let params: [String: Any] = [
            "x": location.x,
            "y": location.y,
            "rotation": rotationDegrees,
            "velocity": gesture.velocity,
            "timestamp": Date().timeIntervalSince1970 * 1000,
            "target": viewId
        ]
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: eventName,
            params: params
        )
        
        if gesture.state == .ended || gesture.state == .cancelled {
            // Reset rotation when gesture ends
            gesture.rotation = 0.0
        }
    }
    
    @objc func handleLongPressGesture(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: self)
            
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onLongPress",
                params: [
                    "x": location.x,
                    "y": location.y,
                    "timestamp": Date().timeIntervalSince1970 * 1000,
                    "target": viewId
                ]
            )
        }
    }
    
    // MARK: - Direct Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        initialTouchLocation = touch.location(in: self)
        initialTouchTimestamp = Date().timeIntervalSince1970
        
        // Send touchStart event
        let location = touch.location(in: self)
        let pageLocation = touch.location(in: nil)
        
        let params: [String: Any] = [
            "nativeEvent": [
                "locationX": location.x,
                "locationY": location.y,
                "pageX": pageLocation.x,
                "pageY": pageLocation.y,
                "timestamp": Date().timeIntervalSince1970 * 1000
            ],
            "target": viewId
        ]
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onTouchStart",
            params: params
        )
        
        // Check if we should become first responder
        if hasEventListener("onStartShouldSetResponder") {
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onStartShouldSetResponder",
                params: params
            )
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let pageLocation = touch.location(in: nil)
        
        let params: [String: Any] = [
            "nativeEvent": [
                "locationX": location.x,
                "locationY": location.y,
                "pageX": pageLocation.x,
                "pageY": pageLocation.y,
                "timestamp": Date().timeIntervalSince1970 * 1000,
                "touches": Array(touches).map { t -> [String: Any] in
                    let loc = t.location(in: self)
                    return ["locationX": loc.x, "locationY": loc.y]
                }
            ],
            "target": viewId
        ]
        
        // Send touchMove event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onTouchMove",
            params: params
        )
        
        // Check for move responder
        if hasEventListener("onMoveShouldSetResponder") {
            DCViewCoordinator.shared?.sendEvent(
                viewId: viewId,
                eventName: "onMoveShouldSetResponder",
                params: params
            )
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Send touchEnd event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onTouchEnd",
            params: [
                "x": location.x,
                "y": location.y,
                "timestamp": Date().timeIntervalSince1970 * 1000,
                "target": viewId
            ]
        )
        
        resetTouchTracking()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        // Send touchCancel event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onTouchCancel",
            params: [
                "timestamp": Date().timeIntervalSince1970 * 1000,
                "target": viewId
            ]
        )
        
        resetTouchTracking()
    }
    
    private func resetTouchTracking() {
        initialTouchLocation = nil
        initialTouchTimestamp = nil
    }
    
    // Helper method to check if an event is registered
    func hasEventListener(_ eventName: String) -> Bool {
        if self.responds(to: NSSelectorFromString(eventName)) {
            return true
        }
        return false
    }
}
