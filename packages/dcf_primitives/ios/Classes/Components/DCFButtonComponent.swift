import UIKit
import yoga
import dcflight


class DCFButtonComponent: NSObject, DCFComponent, ComponentMethodHandler {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a button
        let button = UIButton(type: .system)
        
        // Apply initial styling
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(UIColor.white, for: .normal)
        
        // Set up event handlers
        button.addTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
        
        // Apply props
        updateView(button, withProps: props)
        
        return button
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let button = view as? UIButton else { return false }
        
        // Set title if specified
        if let title = props["title"] as? String {
            button.setTitle(title, for: .normal)
        }
        
        // Set title color if specified
        if let color = props["color"] as? String {
            button.setTitleColor(UIColor.colorFromHexString(color), for: .normal)
        }
        
        // Set background color if specified
        if let backgroundColor = props["backgroundColor"] as? String {
            button.backgroundColor = UIColor.colorFromHexString(backgroundColor)
        }
        
        // Set disabled state if specified
        if let disabled = props["disabled"] as? Bool {
            button.isEnabled = !disabled
            button.alpha = disabled ? 0.5 : 1.0
        }
        
        return true
    }
    
    // Handle button press
    @objc func handleButtonPress(_ sender: UIButton) {
        // Trigger the onPress event
        triggerEvent(on: sender, eventType: "onPress", eventData: [:])
    }
    
    // Handle component methods
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        guard let button = view as? UIButton else { return false }
        
        switch methodName {
        case "setHighlighted":
            if let highlighted = args["highlighted"] as? Bool {
                button.isHighlighted = highlighted
                return true
            }
        case "performClick":
            // Programmatically trigger a button press
            handleButtonPress(button)
            return true
        default:
            return false
        }
        
        return false
    }
}
