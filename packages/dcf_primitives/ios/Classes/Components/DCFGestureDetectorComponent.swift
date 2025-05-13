import UIKit
import dcflight

/// Component that handles gesture recognition
class DCFGestureDetectorComponent: NSObject, DCFComponent, ComponentMethodHandler {
    // Gesture recognizers by view
    private static var gestureRecognizers = [UIView: [UIGestureRecognizer]]()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a view to capture gestures
        let gestureView = UIView()
        gestureView.backgroundColor = .clear
        
        // Apply props
        updateView(gestureView, withProps: props)
        
        return gestureView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Apply visibility
        if let enabled = props["enabled"] as? Bool {
            view.isUserInteractionEnabled = enabled
        }
        
        // Configure gestures based on events registered
        configureGestures(view)
        
        return true
    }
    
    // Configure gesture recognizers
    private func configureGestures(_ view: UIView) {
        // Clean up previous gesture recognizers
        if let recognizers = DCFGestureDetectorComponent.gestureRecognizers[view] {
            for recognizer in recognizers {
                view.removeGestureRecognizer(recognizer)
            }
        }
        
        // Create new gesture recognizers array for this view
        var recognizers = [UIGestureRecognizer]()
        
        // Add tap gesture recognizer
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)
        recognizers.append(tapRecognizer)
        
        // Add long press gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        view.addGestureRecognizer(longPressRecognizer)
        recognizers.append(longPressRecognizer)
        
        // Add swipe gesture recognizers (left, right, up, down)
        let swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeftRecognizer.direction = .left
        view.addGestureRecognizer(swipeLeftRecognizer)
        recognizers.append(swipeLeftRecognizer)
        
        let swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeRightRecognizer.direction = .right
        view.addGestureRecognizer(swipeRightRecognizer)
        recognizers.append(swipeRightRecognizer)
        
        let swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp(_:)))
        swipeUpRecognizer.direction = .up
        view.addGestureRecognizer(swipeUpRecognizer)
        recognizers.append(swipeUpRecognizer)
        
        let swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown(_:)))
        swipeDownRecognizer.direction = .down
        view.addGestureRecognizer(swipeDownRecognizer)
        recognizers.append(swipeDownRecognizer)
        
        // Add pan gesture recognizer
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        view.addGestureRecognizer(panRecognizer)
        recognizers.append(panRecognizer)
        
        // Store gesture recognizers for cleanup
        DCFGestureDetectorComponent.gestureRecognizers[view] = recognizers
    }
    
    // MARK: - Gesture Handlers
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        if let view = recognizer.view {
            triggerEvent(on: view, eventType: "onTap", eventData: [:])
        }
    }
    
    @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began, let view = recognizer.view {
            triggerEvent(on: view, eventType: "onLongPress", eventData: [:])
        }
    }
    
    @objc func handleSwipeLeft(_ recognizer: UISwipeGestureRecognizer) {
        if let view = recognizer.view {
            triggerEvent(on: view, eventType: "onSwipeLeft", eventData: [:])
        }
    }
    
    @objc func handleSwipeRight(_ recognizer: UISwipeGestureRecognizer) {
        if let view = recognizer.view {
            triggerEvent(on: view, eventType: "onSwipeRight", eventData: [:])
        }
    }
    
    @objc func handleSwipeUp(_ recognizer: UISwipeGestureRecognizer) {
        if let view = recognizer.view {
            triggerEvent(on: view, eventType: "onSwipeUp", eventData: [:])
        }
    }
    
    @objc func handleSwipeDown(_ recognizer: UISwipeGestureRecognizer) {
        if let view = recognizer.view {
            triggerEvent(on: view, eventType: "onSwipeDown", eventData: [:])
        }
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else { return }
        
        let translation = recognizer.translation(in: view)
        let velocity = recognizer.velocity(in: view)
        
        var eventType = "onPan"
        var eventData: [String: Any] = [
            "translationX": translation.x,
            "translationY": translation.y,
            "velocityX": velocity.x,
            "velocityY": velocity.y
        ]
        
        switch recognizer.state {
        case .began:
            eventType = "onPanStart"
        case .changed:
            eventType = "onPanUpdate"
        case .ended, .cancelled:
            eventType = "onPanEnd"
        default:
            return
        }
        
        triggerEvent(on: view, eventType: eventType, eventData: eventData)
    }
    
    // MARK: - Method Handling
    
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        // Handle custom methods
        switch methodName {
        case "enableGestures":
            view.isUserInteractionEnabled = true
            return true
        case "disableGestures":
            view.isUserInteractionEnabled = false
            return true
        default:
            return false
        }
    }
}
