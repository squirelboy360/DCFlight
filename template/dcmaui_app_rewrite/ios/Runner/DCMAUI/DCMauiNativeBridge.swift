import Flutter
import UIKit
import yoga

@objc public class DCMauiNativeBridge: NSObject {
    // Singleton instance
    @objc public static let shared = DCMauiNativeBridge()
    
    // View registry to keep track of created views
    private var viewRegistry = [String: (view: UIView, componentType: String)]()
    
    // Root view for all DCMAUI components
    private var rootView: UIView?
    
    // Flutter method channel for event handling
    private var eventChannel: FlutterMethodChannel?
    
    // Local event callback for debugging
    private var eventCallback: ((String, String, [String: Any]) -> Void)?
    
    private override init() {
        super.init()
    }
    
    // Setup method channel for event handling
    func setupEventChannel(binaryMessenger: FlutterBinaryMessenger) {
        self.eventChannel = FlutterMethodChannel(name: "com.dcmaui.events", binaryMessenger: binaryMessenger)
        
        // Register method handlers for direct event registration without FFI
        self.eventChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", message: "Bridge not available", details: nil))
                return
            }
            
            switch call.method {
            case "registerEvents":
                // Direct event registration - NO FFI FALLBACK
                if let args = call.arguments as? [String: Any],
                   let viewId = args["viewId"] as? String,
                   let eventTypes = args["eventTypes"] as? [String] {
                    
                    print("🚀 DIRECT EVENT REGISTRATION: \(viewId) for events: \(eventTypes)")
                    
                    // Lookup the view and component
                    if let viewInfo = self.viewRegistry[viewId] {
                        let view = viewInfo.view
                        let componentType = viewInfo.componentType
                        
                        // Get the component handler and register events
                        if let handler = DCMauiComponentRegistry.shared.getComponentType(for: componentType) {
                            handler.addEventListeners(to: view, viewId: viewId, eventTypes: eventTypes) { [weak self] vId, evType, evData in
                                self?.sendEventToDart(viewId: vId, eventName: evType, eventData: evData)
                            }
                            result(true)
                            return
                        }
                    }
                }
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments or view not found", details: nil))
                
            case "unregisterEvents":
                // Direct event unregistration - NO FFI FALLBACK
                if let args = call.arguments as? [String: Any],
                   let viewId = args["viewId"] as? String,
                   let eventTypes = args["eventTypes"] as? [String] {
                    
                    print("🚀 DIRECT EVENT UNREGISTRATION: \(viewId) for events: \(eventTypes)")
                    
                    // Lookup the view and component
                    if let viewInfo = self.viewRegistry[viewId] {
                        let view = viewInfo.view
                        let componentType = viewInfo.componentType
                        
                        // Get the component handler and unregister events
                        if let handler = DCMauiComponentRegistry.shared.getComponentType(for: componentType) {
                            handler.removeEventListeners(from: view, viewId: viewId, eventTypes: eventTypes)
                            result(true)
                            return
                        }
                    }
                }
                result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments or view not found", details: nil))
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        print("⚡️ Method channel for events initialized - ALL EVENT HANDLING IS NOW DIRECT")
    }
    
    // Called by FFI to initialize the native bridge
    @objc public func dcmaui_initialize() -> Int8 {
        print("DCMauiNativeBridge: initialize() called from FFI")
        // Set up any necessary initialization
        return 1
    }
    
    // Create a view with the given ID, type and properties
    @objc public func dcmaui_create_view(_ viewId: UnsafePointer<CChar>, 
                                      _ type: UnsafePointer<CChar>,
                                      _ propsJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let typeString = String(cString: type)
        let propsString = String(cString: propsJson)
        
        print("DCMauiNativeBridge: Creating view - ID: \(viewIdString), Type: \(typeString)")
        
        // Parse props JSON
        guard let propsData = propsString.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData) as? [String: Any] else {
            print("DCMauiNativeBridge: Failed to parse props JSON")
            return 0
        }
        
        // Get the component type from registry
        guard let componentType = DCMauiComponentRegistry.shared.getComponentType(for: typeString) else {
            print("DCMauiNativeBridge: Unsupported component type: \(typeString)")
            return 0
        }
        
        // Create the view using the component
        let view = componentType.createView(props: props)
        
        // Store in registry with component type info
        viewRegistry[viewIdString] = (view, typeString)
        
