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
            
        case "setChildren":
            if let args = args {
                handleSetChildren(args, result: result)
            } else {
                result(FlutterError(code: "ARGS_ERROR", message: "Arguments cannot be null", details: nil))
            }
            
        case "viewExists":
            if let args = args {
                handleViewExists(args, result: result)
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
    // Handle calls to component-specific methods
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

            // Handle methods based on view type
            var success = false
            var errorMessage: String? = nil

            // --- ScrollView Methods ---
            if let scrollView = finalView as? UIScrollView {
                let component = DCFScrollViewComponent() // Use a temporary instance to access methods
                
                print("✅ Found ScrollView for method: \(methodName)")
                
                if methodName == "scrollTo" {
                    component.scrollTo(view: scrollView, args: methodArgs)
                    success = true
                    print("✅ Executed scrollTo with args: \(methodArgs)")
                } 
                else if methodName == "scrollToEnd" {
                    component.scrollToEnd(view: scrollView, args: methodArgs)
                    success = true
                    print("✅ Executed scrollToEnd with args: \(methodArgs)")
                }
                else if methodName == "flashScrollIndicators" {
                    component.flashScrollIndicators(view: scrollView, args: methodArgs)
                    success = true
                    print("✅ Executed flashScrollIndicators")
                }
                else {
                    errorMessage = "Method '\(methodName)' not supported for ScrollView"
                }
            }
            // --- Add handling for other component types here ---
            else {
                errorMessage = "Component type '\(type(of: finalView))' does not support method calls or method '\(methodName)' is unknown."
                print("⚠️ Unsupported component type: \(type(of: finalView)) for method: \(methodName)")
            }

            // Return result
            if success {
                print("✅ callComponentMethod successful for \(viewId).\(methodName)")
                result(true)
            } else {
                print("❌ callComponentMethod failed: \(errorMessage ?? "Unknown error")")
                result(FlutterError(code: "METHOD_EXECUTION_FAILED", message: errorMessage ?? "Failed to execute method", details: methodName))
            }
        }
    }
    // --- END NEW HANDLER ---
    
    // Check if a view exists
    private func handleViewExists(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String else {
            result(FlutterError(code: "VIEW_EXISTS_ERROR", message: "Invalid view ID", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            let exists = DCMauiBridgeImpl.shared.viewExists(viewId: viewId)
            result(exists)
        }
    }
    
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
