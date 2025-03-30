import UIKit
import yoga

class DCMauiButtonComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    private static var buttonEventHandlers: [UIButton: (String, (String, String, [String: Any]) -> Void)] = [:]
    
    func createView(props: [String: Any]) -> UIView {
        // Create button
        let button = UIButton(type: .system)
        
        // Configure default properties
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        
        // Apply initial props
        updateView(button, withProps: props)
        
        return button
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let button = view as? UIButton else { return false }
        
        // Apply title
        if let title = props["title"] as? String {
            button.setTitle(title, for: .normal)
        }
        
        // Title color
        if let titleColor = props["titleColor"] as? String {
            button.setTitleColor(ColorUtilities.color(fromHexString: titleColor), for: .normal)
        }
        
        // Disabled state
        if let disabled = props["disabled"] as? Bool {
            button.isEnabled = !disabled
            
            if disabled, let disabledColor = props["disabledColor"] as? String {
                button.setTitleColor(ColorUtilities.color(fromHexString: disabledColor), for: .disabled)
            }
        }
        
        // Font properties
        var fontSize: CGFloat = 16.0
        if let size = props["fontSize"] as? CGFloat {
            fontSize = size
        } else if let size = props["fontSize"] as? Double {
            fontSize = CGFloat(size)
        }
        
        var fontWeight = UIFont.Weight.regular
        if let weight = props["fontWeight"] as? String {
            switch weight {
            case "bold": fontWeight = .bold
            case "100": fontWeight = .ultraLight
            case "200": fontWeight = .thin
            case "300": fontWeight = .light
            case "400": fontWeight = .regular
            case "500": fontWeight = .medium
            case "600": fontWeight = .semibold
            case "700": fontWeight = .bold
            case "800": fontWeight = .heavy
            case "900": fontWeight = .black
            default: fontWeight = .regular
            }
        }
        
        if let fontFamily = props["fontFamily"] as? String {
            if let customFont = UIFont(name: fontFamily, size: fontSize) {
                button.titleLabel?.font = customFont
            } else {
                button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
            }
        } else {
            button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
        
        // Active opacity for touch feedback
        if let activeOpacity = props["activeOpacity"] as? CGFloat {
            // Store for use in touch handlers
            objc_setAssociatedObject(
                button,
                UnsafeRawPointer(bitPattern: "activeOpacity".hashValue)!,
                activeOpacity,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        // Apply shared non-layout styling
        DCMauiLayoutManager.shared.applyStyles(to: button, props: props)
        
        return true
    }
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let button = view as? UIButton else { return }
        
        // Handle press event
        if eventTypes.contains("press") {
            // Remove existing targets to avoid duplicates
            button.removeTarget(nil, action: nil, for: .touchUpInside)
            
            // Add press handler
            button.addTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
            
            // Store callback and viewId for the event handler
            objc_setAssociatedObject(
                button,
                UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!,
                eventCallback,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            objc_setAssociatedObject(
                button,
                UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
                viewId,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            // Add touch down/up handlers for opacity feedback
            button.addTarget(self, action: #selector(handleButtonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchUpOutside)
            button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchCancel)
        }
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let button = view as? UIButton else { return }
        
        if eventTypes.contains("press") {
            button.removeTarget(nil, action: nil, for: .touchUpInside)
            button.removeTarget(nil, action: nil, for: .touchDown)
            button.removeTarget(nil, action: nil, for: .touchUpOutside)
            button.removeTarget(nil, action: nil, for: .touchCancel)
            
            // Clean up stored properties
            objc_setAssociatedObject(
                button,
                UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            objc_setAssociatedObject(
                button,
                UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    // MARK: - Button Event Handlers
    
    @objc private func handleButtonPress(_ sender: UIButton) {
        guard let callback = objc_getAssociatedObject(
            sender,
            UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!
        ) as? (String, String, [String: Any]) -> Void,
        let viewId = objc_getAssociatedObject(
            sender,
            UnsafeRawPointer(bitPattern: "viewId".hashValue)!
        ) as? String else {
            return
        }
        
        // Call the callback with the event data
        callback(viewId, "press", [:])
    }
    
    @objc private func handleButtonTouchDown(_ sender: UIButton) {
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
    
    @objc private func handleButtonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.15) {
            sender.alpha = 1.0
        }
    }
}