        print("DCMauiNativeBridge: View created successfully: \(viewIdString)")
        return 1
    }
    
    // Update a view's properties - now uses the stored component type
    @objc public func dcmaui_update_view(_ viewId: UnsafePointer<CChar>,
                                      _ propsJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let propsString = String(cString: propsJson)
        
        // Parse props JSON
        guard let propsData = propsString.data(using: .utf8),
              let props = try? JSONSerialization.jsonObject(with: propsData) as? [String: Any],
              let viewInfo = viewRegistry[viewIdString] else {
            return 0
        }
        
        // Get component handler by the registered type and update
        let view = viewInfo.view
        let componentType = viewInfo.componentType
        
        if let handler = DCMauiComponentRegistry.shared.getComponentType(for: componentType) {
            handler.updateView(view, props: props)
            return 1
        }
        
        return 0
    }
    
    // Delete a view
    @objc public func dcmaui_delete_view(_ viewId: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        
        guard let view = viewRegistry[viewIdString]?.view else {
            return 0
        }
        
        // Remove from parent view
        view.removeFromSuperview()
        
        // Clean up Yoga node
        DCMauiLayoutManager.shared.cleanUpYogaNode(for: view)
        
        // Remove from registry
        viewRegistry.removeValue(forKey: viewIdString)
        
        return 1
    }
    
    // Attach a child view to a parent view
    @objc public func dcmaui_attach_view(_ childId: UnsafePointer<CChar>,
                                      _ parentId: UnsafePointer<CChar>,
                                      _ index: Int32) -> Int8 {
        let childIdString = String(cString: childId)
        let parentIdString = String(cString: parentId)
        
        guard let childInfo = viewRegistry[childIdString],
              let parentInfo = viewRegistry[parentIdString] else {
            print("Failed to find child or parent view: \(childIdString) -> \(parentIdString)")
            return 0
        }
        
        let childView = childInfo.view
        let parentView = parentInfo.view
        
        // Add child to parent
        parentView.addSubview(childView)
        
        // Log the views for debugging
        print("Attaching view \(childIdString) (\(childInfo.componentType)) to parent \(parentIdString)")
        
        // Set up Yoga nodes for layout
        let layoutManager = DCMauiLayoutManager.shared
        
        // Connect Yoga nodes between parent and child
        layoutManager.connectNodes(parent: parentView, child: childView, atIndex: Int(index))
        
        // Calculate and apply layout if parent has fixed dimensions
        if parentView.frame.width > 0 && parentView.frame.height > 0 {
            layoutManager.calculateAndApplyLayout(
                for: parentView,
                width: parentView.frame.width,
                height: parentView.frame.height
            )
        }
        
        return 1
    }
    
    // Set children for a view
    @objc public func dcmaui_set_children(_ viewId: UnsafePointer<CChar>,
                                       _ childrenJson: UnsafePointer<CChar>) -> Int8 {
        let viewIdString = String(cString: viewId)
        let childrenString = String(cString: childrenJson)
        
        guard let childrenData = childrenString.data(using: .utf8),
              let childrenIds = try? JSONSerialization.jsonObject(with: childrenData) as? [String],
              let parentView = viewRegistry[viewIdString]?.view else {
            return 0
        }
        
        // Set z-order of children based on array order
        for (index, childId) in childrenIds.enumerated() {
            if let childView = viewRegistry[childId]?.view {
                parentView.insertSubview(childView, at: index)
            }
        }
        
        return 1
    }
    
    // Set the event callback function
    func setEventCallback(_ callback: @escaping (String, String, [String: Any]) -> Void) {
        self.eventCallback = callback
    }

    // Send events to Dart using method channel
    func sendEventToDart(viewId: String, eventName: String, eventData: [String: Any]) {
        // Create event data once
        let event: [String: Any] = [
            "viewId": viewId,
            "eventType": eventName,
            "eventData": eventData
        ]
        

            self.eventChannel?.invokeMethod("onEvent", arguments: event)
        // Local callback is only for debugging and optional
        if let callback = self.eventCallback {
                callback(viewId, eventName, eventData)
            }
    }

    // Method for direct view setup without going through C layer
    func manuallyCreateRootView(_ view: UIView, viewId: String, props: [String: Any]) {
        // Create the appropriate component type (assuming View)
        if let componentType = DCMauiComponentRegistry.shared.getComponentType(for: "View") {
            componentType.updateView(view, props: props)
            
            // Store in registry
            viewRegistry[viewId] = (view, "View")
            
            print("Root view manually created with ID: \(viewId)")
        }
    }
}
