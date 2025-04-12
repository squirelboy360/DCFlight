import UIKit
import yoga

class DCMauiButtonComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    
    // Static storage for button handlers
    private static var buttonEventHandlers: [UIButton: (String, (String, String, [String: Any]) -> Void)] = [:]
    
    func createView(props: [String: Any]) -> UIView {
        // Create a standard system button directly
        let button = UIButton(type: .system)
        
        // Ensure user interaction is enabled
        button.isUserInteractionEnabled = true
        
        // Apply props to the button directly
        _ = updateView(button, withProps: props)
        
        return button
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let button = view as? UIButton else { 
            print("⚠️ DCMauiButtonComponent: Attempting to update non-button view")
            return false 
        }
        
        // Apply standard styles using common extension
        view.applyStyles(props: props)
        
        // Apply button-specific props
        if let title = props["title"] as? String {
            print("🔤 Setting button title: \(title)")
            button.setTitle(title, for: .normal)
        }
        
        if let titleColor = props["titleColor"] as? String {
            print("🎨 Setting button title color: \(titleColor)")
            button.setTitleColor(ColorUtilities.color(fromHexString: titleColor), for: .normal)
        }
        
        // Font properties
        if let fontSize = props["fontSize"] as? CGFloat {
            var font = UIFont.systemFont(ofSize: fontSize)
            
            // Apply font weight if available
            if let fontWeight = props["fontWeight"] as? String {
                switch fontWeight {
                case "bold", "700":
                    font = UIFont.boldSystemFont(ofSize: fontSize)
                case "600":
                    font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
                case "500":
                    font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
                case "400", "normal", "regular":
                    font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
                case "300":
                    font = UIFont.systemFont(ofSize: fontSize, weight: .light)
                case "200":
                    font = UIFont.systemFont(ofSize: fontSize, weight: .thin)
                case "100":
                    font = UIFont.systemFont(ofSize: fontSize, weight: .ultraLight)
                default:
                    break
                }
            }
            
            // Apply font family if available
            if let fontFamily = props["fontFamily"] as? String {
                if let customFont = UIFont(name: fontFamily, size: fontSize) {
                    font = customFont
                }
            }
            
            button.titleLabel?.font = font
            print("📝 Setting button font: \(font)")
        }
        
        // Handle disabled state
        if let disabled = props["disabled"] as? Bool {
            button.isEnabled = !disabled
            
            // Apply disabled color if provided
            if disabled, let disabledColor = props["disabledColor"] as? String {
                button.setTitleColor(ColorUtilities.color(fromHexString: disabledColor), for: .disabled)
            }
        }
        
        // Padding inside button
        if let padding = props["padding"] as? CGFloat {
            button.contentEdgeInsets = UIEdgeInsets(
                top: padding, left: padding, bottom: padding, right: padding
            )
        } else {
            // Directional padding
            let top = props["paddingTop"] as? CGFloat ?? 0
            let left = props["paddingLeft"] as? CGFloat ?? 0
            let bottom = props["paddingBottom"] as? CGFloat ?? 0
            let right = props["paddingRight"] as? CGFloat ?? 0
            
            if top != 0 || left != 0 || bottom != 0 || right != 0 {
                button.contentEdgeInsets = UIEdgeInsets(
                    top: top, left: left, bottom: bottom, right: right
                )
            }
        }
        
        // Store active opacity for press animation
        if let activeOpacity = props["activeOpacity"] as? CGFloat {
            objc_setAssociatedObject(
                button,
                UnsafeRawPointer(bitPattern: "activeOpacity".hashValue)!,
                activeOpacity,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        return true
    }
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        view.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        guard let button = view as? UIButton else { return .zero }
        
        // Get button's intrinsic content size
        let contentSize = button.intrinsicContentSize
        
        // Account for content edge insets
        let width = contentSize.width + button.contentEdgeInsets.left + button.contentEdgeInsets.right
        let height = contentSize.height + button.contentEdgeInsets.top + button.contentEdgeInsets.bottom
        
        return CGSize(width: width, height: height)
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Set accessibility identifier for easier debugging
        view.accessibilityIdentifier = nodeId
    }
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let button = view as? UIButton else { return }
        
        // Use the parent implementation to store common event data
        (self as DCMauiComponent).addEventListeners(to: view, viewId: viewId, eventTypes: eventTypes, eventCallback: eventCallback)
        
        print("🔘 Adding event listeners to button \(viewId): \(eventTypes)")
        
        // Store the button-specific event handler in the static dictionary
        DCMauiButtonComponent.buttonEventHandlers[button] = (viewId, eventCallback)
        
        // Remove any existing targets to avoid duplicates
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        button.removeTarget(nil, action: nil, for: .touchDown)
        button.removeTarget(nil, action: nil, for: .touchUpOutside)
        button.removeTarget(nil, action: nil, for: .touchCancel)
        
        // UPDATED: Only accept events with "on" prefix
        for eventType in eventTypes {
            // Enforce "on" prefix convention - only handle onPress
            if eventType == "onPress" {
                // Add touch handlers
                button.addTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
                button.addTarget(self, action: #selector(handleButtonTouchDown(_:)), for: .touchDown)
                button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchUpInside)
                button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchUpOutside)
                button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchCancel)
                
                print("✅ Added \(eventType) event handler to button \(viewId)")
            }
        }
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let button = view as? UIButton else { return }
        
        // Remove from static handlers dictionary
        DCMauiButtonComponent.buttonEventHandlers.removeValue(forKey: button)
        
        // Remove all touch events
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        button.removeTarget(nil, action: nil, for: .touchDown)
        button.removeTarget(nil, action: nil, for: .touchUpOutside)
        button.removeTarget(nil, action: nil, for: .touchCancel)
        
        print("✅ Removed event listeners from button: \(viewId)")
        
        // Use the parent implementation to clean up common event data
        (self as DCMauiComponent).removeEventListeners(from: view, viewId: viewId, eventTypes: eventTypes)
    }
    
    // MARK: - Button Event Handlers
    
    @objc func handleButtonPress(_ sender: UIButton) {
        // Get the stored view ID and callback from the static dictionary
        guard let (viewId, callback) = DCMauiButtonComponent.buttonEventHandlers[sender] else {
            print("⚠️ Button press ignored: no handler registered")
            return
        }
        
        print("🔘 Button pressed: \(viewId)")
        
        // Include useful data for debugging
        let eventData: [String: Any] = [
            "pressed": true,
            "timestamp": Date().timeIntervalSince1970,
            "buttonTitle": sender.title(for: .normal) ?? "",
            "buttonTag": sender.tag
        ]
        
        // UPDATED: Always use onPress as the standard event name
        if let eventTypes = objc_getAssociatedObject(sender, 
                                                   UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!) as? [String],
           eventTypes.contains("onPress") {
            // Trigger the event using the standard onPress name
            callback(viewId, "onPress", eventData)
            print("📣 Triggered onPress event for button \(viewId)")
        }
    }
    
    @objc func handleButtonTouchDown(_ sender: UIButton) {
        if let activeOpacity = objc_getAssociatedObject(
            sender,
            UnsafeRawPointer(bitPattern: "activeOpacity".hashValue)!
        ) as? CGFloat {
            UIView.animate(withDuration: 0.15) {
                sender.alpha = activeOpacity
            }
        } else {
            UIView.animate(withDuration: 0.15) {
                sender.alpha = 0.7 // Default active opacity
            }
        }
    }
    
    @objc func handleButtonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15) {
            sender.alpha = 1.0
        }
    }
}
