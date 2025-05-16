import Flutter
import UIKit

/// Handles bridge method channel interactions between Flutter and native code
class DCMauiBridgeMethodChannel: NSObject {
    /// Singleton instance
    static let shared = DCMauiBridgeMethodChannel()
    
    /// Method channel for bridge operations
    var methodChannel: FlutterMethodChannel?
    
    /// Views dictionary for compatibility
    var views = [String: UIView]()
    
    func initialize() {
        print("🚀 Bridge channel initializing")
    }
    
    /// Initialize with Flutter binary messenger
    func initialize(with binaryMessenger: FlutterBinaryMessenger) {
        // Create method channel
        methodChannel = FlutterMethodChannel(
            name: "com.dcmaui.bridge",
            binaryMessenger: binaryMessenger
        )
        
        // Set up method handler
        methodChannel?.setMethodCallHandler(handleMethodCall)
        
        print("🌉 Bridge method channel initialized")
    }
    
    /// Handle method calls from Flutter
    func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("🔔 Bridge received method call: \(call.method)")
        
        // Get the arguments
        let args = call.arguments as? [String: Any]
        
        // Handle methods
        switch call.method {
        case "initialize":
            handleInitialize(result: result)
            
        case "createView":
            if let args = args {
                handleCreateView(args, result: result)
            } else {
                result(FlutterError(code: "ARGS_ERROR", message: "Arguments cannot be null", details: nil))
            }
            
        case "updateView":
            if let args = args {
                handleUpdateView(args, result: result)
            } else {
                result(FlutterError(code: "ARGS_ERROR", message: "Arguments cannot be null", details: nil))
            }
            
        case "deleteView":
            if let args = args {
                handleDeleteView(args, result: result)
            } else {
                result(FlutterError(code: "ARGS_ERROR", message: "Arguments cannot be null", details: nil))
            }
            
        case "attachView":
            if let args = args {
                handleAttachView(args, result: result)
            } else {
                result(FlutterError(code: "ARGS_ERROR", message: "Arguments cannot be null", details: nil))
            }
            
        case "detachView":
            if let args = args {
                handleDetachView(args, result: result)
            } else {
                result(FlutterError(code: "ARGS_ERROR", message: "Arguments cannot be null", details: nil))
            }
            
        case "setChildren":
            if let args = args {
                handleSetChildren(args, result: result)
            } else {
                result(FlutterError(code: "ARGS_ERROR", message: "Arguments cannot be null", details: nil))
            }
            
        case "commitBatchUpdate":
            if let args = args {
                handleCommitBatchUpdate(args, result: result)
            } else {
                result(FlutterError(code: "ARGS_ERROR", message: "Arguments cannot be null", details: nil))
            }
            
        // --- START NEW METHOD FOR COMPONENT LEVEL METHODS ---    
        case "callComponentMethod":
            if let args = args {
                handleCallComponentMethod(args, result: result)
            } else {
                result(FlutterError(code: "ARGS_ERROR", message: "Arguments cannot be null", details: nil))
            }
        // --- END NEW METHOD ---
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Initialize the bridge
    private func handleInitialize(result: @escaping FlutterResult) {
        print("🚀 Bridge initialize method called")
        
        // Execute on main thread
        DispatchQueue.main.async {
            // Initialize components and systems
            let success = DCMauiBridgeImpl.shared.initialize()
            print("🚀 Bridge initialization result: \(success)")
            result(success)
        }
    }
    
    // Create a view
    private func handleCreateView(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String,
              let viewType = args["viewType"] as? String,
              let props = args["props"] as? [String: Any] else {
            result(FlutterError(code: "CREATE_ERROR", message: "Invalid view creation parameters", details: nil))
            return
        }
        
        // Convert props to JSON
        guard let propsData = try? JSONSerialization.data(withJSONObject: props),
              let propsJson = String(data: propsData, encoding: .utf8) else {
            result(FlutterError(code: "JSON_ERROR", message: "Failed to serialize props", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            let success = DCMauiBridgeImpl.shared.createView(viewId: viewId, viewType: viewType, propsJson: propsJson)
            result(success)
        }
    }

    // Update a view
    private func handleUpdateView(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String,
              let props = args["props"] as? [String: Any] else {
            result(FlutterError(code: "UPDATE_ERROR", message: "Invalid view update parameters", details: nil))
            return
        }
        
        // Convert props to JSON
        guard let propsData = try? JSONSerialization.data(withJSONObject: props),
              let propsJson = String(data: propsData, encoding: .utf8) else {
            result(FlutterError(code: "JSON_ERROR", message: "Failed to serialize props", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            let success = DCMauiBridgeImpl.shared.updateView(viewId: viewId, propsJson: propsJson)
            result(success)
        }
    }
    
    // Delete a view
    private func handleDeleteView(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String else {
            result(FlutterError(code: "DELETE_ERROR", message: "Invalid view ID", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            let success = DCMauiBridgeImpl.shared.deleteView(viewId: viewId)
            result(success)
        }
    }
    
    // Detach a view (new method)
    private func handleDetachView(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String else {
            result(FlutterError(code: "DETACH_ERROR", message: "Invalid view ID", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            let success = DCMauiBridgeImpl.shared.detachView(childId: viewId)
            print("🔄 Detached view \(viewId) from parent: \(success)")
            result(success)
        }
    }
    
    // Attach a view to a parent
    private func handleAttachView(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let childId = args["childId"] as? String,
              let parentId = args["parentId"] as? String,
              let index = args["index"] as? Int else {
            result(FlutterError(code: "ATTACH_ERROR", message: "Invalid view attachment parameters", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            let success = DCMauiBridgeImpl.shared.attachView(childId: childId, parentId: parentId, index: index)
            result(success)
        }
    }
    
    // Set children for a view
    private func handleSetChildren(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String,
              let childrenIds = args["childrenIds"] as? [String] else {
            result(FlutterError(code: "CHILDREN_ERROR", message: "Invalid children parameters", details: nil))
            return
        }
        
        // Convert children to JSON
        guard let childrenData = try? JSONSerialization.data(withJSONObject: childrenIds),
              let childrenJson = String(data: childrenData, encoding: .utf8) else {
            result(FlutterError(code: "JSON_ERROR", message: "Failed to serialize children", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            let success = DCMauiBridgeImpl.shared.setChildren(viewId: viewId, childrenJson: childrenJson)
            result(success)
        }
    }
    
    // Handle batch updates
    private func handleCommitBatchUpdate(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let updates = args["updates"] as? [[String: Any]] else {
            result(FlutterError(code: "BATCH_ERROR", message: "Invalid batch update parameters", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            var allSucceeded = true
            
            for update in updates {
                if let operation = update["operation"] as? String {
                    switch operation {
                    case "createView":
                        if let viewId = update["viewId"] as? String,
                           let viewType = update["viewType"] as? String,
                           let props = update["props"] as? [String: Any],
                           let propsData = try? JSONSerialization.data(withJSONObject: props),
                           let propsJson = String(data: propsData, encoding: .utf8) {
                            let success = DCMauiBridgeImpl.shared.createView(viewId: viewId, viewType: viewType, propsJson: propsJson)
                            if !success {
                                allSucceeded = false
                            }
                        }
                    case "updateView":
                        if let viewId = update["viewId"] as? String,
                           let props = update["props"] as? [String: Any],
                           let propsData = try? JSONSerialization.data(withJSONObject: props),
                           let propsJson = String(data: propsData, encoding: .utf8) {
                            let success = DCMauiBridgeImpl.shared.updateView(viewId: viewId, propsJson: propsJson)
                            if !success {
                                allSucceeded = false
                            }
                        }
                    default:
                        print("Unknown batch operation: \(operation)")
                    }
                }
            }
            
            result(allSucceeded)
        }
    }
    
    // --- START NEW HANDLER ---
    // Handle calls to component-specific methods using protocol-based routing
    private func handleCallComponentMethod(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String,
              let methodName = args["methodName"] as? String,
              let methodArgs = args["args"] as? [String: Any] else {
            result(FlutterError(code: "ARGS_ERROR", message: "Invalid arguments for callComponentMethod. Required: viewId (String), methodName (String), args (Map)", details: args))
            return
        }

        print("📞 Received callComponentMethod: viewId=\(viewId), method=\(methodName), args=\(methodArgs)")

        // Execute on main thread
        DispatchQueue.main.async {
            // Try to find the view from multiple sources
            var view: UIView? = self.getViewById(viewId)
            
            // If view not found in main registry, try DCMauiBridgeImpl as backup
            if view == nil {
                view = DCMauiBridgeImpl.shared.views[viewId]
                
                // If found, update our registry
                if view != nil {
                    self.views[viewId] = view
                    print("🔄 View \(viewId) found in DCMauiBridgeImpl but not in bridge channel - synced")
                }
            }
            
            // Final check - view must exist
            guard let finalView = view else {
                print("❌ callComponentMethod: View not found with ID: \(viewId)")
                result(FlutterError(code: "VIEW_NOT_FOUND", message: "View not found", details: viewId))
                return
            }

            // Find the appropriate component for this view
            let viewClassName = String(describing: type(of: finalView))
            var componentInstance: DCFComponent? = nil
            var componentName: String = "unknown"
            
            // Try to find component based on view class name
            for (name, componentType) in DCFComponentRegistry.shared.componentTypes {
                let tempInstance = componentType.init()
                let tempView = tempInstance.createView(props: [:])
                
                if String(describing: type(of: tempView)) == viewClassName {
                    componentInstance = tempInstance
                    componentName = name
                    print("✅ Found component \(name) for view class: \(viewClassName)")
                    break
                }
            }
            
            guard let component = componentInstance else {
                print("❌ No component found for view class: \(viewClassName)")
                result(FlutterError(code: "COMPONENT_NOT_FOUND", message: "No component found for view type", details: viewClassName))
                return
            }
            
            // Use component method handler protocol if available
            if let methodHandler = component as? ComponentMethodHandler {
                let success = methodHandler.handleMethod(methodName: methodName, args: methodArgs, view: finalView)
                
                if success {
                    print("✅ Method \(methodName) successfully handled by \(componentName) component")
                    result(true)
                } else {
                    print("❌ Component \(componentName) failed to handle method \(methodName)")
                    result(FlutterError(code: "METHOD_FAILED", message: "Component failed to handle method", details: methodName))
                }
            } else {
                print("❌ Component \(componentName) does not implement ComponentMethodHandler protocol")
                result(FlutterError(code: "METHOD_NOT_SUPPORTED", message: "Component does not support method handling", details: componentName))
            }
        }
    }
    // --- END NEW HANDLER ---
    
    
    /// Helper to get a view by ID
    func getViewById(_ viewId: String) -> UIView? {
        // First try our local views dictionary
        if let view = views[viewId] {
            return view
        }
        
        // Then try DCMauiFFIBridge's views
        if let view = DCMauiBridgeImpl.shared.views[viewId] {
            return view
        }
        
        // Finally try ViewRegistry
        return ViewRegistry.shared.getView(id: viewId)
    }
}
