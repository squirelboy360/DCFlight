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
        
        // Apply props to create the view
        _ = updateView(button, withProps: props)
        
        return button
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let button = view as? UIButton else { return false }
        
    
        view.applyStyles(props: props)
    
        applyButtonProps(button, props: props)
        
        return true
    }
    
    private func applyButtonProps(_ button: UIButton, props: [String: Any]) {
        // Button-specific properties (not styling)
        if let title = props["title"] as? String {
            button.setTitle(title, for: .normal)
        }
        
        if let titleColor = props["titleColor"] as? String {
            button.setTitleColor(ColorUtilities.color(fromHexString: titleColor), for: .normal)
        }
        
        if let fontSize = props["fontSize"] as? CGFloat {
            button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        if let fontWeight = props["fontWeight"] as? String {
            var font = button.titleLabel?.font ?? UIFont.systemFont(ofSize: button.titleLabel?.font?.pointSize ?? 17)
            
            switch fontWeight {
            case "bold", "700":
                font = UIFont.boldSystemFont(ofSize: font.pointSize)
            case "600":
                font = UIFont.systemFont(ofSize: font.pointSize, weight: .semibold)
            case "500":
                font = UIFont.systemFont(ofSize: font.pointSize, weight: .medium)
            case "400", "normal", "regular":
                font = UIFont.systemFont(ofSize: font.pointSize, weight: .regular)
            case "300":
                font = UIFont.systemFont(ofSize: font.pointSize, weight: .light)
            case "200":
                font = UIFont.systemFont(ofSize: font.pointSize, weight: .thin)
            case "100":
                font = UIFont.systemFont(ofSize: font.pointSize, weight: .ultraLight)
            default:
                break
            }
            
            button.titleLabel?.font = font
        }
        
        if let fontFamily = props["fontFamily"] as? String {
            if let font = UIFont(name: fontFamily, size: button.titleLabel?.font?.pointSize ?? 17) {
                button.titleLabel?.font = font
            }
        }
        
        if let disabled = props["disabled"] as? Bool {
            button.isEnabled = !disabled
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
