import UIKit
import yoga

class DCMauiButtonComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    
    // Static storage for button handlers
    private static var buttonEventHandlers: [UIButton: (String, (String, String, [String: Any]) -> Void)] = [:]
    
    func createView(props: [String: Any]) -> UIView {
        // FIXED: Use custom button instead of system button which has better touch handling
        let button = CustomButton(type: .custom)
        
        // CRITICAL FIX: Make sure user interaction is explicitly enabled (iOS sometimes disables it)
        button.isUserInteractionEnabled = true
        
        // Apply props to the button directly
        _ = updateView(button, withProps: props)
        
        // CRITICAL: Enable debug mode for this button
        button._debugMode = true
        
        NSLog("🆕 Created button with props: \(props)")
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
        guard let button = view as? UIButton else { 
            NSLog("❌ Cannot add event listeners to non-button view")
            return 
        }
        
        // Use the parent implementation to store common event data
        (self as DCMauiComponent).addEventListeners(to: view, viewId: viewId, eventTypes: eventTypes, eventCallback: eventCallback)
        
        // CRITICAL FIX: Log to console using NSLog for debugging with device logs
        NSLog("🔘 Adding event listeners to button \(viewId): \(eventTypes)")
        
        // CRITICAL: Store the callback and viewId directly on the button as associated objects
        objc_setAssociatedObject(
            button,
            UnsafeRawPointer(bitPattern: "buttonViewId".hashValue)!,
            viewId,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        objc_setAssociatedObject(
            button,
            UnsafeRawPointer(bitPattern: "buttonCallback".hashValue)!,
            eventCallback,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        // Store the button-specific event handler in the static dictionary as backup
        DCMauiButtonComponent.buttonEventHandlers[button] = (viewId, eventCallback)
        
        // Remove any existing targets to avoid duplicates
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        button.removeTarget(nil, action: nil, for: .touchDown)
        button.removeTarget(nil, action: nil, for: .touchUpOutside)
        button.removeTarget(nil, action: nil, for: .touchCancel)
        
        // CRITICAL FIX: Use strong reference to self to prevent deallocation of handler
        button.addTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(handleButtonTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchUpOutside)
        button.addTarget(self, action: #selector(handleButtonTouchUp(_:)), for: .touchCancel)
        
        NSLog("✅ Successfully added event handlers to button \(viewId)")
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
        NSLog("👆 BUTTON PRESS DETECTED")
        
        // CRITICAL FIX: Use associated object directly first as primary method
        if let viewId = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "buttonViewId".hashValue)!) as? String,
           let callback = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "buttonCallback".hashValue)!) as? (String, String, [String: Any]) -> Void {
            
            NSLog("🎯 Direct handler found for button: \(viewId)")
            
            // Prepare event data
            let eventData: [String: Any] = [
                "pressed": true,
                "timestamp": Date().timeIntervalSince1970,
                "buttonTitle": sender.title(for: .normal) ?? "",
                "direct": true
            ]
            
            // Invoke callback directly
            callback(viewId, "onPress", eventData)
            
            // Also send via coordinator for redundancy
            DispatchQueue.main.async {
                DCMauiEventMethodHandler.shared.sendEvent(
                    viewId: viewId,
                    eventName: "onPress",
                    eventData: eventData
                )
            }
            
            NSLog("📣 Event sent for button: \(viewId)")
            return
        }
        
        // Fallback to the static dictionary approach
        guard let (viewId, callback) = DCMauiButtonComponent.buttonEventHandlers[sender] else {
            NSLog("⚠️ Button press ignored: no handler registered")
            
            // CRITICAL FIX: Try to find the handler via associated objects as fallback
            if let viewId = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String,
               let callback = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!) as? (String, String, [String: Any]) -> Void {
                
                print("🔍 Found event handler via associated objects for view \(viewId)")
                
                // Trigger the onPress event
                callback(viewId, "onPress", [
                    "pressed": true,
                    "timestamp": Date().timeIntervalSince1970,
                    "buttonTitle": sender.title(for: .normal) ?? "",
                    "emergency": true // Flag to indicate fallback path was used
                ])
                return
            }
            
            return
        }
        
        NSLog("🔘 Button pressed: \(viewId)")
        
        // CRITICAL FIX: Always trigger onPress event regardless of registered types
        callback(viewId, "onPress", [
            "pressed": true,
            "timestamp": Date().timeIntervalSince1970,
            "buttonTitle": sender.title(for: .normal) ?? ""
        ])
        print("📣 Triggered onPress event for button \(viewId)")
        
        // CRITICAL FIX: Also send directly via method channel for redundancy
        DispatchQueue.main.async {
            DCMauiEventMethodHandler.shared.sendEvent(
                viewId: viewId,
                eventName: "onPress",
                eventData: [
                    "pressed": true, 
                    "timestamp": Date().timeIntervalSince1970,
                    "buttonTitle": sender.title(for: .normal) ?? "",
                    "direct": true
                ]
            )
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

// CRITICAL FIX: Add a custom button class to ensure touch events are properly captured
class CustomButton: UIButton {
    var _debugMode = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // Force user interaction to be enabled
        self.isUserInteractionEnabled = true
        
        // Make sure hit testing area is sufficient
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    // CRITICAL: Override hit testing to ensure button touches are detected even with transparency
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if _debugMode {
            NSLog("🔍 Hit test on button: \(point), bounds: \(self.bounds)")
        }
        
        // Expand the hit area slightly to make the button easier to tap
        let hitTestInsets = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
        let hitTestRect = bounds.inset(by: hitTestInsets)
        
        let result = hitTestRect.contains(point)
        if _debugMode && !result {
            NSLog("❌ Point outside hit area")
        }
        return result
    }
    
    // CRITICAL: Log touch events in debug mode
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if _debugMode {
            NSLog("👇 Button touchesBegan")
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if _debugMode {
            NSLog("👆 Button touchesEnded")
        }
        super.touchesEnded(touches, with: event)
    }
}
