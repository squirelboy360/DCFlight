import UIKit
import Flutter

/// Method channel handler for all event-related operations
class DCMauiEventMethodHandler: NSObject {
    // Singleton instance
    static let shared = DCMauiEventMethodHandler()
    
    // Method channel for event operations
    private(set) var methodChannel: FlutterMethodChannel?
    
    // Event callback closure type
    typealias EventCallback = (String, String, [String: Any]) -> Void
    
    // Store the event callback
    private var eventCallback: EventCallback?
    
    // Private initializer for singleton
    private override init() {
        super.init()
        // Setup will be done later when binary messenger is available
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
        print("📣 Sending event to Dart - viewId: \(viewId), eventName: \(eventName), data: \(eventData)")
        
        if let callback = self.eventCallback {
            // Use the stored callback if available
            callback(viewId, eventName, eventData)
            print("✅ Event sent via direct callback")
        } else if let channel = methodChannel {
            // Fall back to method channel
            print("📲 Sending event via method channel")
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
        
        // Execute on main thread
        DispatchQueue.main.async {
            // Register event listeners in native code
            let success = self.registerEventListeners(viewId: viewId, eventTypes: eventTypes)
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
        
        // Execute on main thread
        DispatchQueue.main.async {
            // Unregister event listeners in native code
            let success = self.unregisterEventListeners(viewId: viewId, eventTypes: eventTypes)
            result(success)
        }
    }
    
    // Helper method to register event listeners
    private func registerEventListeners(viewId: String, eventTypes: [String]) -> Bool {
        guard let view = ViewRegistry.shared.getView(id: viewId),
              let viewInfo = ViewRegistry.shared.getViewInfo(id: viewId) else {
            print("❌ Cannot register events: View not found with ID \(viewId)")
            return false
        }
        
        let componentType = viewInfo.type
        if let handlerType = DCMauiComponentRegistry.shared.getComponentType(for: componentType) {
            let handler = handlerType.init()
            handler.addEventListeners(to: view, viewId: viewId, eventTypes: eventTypes) { [weak self] (viewId, eventType, eventData) in
                print("🔔 Event triggered: \(eventType) for view \(viewId)")
                self?.sendEvent(viewId: viewId, eventName: eventType, eventData: eventData)
            }
            print("✅ Successfully registered events for view \(viewId): \(eventTypes)")
            return true
        }
        
        print("❌ Failed to register events: No component handler for type \(componentType)")
        return false
    }
    
    // Helper method to unregister event listeners
    private func unregisterEventListeners(viewId: String, eventTypes: [String]) -> Bool {
        guard let view = ViewRegistry.shared.getView(id: viewId),
              let viewInfo = ViewRegistry.shared.getViewInfo(id: viewId) else {
            print("❌ Cannot unregister events: View not found with ID \(viewId)")
            return false
        }
        
        let componentType = viewInfo.type
        if let handlerType = DCMauiComponentRegistry.shared.getComponentType(for: componentType) {
            let handler = handlerType.init()
            handler.removeEventListeners(from: view, viewId: viewId, eventTypes: eventTypes)
            print("✅ Successfully unregistered events for view \(viewId): \(eventTypes)")
            return true
        }
        
        print("❌ Failed to unregister events: No component handler for type \(componentType)")
        return false
    }
}
