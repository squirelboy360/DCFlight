import UIKit
import yoga

class DCFButtonComponent: NSObject, DCFComponent {
    // Keep singleton instance to prevent deallocation when button targets are registered
    private static let sharedInstance = DCFButtonComponent()
    
    // Static storage for button handlers
    private static var buttonEventHandlers = [UIButton: (String, (String, String, [String: Any]) -> Void)]()
    
    // Store strong reference to self when buttons are registered
    private static var registeredButtons = [UIButton: DCFButtonComponent]()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Use custom button for better touch handling
        let button = CustomButton(type: .custom)
        
        // Make sure user interaction is explicitly enabled
        button.isUserInteractionEnabled = true
        
        // Apply props to the button directly
        _ = updateView(button, withProps: props)
        
        // Enable debug mode for this button in development
        #if DEBUG
        button._debugMode = true
        #endif
        
        print("🆕 Created button with props: \(props)")
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
        updateButtonContent(button, props: props)
        updateButtonAppearance(button, props: props)
        updateButtonState(button, props: props)
        
        return true
    }
    
    // Update the button's content (title)
    private func updateButtonContent(_ button: UIButton, props: [String: Any]) {
        if let title = props["title"] as? String {
            print("🔤 Setting button title: \(title)")
            button.setTitle(title, for: .normal)
        }
    }
    
    // Update the button's appearance (colors, fonts)
    private func updateButtonAppearance(_ button: UIButton, props: [String: Any]) {
        // Title color
        if let titleColor = props["titleColor"] as? String {
            print("🎨 Setting button title color: \(titleColor)")
            button.setTitleColor(ColorUtilities.color(fromHexString: titleColor), for: .normal)
        }
        
        // Font properties
        if let fontSize = props["fontSize"] as? CGFloat {
            var font = UIFont.systemFont(ofSize: fontSize)
            
            // Apply font weight if available
            if let fontWeight = props["fontWeight"] as? String {
                font = UIFont.systemFont(ofSize: fontSize, weight: fontWeightFromString(fontWeight))
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
        
        // Padding inside button
        updateButtonPadding(button, props: props)
    }
    
    // Update button padding
    private func updateButtonPadding(_ button: UIButton, props: [String: Any]) {
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
    }
    
    // Update button state (enabled/disabled)
    private func updateButtonState(_ button: UIButton, props: [String: Any]) {
        // Handle disabled state
        if let disabled = props["disabled"] as? Bool {
            button.isEnabled = !disabled
            
            // Apply disabled color if provided
            if disabled, let disabledColor = props["disabledColor"] as? String {
                button.setTitleColor(ColorUtilities.color(fromHexString: disabledColor), for: .disabled)
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
            print("❌ Cannot add event listeners to non-button view")
            return 
        }
        
        print("🔘 Adding event listeners to button \(viewId): \(eventTypes)")
        
        // Store event data with associated objects
        storeEventData(on: button, viewId: viewId, eventTypes: eventTypes, callback: eventCallback)
        
        // Remove any existing targets to avoid duplicates
        button.removeTarget(nil, action: nil, for: .touchUpInside)
        button.removeTarget(nil, action: nil, for: .touchDown)
        button.removeTarget(nil, action: nil, for: .touchUpOutside)
        button.removeTarget(nil, action: nil, for: .touchCancel)
        
        // Use sharedInstance to ensure the target isn't deallocated
        button.addTarget(DCFButtonComponent.sharedInstance, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
        button.addTarget(DCFButtonComponent.sharedInstance, action: #selector(handleButtonTouchDown(_:)), for: .touchDown)
        button.addTarget(DCFButtonComponent.sharedInstance, action: #selector(handleButtonTouchUp(_:)), for: .touchUpInside)
        button.addTarget(DCFButtonComponent.sharedInstance, action: #selector(handleButtonTouchUp(_:)), for: .touchUpOutside)
        button.addTarget(DCFButtonComponent.sharedInstance, action: #selector(handleButtonTouchUp(_:)), for: .touchCancel)
        
        // Store strong reference to component instance to prevent deallocation
        DCFButtonComponent.registeredButtons[button] = DCFButtonComponent.sharedInstance
        
        print("✅ Successfully added event handlers to button \(viewId)")
    }
    
    // Store event data using multiple methods for redundancy
    private func storeEventData(on button: UIButton, viewId: String, eventTypes: [String], 
                               callback: @escaping (String, String, [String: Any]) -> Void) {
        // Store the event information as associated objects
        objc_setAssociatedObject(
            button,
            UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
            viewId,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        objc_setAssociatedObject(
            button,
            UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!,
            eventTypes,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        objc_setAssociatedObject(
            button,
            UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!,
            callback,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        // Additional redundant storage
        objc_setAssociatedObject(
            button,
            UnsafeRawPointer(bitPattern: "buttonViewId".hashValue)!,
            viewId,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        objc_setAssociatedObject(
            button,
            UnsafeRawPointer(bitPattern: "buttonCallback".hashValue)!,
            callback,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        // Store in static dictionary as additional backup
        DCFButtonComponent.buttonEventHandlers[button] = (viewId, callback)
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let button = view as? UIButton else { return }
        
        // Clean up all references
        cleanupEventReferences(from: button, viewId: viewId)
        
        // Remove all touch events
        button.removeTarget(nil, action: nil, for: .allEvents)
        
        print("✅ Removed event listeners from button: \(viewId)")
    }
    
    // Helper to clean up all event references
    private func cleanupEventReferences(from button: UIButton, viewId: String) {
        // Remove from static handlers dictionary
        DCFButtonComponent.buttonEventHandlers.removeValue(forKey: button)
        DCFButtonComponent.registeredButtons.removeValue(forKey: button)
        
        // Clear all associated objects
        let keys = ["viewId", "eventTypes", "eventCallback", "buttonViewId", "buttonCallback"]
        for key in keys {
            objc_setAssociatedObject(
                button,
                UnsafeRawPointer(bitPattern: key.hashValue)!,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    // MARK: - Button Event Handlers
    
    @objc func handleButtonPress(_ sender: UIButton) {
        print("👆 BUTTON PRESS DETECTED")
        
        // Try to find handler using multiple backup methods
        if tryDirectHandling(sender) || tryStaticDictionaryHandling(sender) || tryAssociatedObjectHandling(sender) {
            print("✅ Button press successfully handled")
        } else {
            print("⚠️ Button press ignored: no handler registered")
        }
    }
    
    // Try direct handling via buttonViewId and buttonCallback
    private func tryDirectHandling(_ sender: UIButton) -> Bool {
        if let viewId = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "buttonViewId".hashValue)!) as? String,
           let callback = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "buttonCallback".hashValue)!) as? (String, String, [String: Any]) -> Void {
            
            print("🎯 Direct handler found for button: \(viewId)")
            
            // Prepare event data
            let eventData: [String: Any] = [
                "pressed": true,
                "timestamp": Date().timeIntervalSince1970,
                "buttonTitle": sender.title(for: .normal) ?? "",
                "direct": true
            ]
            
            // Invoke callback directly
            callback(viewId, "onPress", eventData)
            return true
        }
        return false
    }
    
    // Try handling via static dictionary
    private func tryStaticDictionaryHandling(_ sender: UIButton) -> Bool {
        if let (viewId, callback) = DCFButtonComponent.buttonEventHandlers[sender] {
            print("🔘 Button pressed via static dictionary: \(viewId)")
            
            callback(viewId, "onPress", [
                "pressed": true,
                "timestamp": Date().timeIntervalSince1970,
                "buttonTitle": sender.title(for: .normal) ?? "",
                "staticDict": true
            ])
            return true
        }
        return false
    }
    
    // Try handling via regular associated objects
    private func tryAssociatedObjectHandling(_ sender: UIButton) -> Bool {
        if let viewId = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String,
           let callback = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!) as? (String, String, [String: Any]) -> Void {
            
            print("🔍 Found event handler via associated objects for view \(viewId)")
            
            callback(viewId, "onPress", [
                "pressed": true,
                "timestamp": Date().timeIntervalSince1970,
                "buttonTitle": sender.title(for: .normal) ?? "",
                "emergency": true
            ])
            return true
        }
        return false
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

// Custom button class to ensure touch events are properly captured
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
        
        // Ensure touch area is sufficient
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    // Override hit testing to ensure touches are detected even with transparency
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if _debugMode {
            print("🔍 Hit test on button: \(point), bounds: \(self.bounds)")
        }
        
        // Expand the hit area slightly for better touch handling
        let hitTestInsets = UIEdgeInsets(top: -8, left: -8, bottom: -8, right: -8)
        let hitTestRect = bounds.inset(by: hitTestInsets)
        
        let result = hitTestRect.contains(point)
        if _debugMode && !result {
            print("❌ Point outside hit area")
        }
        return result
    }
    
    // Log touch events in debug mode
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if _debugMode {
            print("👇 Button touchesBegan")
        }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if _debugMode {
            print("👆 Button touchesEnded")
        }
        super.touchesEnded(touches, with: event)
    }
}
