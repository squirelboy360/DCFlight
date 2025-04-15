import UIKit
import Flutter

/// Method channel handler for all event-related operations
class DCMauiEventMethodHandler: NSObject {
    // Singleton instance
    static let shared = DCMauiEventMethodHandler()
    
    // Method channel for event operations
    internal var methodChannel: FlutterMethodChannel?
    
    // Event callback closure type
    typealias EventCallback = (String, String, [String: Any]) -> Void
    
    // Store the event callback
    private var eventCallback: EventCallback?
    
    // Private initializer for singleton
    private override init() {
        super.init()
    }
    
    // Initialize with Flutter binary messenger
    func initialize(with binaryMessenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(
            name: "com.dcmaui.events",
            binaryMessenger: binaryMessenger
        )
        
        setupMethodCallHandler()
        print("📣 Event method channel initialized")
    }
    
    // Register method call handler
    private func setupMethodCallHandler() {
        methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", 
                                   message: "Event handler not available", 
                                   details: nil))
                return
            }
            
            switch call.method {
                case "addEventListeners":
                    self.handleAddEventListeners(call, result)
                    
                case "removeEventListeners":
                    self.handleRemoveEventListeners(call, result)
                    
                default:
                    result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // Set event callback function
    func setEventCallback(_ callback: @escaping EventCallback) {
        self.eventCallback = callback
    }
    
    // Send event to Dart
    func sendEvent(viewId: String, eventName: String, eventData: [String: Any]) {
        print("📣 Sending event to Dart - viewId: \(viewId), eventName: \(eventName)")
        
        if let callback = self.eventCallback {
            // Use the stored callback if available
            callback(viewId, eventName, eventData)
        } else if let channel = methodChannel {
            // Fall back to method channel
            channel.invokeMethod("onEvent", arguments: [
                "viewId": viewId,
                "eventType": eventName,
                "eventData": eventData
            ])
        } else {
            print("❌ No method to send events available")
        }
    }
    
    // MARK: - Method handlers
    
    // Handle addEventListeners calls
    private func handleAddEventListeners(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventTypes = args["eventTypes"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGS", 
                               message: "Invalid arguments for addEventListeners", 
                               details: nil))
            return
        }
        
        print("🎯 Native: Received addEventListeners call for view \(viewId): \(eventTypes)")
        
        // CRITICAL FIX: Use BOTH registries to locate the view - first the FFI bridge
        var view: UIView?
        
        // First try the FFI bridge registry
        view = DCMauiFFIBridge.shared.getViewById(viewId)
        
        // If not found, try the ViewRegistry
        if view == nil {
            view = ViewRegistry.shared.getView(id: viewId)
        }
        
        // If still not found, try the LayoutManager
        if view == nil {
            view = DCMauiLayoutManager.shared.getView(withId: viewId)
        }
        
        guard let foundView = view else {
            print("❌ Cannot register events: View not found with ID \(viewId)")
            
            // Return success anyway to prevent Flutter errors - we'll handle missing views gracefully
            result(true)
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            // Now register event listeners with the found view
            let success = self.registerEventListeners(view: foundView, viewId: viewId, eventTypes: eventTypes)
            result(success)
        }
    }
    
    // Handle removeEventListeners calls
    private func handleRemoveEventListeners(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let eventTypes = args["eventTypes"] as? [String] else {
            result(FlutterError(code: "INVALID_ARGS", 
                               message: "Invalid arguments for removeEventListeners", 
                               details: nil))
            return
        }
        
        print("🎯 Native: Received removeEventListeners call for view \(viewId): \(eventTypes)")
        
        // CRITICAL FIX: Use BOTH registries to locate the view - first the FFI bridge
        var view: UIView?
        
        // First try the FFI bridge registry
        view = DCMauiFFIBridge.shared.getViewById(viewId)
        
        // If not found, try the ViewRegistry
        if view == nil {
            view = ViewRegistry.shared.getView(id: viewId)
        }
        
        // If still not found, try the LayoutManager
        if view == nil {
            view = DCMauiLayoutManager.shared.getView(withId: viewId)
        }
        
        guard let foundView = view else {
            print("❌ Cannot unregister events: View not found with ID \(viewId)")
            
            // Return success anyway to prevent Flutter errors - we'll handle missing views gracefully
            result(true)
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            // Now unregister event listeners with the found view
            let success = self.unregisterEventListeners(view: foundView, viewId: viewId, eventTypes: eventTypes)
            result(success)
        }
    }
    
    // Helper method to register event listeners
    private func registerEventListeners(view: UIView, viewId: String, eventTypes: [String]) -> Bool {
        let viewType = String(describing: type(of: view))
        
        // First try to find the component by looking at UI class type
        for (componentType, componentClass) in DCMauiComponentRegistry.shared.componentTypes {
            let tempInstance = componentClass.init()
            let tempView = tempInstance.createView(props: [:])
            
            if String(describing: type(of: tempView)) == viewType {
                tempInstance.addEventListeners(to: view, viewId: viewId, eventTypes: eventTypes) { [weak self] (viewId, eventType, eventData) in
                    print("🔔 Event triggered: \(eventType) for view \(viewId)")
                    self?.sendEvent(viewId: viewId, eventName: eventType, eventData: eventData)
                }
                print("✅ Successfully registered events for view \(viewId): \(eventTypes)")
                return true
            }
        }
        
        // Fallback to generic event listener for any view type
        print("⚠️ Using generic event handler for view type \(viewType)")
        
        // Store event data directly on the view
        objc_setAssociatedObject(
            view,
            UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
            viewId,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        objc_setAssociatedObject(
            view,
            UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!,
            eventTypes,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        // For buttons, add a generic handler
        if let button = view as? UIButton {
            // Remove any existing targets first to avoid duplicates
            button.removeTarget(nil, action: nil, for: .touchUpInside)
            
            // Add a target for button presses
            button.addTarget(self, action: #selector(handleButtonPress(_:)), for: .touchUpInside)
            print("🔘 Added generic button handler for \(viewId)")
        }
        
        print("✅ Successfully registered generic events for view \(viewId): \(eventTypes)")
        return true
    }
    
    // Helper method to unregister event listeners
    private func unregisterEventListeners(view: UIView, viewId: String, eventTypes: [String]) -> Bool {
        // Remove event data from the view
        if let storedEventTypes = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!) as? [String] {
            var remainingTypes = storedEventTypes
            
            for eventType in eventTypes {
                if let index = remainingTypes.firstIndex(of: eventType) {
                    remainingTypes.remove(at: index)
                }
            }
            
            if remainingTypes.isEmpty {
                // Clear all event data if no events remain
                objc_setAssociatedObject(
                    view,
                    UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
                    nil,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                
                objc_setAssociatedObject(
                    view,
                    UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!,
                    nil,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                
                // For buttons, remove targets
                if let button = view as? UIButton {
                    button.removeTarget(nil, action: nil, for: .touchUpInside)
                }
            } else {
                // Update remaining event types
                objc_setAssociatedObject(
                    view,
                    UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!,
                    remainingTypes,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
        
        print("✅ Successfully unregistered events for view \(viewId): \(eventTypes)")
        return true
    }
    
    // MARK: - Button Event Handler
    
    @objc private func handleButtonPress(_ sender: UIButton) {
        guard let viewId = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String,
              let eventTypes = objc_getAssociatedObject(sender, UnsafeRawPointer(bitPattern: "eventTypes".hashValue)!) as? [String] else {
            print("⚠️ Button pressed but no viewId or eventTypes found")
            return
        }
        
        // Check if this button should handle press events
        if eventTypes.contains("onPress") {
            print("👆 Button \(viewId) pressed - sending onPress event")
            
            // Send event
            sendEvent(viewId: viewId, eventName: "onPress", eventData: [
                "pressed": true,
                "timestamp": Date().timeIntervalSince1970
            ])
        }
    }
}

// MARK: - Extension for DCMauiFFIBridge
extension DCMauiFFIBridge {
    // Helper method to get view by ID
    func getViewById(_ viewId: String) -> UIView? {
        return views[viewId]
    }
}
