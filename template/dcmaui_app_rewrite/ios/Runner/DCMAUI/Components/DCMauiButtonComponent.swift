import UIKit
import yoga

class DCMauiButtonComponent: NSObject, DCMauiComponentProtocol {
    private static var buttonEventHandlers: [UIButton: (String, (String, String, [String: Any]) -> Void)] = [:]
    
    static func createView(props: [String: Any]) -> UIView {
        // Create a standard system button
        let button = UIButton(type: .system)
        
        // Ensure user interaction is enabled
        button.isUserInteractionEnabled = true
        
        // Create Yoga node for this button
        let _ = DCMauiLayoutManager.shared.createYogaNode(for: button)
        
        // Set title if available
        if let title = props["title"] as? String {
            button.setTitle(title, for: .normal)
        }
        
        // Apply other properties
        updateView(button, props: props)
        
        return button
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        guard let button = view as? UIButton else { return }
        
        // Basic properties
        if let title = props["title"] as? String {
            button.setTitle(title, for: .normal)
        }
        
        // Handle text color - now supporting both string and Color object
        if let color = props["color"] as? String {
            button.setTitleColor(UIColorFromHex(color), for: .normal)
        }
        
        // Handle background color - both string and Color object 
        if let backgroundColor = props["backgroundColor"] as? String {
            button.backgroundColor = UIColorFromHex(backgroundColor)
        }
        
        // Handle disabled state for color
        if let disabled = props["disabled"] as? Bool, disabled {
            button.isEnabled = false
            
            // Apply disabled color if provided
            if let disabledColor = props["disabledColor"] as? String {
                button.setTitleColor(UIColorFromHex(disabledColor), for: .disabled)
            } else {
                // Default disabled color
                button.setTitleColor(UIColor.lightGray, for: .disabled)
            }
        } else {
            button.isEnabled = true
        }
        
        // Font properties
        if let fontSize = props["fontSize"] as? CGFloat {
            if let fontWeight = props["fontWeight"] as? String {
                // Apply both size and weight
                switch fontWeight {
                case "bold":
                    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
                case "100": 
                    button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .ultraLight)
                case "200": 
                    button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .thin)
                case "300": 
                    button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .light)
                case "400": 
                    button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
                case "500": 
                    button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
                case "600": 
                    button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
                case "700": 
                    button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
                case "800": 
                    button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .heavy)
                case "900": 
                    button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .black)
                default:
                    button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
                }
            } else {
                // Just apply font size
                button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            }
        } else if let fontWeight = props["fontWeight"] as? String {
            // Just apply font weight with default size
            let defaultSize = button.titleLabel?.font.pointSize ?? 15.0
            switch fontWeight {
            case "bold":
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: defaultSize)
            case "normal":
                button.titleLabel?.font = UIFont.systemFont(ofSize: defaultSize)
            default:
                if let weight = Int(fontWeight), weight >= 100 && weight <= 900 {
                    let uiWeight: UIFont.Weight
                    switch weight {
                    case 100: uiWeight = .ultraLight
                    case 200: uiWeight = .thin
                    case 300: uiWeight = .light
                    case 400: uiWeight = .regular
                    case 500: uiWeight = .medium
                    case 600: uiWeight = .semibold
                    case 700: uiWeight = .bold
                    case 800: uiWeight = .heavy
                    case 900: uiWeight = .black
                    default: uiWeight = .regular
                    }
                    button.titleLabel?.font = UIFont.systemFont(ofSize: defaultSize, weight: uiWeight)
                }
            }
        }

        // Shadow properties - buttons can have shadows too
        if let shadowColor = props["shadowColor"] as? String {
            button.layer.shadowColor = UIColorFromHex(shadowColor).cgColor
            button.layer.shadowOpacity = props["shadowOpacity"] as? Float ?? 0.5
            button.layer.shadowRadius = props["shadowRadius"] as? CGFloat ?? 3.0
            
            if let shadowOffset = props["shadowOffset"] as? [String: CGFloat],
               let width = shadowOffset["width"],
               let height = shadowOffset["height"] {
                button.layer.shadowOffset = CGSize(width: width, height: height)
            } else {
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
            }
        }
        
        // Padding inside button
        if let padding = props["padding"] as? CGFloat {
            button.contentEdgeInsets = UIEdgeInsets(
                top: padding,
                left: padding,
                bottom: padding,
                right: padding
            )
        } else {
            // Directional padding
            let top = props["paddingTop"] as? CGFloat ?? 0
            let left = props["paddingLeft"] as? CGFloat ?? 0
            let bottom = props["paddingBottom"] as? CGFloat ?? 0
            let right = props["paddingRight"] as? CGFloat ?? 0
            
            if top != 0 || left != 0 || bottom != 0 || right != 0 {
                button.contentEdgeInsets = UIEdgeInsets(
                    top: top,
                    left: left,
                    bottom: bottom,
                    right: right
                )
            }
        }
        
        // Border properties
        if let borderWidth = props["borderWidth"] as? CGFloat {
            button.layer.borderWidth = borderWidth
        }
        
        if let borderColor = props["borderColor"] as? String {
            button.layer.borderColor = UIColorFromHex(borderColor).cgColor
        }
        
        // Border radius
        if let borderRadius = props["borderRadius"] as? CGFloat {
            button.layer.cornerRadius = borderRadius
            button.clipsToBounds = true
        }
        
        // Handle explicit button size
        if let width = props["width"] as? CGFloat, 
           let height = props["height"] as? CGFloat {
            // Setting frame directly for the button can help with internal layout
            let currentFrame = button.frame
            button.frame = CGRect(x: currentFrame.origin.x, 
                                 y: currentFrame.origin.y, 
                                 width: width, 
                                 height: height)
        }
        
        // Apply opacity
        if let opacity = props["opacity"] as? CGFloat {
            button.alpha = opacity
        }

        // Apply layout properties - this will handle all positioning and sizing
        applyLayoutProps(button, props: props)
    }
    
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let button = view as? UIButton else { return }
        
        for eventType in eventTypes {
            if eventType == "press" {
                // Remove any existing handlers to prevent duplicates
                button.removeTarget(nil, action: nil, for: .touchUpInside)
                
                // Store the viewId and callback
                buttonEventHandlers[button] = (viewId, eventCallback)
                
                // Add the event listener
                button.addTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
                print("Added press event listener to button: \(viewId)")
            }
        }
    }
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let button = view as? UIButton else { return }
        
        for eventType in eventTypes {
            if eventType == "press" {
                button.removeTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
                buttonEventHandlers.removeValue(forKey: button)
            }
        }
    }
    
    @objc static func handleButtonPress(_ sender: UIButton) {
        // Get the stored view ID and callback
        guard let (viewId, callback) = buttonEventHandlers[sender] else {
            print("Button press ignored: no handler registered")
            return
        }
        
        print("Button pressed: \(viewId)")
        
        // Include more useful data for debugging and better bidirectional communication
        let eventData: [String: Any] = [
            "pressed": true,
            "timestamp": Date().timeIntervalSince1970,
            "buttonTitle": sender.title(for: .normal) ?? "",
            "buttonTag": sender.tag
        ]
        
        callback(viewId, "press", eventData)
    }
}
