import UIKit
import yoga

class DCMauiButtonComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        print("🔵 Creating button with props: \(props)")
        
        // Create button with custom type
        let button = UIButton(type: .system)
        
        // CRITICAL FIX: Set default background color for visibility
        button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
        
        // CRITICAL FIX: Make sure button has enough size to be visible
        button.frame = CGRect(x: 0, y: 0, width: 120, height: 44)
        
        // CRITICAL FIX: Set default title for visibility if not provided
        button.setTitle(props["title"] as? String ?? "Button", for: .normal)
        
        // CRITICAL FIX: Set default title color for visibility
        button.setTitleColor(.white, for: .normal)
        
        // CRITICAL FIX: Apply default corner radius for modern look
        button.layer.cornerRadius = 8.0
        
        // Apply props to create the view
        _ = updateView(button, withProps: props)
        
        // CRITICAL FIX: Log button creation for debugging
        print("🔵 Button created: \(button), frame: \(button.frame), background: \(String(describing: button.backgroundColor))")
        
        return button
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let button = view as? UIButton else { 
            print("❌ Failed to update button - wrong view type: \(type(of: view))")
            return false 
        }
        
        print("🔄 Updating button with props: \(props)")
        
        // Apply general styles
        view.applyStyles(props: props)
        
        // Apply button-specific props
        applyButtonProps(button, props: props)
        
        // CRITICAL FIX: Make sure button appearance is updated
        button.setNeedsDisplay()
        
        return true
    }
    
    private func applyButtonProps(_ button: UIButton, props: [String: Any]) {
        // Button-specific properties (not styling)
        if let title = props["title"] as? String {
            button.setTitle(title, for: .normal)
            print("🔠 Setting button title: \(title)")
        }
        
        // CRITICAL FIX: Handle titleColor more robustly
        if let titleColor = props["titleColor"] {
            if let colorString = titleColor as? String {
                button.setTitleColor(ColorUtilities.color(fromHexString: colorString), for: .normal)
                print("🎨 Setting button title color from string: \(colorString)")
            } else if let colorObj = titleColor as? UIColor {
                button.setTitleColor(colorObj, for: .normal)
                print("🎨 Setting button title color from object")
            }
        } else {
            // Default to contrasting color based on background
            if let bgColor = button.backgroundColor {
                let isDark = bgColor.isDark
                button.setTitleColor(isDark ? .white : .black, for: .normal)
                print("🎨 Setting default contrasting title color: \(isDark ? "white" : "black")")
            } else {
                // Fall back to system color if no background
                button.setTitleColor(.white, for: .normal)
            }
        }
        
        // CRITICAL FIX: Set default background color if none is specified
        if button.backgroundColor == nil || button.backgroundColor == .clear {
            button.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 1.0)
            print("🎨 Setting default button background color")
        }
        
        if let fontSize = props["fontSize"] as? CGFloat {
            button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            print("📏 Setting button font size: \(fontSize)")
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
            print("📝 Setting button font weight: \(fontWeight)")
        }
        
        if let fontFamily = props["fontFamily"] as? String {
            if let font = UIFont(name: fontFamily, size: button.titleLabel?.font?.pointSize ?? 17) {
                button.titleLabel?.font = font
                print("📝 Setting button font family: \(fontFamily)")
            }
        }
        
        if let disabled = props["disabled"] as? Bool {
            button.isEnabled = !disabled
            print("🔘 Setting button enabled: \(!disabled)")
        }
        
        // Store active opacity for press animation
        if let activeOpacity = props["activeOpacity"] as? CGFloat {
            objc_setAssociatedObject(
                button,
                UnsafeRawPointer(bitPattern: "activeOpacity".hashValue)!,
                activeOpacity,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            print("⚙️ Setting button active opacity: \(activeOpacity)")
        }
        
        // CRITICAL FIX: Apply additional touch area if needed
        if let touchAreaInsets = props["touchAreaInsets"] as? [String: CGFloat] {
            let top = touchAreaInsets["top"] ?? 0
            let left = touchAreaInsets["left"] ?? 0
            let bottom = touchAreaInsets["bottom"] ?? 0
            let right = touchAreaInsets["right"] ?? 0
            
            button.contentEdgeInsets = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
            print("📲 Setting button touch area insets: \(button.contentEdgeInsets)")
        } else {
            // CRITICAL FIX: Add default padding for better touchability
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        }
    }
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // Store the common event data using the protocol extension's implementation
        (self as DCMauiComponent).addEventListeners(to: view, viewId: viewId, eventTypes: eventTypes, eventCallback: eventCallback)
        
        guard let button = view as? UIButton else { 
            print("❌ Failed to add event listener - not a button: \(type(of: view))")
            return 
        }
        
        print("🎯 Adding event listeners to button \(viewId): \(eventTypes)")
        
        // CRITICAL FIX: Add property for direct access to event callback
        objc_setAssociatedObject(
            button,
            UnsafeRawPointer(bitPattern: "onPressCallback".hashValue)!,
            eventCallback,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        // Handle specific events
        if eventTypes.contains("press") || eventTypes.contains("onPress") {
            // Remove existing targets to avoid duplicates
            button.removeTarget(nil, action: nil, for: .touchUpInside)
            
            // CRITICAL FIX: Add press handler with strong reference
            button.addTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
            
            // CRITICAL FIX: Store reference to self on the button to prevent deallocation
            objc_setAssociatedObject(
                button,
                UnsafeRawPointer(bitPattern: "componentHandler".hashValue)!,
                self,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            // Add touch down/up handlers for opacity feedback
            button.addTarget(self, action: #selector(handleButtonTouchDown(_:)), for: .touchDown)
            button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchUpInside)
            button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchUpOutside)
            button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchCancel)
            
            print("✅ Button press handler added for viewId: \(viewId)")
        }
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let button = view as? UIButton else { return }
        
        if eventTypes.contains("press") || eventTypes.contains("onPress") {
            button.removeTarget(nil, action: nil, for: .touchUpInside)
            button.removeTarget(nil, action: nil, for: .touchDown)
            button.removeTarget(nil, action: nil, for: .touchUpOutside)
            button.removeTarget(nil, action: nil, for: .touchCancel)
            
            // Remove stored component reference
            objc_setAssociatedObject(
                button,
                UnsafeRawPointer(bitPattern: "componentHandler".hashValue)!,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            print("🚫 Removed button event listeners for viewId: \(viewId)")
        }
        
        // Call the protocol extension's implementation
        (self as DCMauiComponent).removeEventListeners(from: view, viewId: viewId, eventTypes: eventTypes)
    }
    
    // MARK: - Button Event Handlers
    
    @objc private func handleButtonPress(_ sender: UIButton) {
        print("👆 Button pressed!")
        
        // CRITICAL FIX: Try both direct callback and generic one
        if let viewId = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String,
           let callback = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "onPressCallback".hashValue)!) as? (String, String, [String: Any]) -> Void {
            
            print("📣 Triggering press event for button \(viewId) with direct callback")
            callback(viewId, "press", [:])
            
            // Also try "onPress" for compatibility
            callback(viewId, "onPress", [:])
        } else {
            // Fall back to generic event triggering
            print("📣 Triggering press event with generic method")
            triggerEvent(on: sender, eventType: "press")
            
            // Also trigger "onPress" for compatibility
            triggerEvent(on: sender, eventType: "onPress")
        }
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

// CRITICAL FIX: Helper extension to determine if a color is dark or light
extension UIColor {
    var isDark: Bool {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate perceived brightness
        let brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
        return brightness < 0.5
    }
}
