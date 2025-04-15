import Flutter
import UIKit

/// Handles bridge method channel interactions between Flutter and native code
class DCMauiBridgeMethodChannel: NSObject {
    /// Singleton instance
    static let shared = DCMauiBridgeMethodChannel()
    
    /// Method channel for bridge operations
    var methodChannel: FlutterMethodChannel?
    
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
    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Get the arguments
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "ARGS_ERROR", message: "Arguments cannot be null", details: nil))
            return
        }
        
        // Handle methods
        switch call.method {
        case "initialize":
            handleInitialize(result: result)
            
        case "createView":
            handleCreateView(args, result: result)
            
        case "updateView":
            handleUpdateView(args, result: result)
            
        case "deleteView":
            handleDeleteView(args, result: result)
            
        case "attachView":
            handleAttachView(args, result: result)
            
        case "setChildren":
            handleSetChildren(args, result: result)
            
        case "commitBatchUpdate":
            handleCommitBatchUpdate(args, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Initialize the bridge
    private func handleInitialize(result: @escaping FlutterResult) {
        // Execute on main thread
        DispatchQueue.main.async {
            // Initialize components and systems
            let success = true
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
        
        // Execute on main thread
        DispatchQueue.main.async {
            // Get the component type from registry
            guard let componentType = DCMauiComponentRegistry.shared.getComponentType(for: viewType) else {
                print("DCMauiNativeBridge: Unknown component type: \(viewType)")
                result(false)
                return
            }
            
            // Create an instance of the component type
            let component = componentType.init()
            
            // Create the view using the component
            let view = component.createView(props: props)
            
            // Register the view
            ViewRegistry.shared.registerView(view, id: viewId, type: viewType)
            
            // Create node in shadow tree
            YogaShadowTree.shared.createNode(id: viewId, componentType: viewType)
            
            // Register with layout manager
            DCMauiLayoutManager.shared.registerView(view, withId: viewId)
            
            // Apply initial layout props
            let layoutProps = props.filter { SupportedLayoutsProps.supportedLayoutProps.contains($0.key) }
            if (!layoutProps.isEmpty) {
                DCMauiLayoutManager.shared.updateNodeWithLayoutProps(
                    nodeId: viewId,
                    componentType: viewType,
                    props: layoutProps
                )
            }
            
            print("View created successfully via method channel: \(viewId)")
            result(true)
        }
    }
    
    // Update a view
    private func handleUpdateView(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String,
              let props = args["props"] as? [String: Any] else {
            result(FlutterError(code: "UPDATE_ERROR", message: "Invalid view update parameters", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            // Get the view
            guard let viewInfo = ViewRegistry.shared.getViewInfo(id: viewId) else {
                print("View not found for update: \(viewId)")
                result(false)
                return
            }
            
            let view = viewInfo.view
            let componentType = viewInfo.type
            
            // Separate layout props from style props
            let layoutProps = props.filter { SupportedLayoutsProps.supportedLayoutProps.contains($0.key) }
            let styleProps = props.filter { !layoutProps.keys.contains($0.key) }
            
            // Update layout props
            if !layoutProps.isEmpty {
                DCMauiLayoutManager.shared.updateNodeWithLayoutProps(
                    nodeId: viewId,
                    componentType: componentType,
                    props: layoutProps
                )
            }
            
            // Update style props
            if !styleProps.isEmpty {
                if let handlerType = DCMauiComponentRegistry.shared.getComponentType(for: componentType) {
                    // Create an instance of the component handler
                    let handler = handlerType.init()
                    _ = handler.updateView(view, withProps: styleProps)
                }
            }
            
            result(true)
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
            guard let viewInfo = ViewRegistry.shared.getViewInfo(id: viewId) else {
                print("View not found for deletion: \(viewId)")
                result(false)
                return
            }
            
            let view = viewInfo.view
            
            // Remove from parent view
            view.removeFromSuperview()
            
            // Clean up from registry
            ViewRegistry.shared.removeView(id: viewId)
            
            // Remove from shadow tree
            YogaShadowTree.shared.removeNode(nodeId: viewId)
            
            result(true)
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
            guard let childView = ViewRegistry.shared.getView(id: childId),
                  let parentView = ViewRegistry.shared.getView(id: parentId) else {
                print("Failed to find child or parent view: \(childId) -> \(parentId)")
                result(false)
                return
            }
            
            // Add child to parent
            parentView.addSubview(childView)
            
            // Update shadow tree
            YogaShadowTree.shared.addChildNode(parentId: parentId, childId: childId, index: index)
            
            result(true)
        }
    }
    
    // Set children for a view
    private func handleSetChildren(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String,
              let childrenIds = args["childrenIds"] as? [String] else {
            result(FlutterError(code: "CHILDREN_ERROR", message: "Invalid children parameters", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            guard let parentView = ViewRegistry.shared.getView(id: viewId) else {
                print("Parent view not found: \(viewId)")
                result(false)
                return
            }
            
            // Set z-order of children based on array order
            for (index, childId) in childrenIds.enumerated() {
                if let childView = ViewRegistry.shared.getView(id: childId) {
                    parentView.insertSubview(childView, at: index)
                    
                    // Update shadow tree
                    YogaShadowTree.shared.addChildNode(parentId: viewId, childId: childId, index: index)
                }
            }
            
            result(true)
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
                           let props = update["props"] as? [String: Any] {
                            
                            // Call the create view handler with the same arguments
                            let createArgs: [String: Any] = [
                                "viewId": viewId,
                                "viewType": viewType,
                                "props": props
                            ]
                            
                            var createSuccess = false
                            let semaphore = DispatchSemaphore(value: 0)
                            
                            self.handleCreateView(createArgs) { result in
                                if let boolResult = result as? Bool {
                                    createSuccess = boolResult
                                }
                                semaphore.signal()
                            }
                            
                            semaphore.wait()
                            
                            if !createSuccess {
                                allSucceeded = false
                            }
                        }
                        
                    case "updateView":
                        if let viewId = update["viewId"] as? String,
                           let props = update["props"] as? [String: Any] {
                            
                            // Call the update view handler with the same arguments
                            let updateArgs: [String: Any] = [
                                "viewId": viewId,
                                "props": props
                            ]
                            
                            var updateSuccess = false
                            let semaphore = DispatchSemaphore(value: 0)
                            
                            self.handleUpdateView(updateArgs) { result in
                                if let boolResult = result as? Bool {
                                    updateSuccess = boolResult
                                }
                                semaphore.signal()
                            }
                            
                            semaphore.wait()
                            
                            if !updateSuccess {
                                allSucceeded = false
                            }
                        }
                        
                    default:
                        print("Unknown batch operation: \(operation)")
                    }
                }
            }
            
            // Calculate layout after batch update
            YogaShadowTree.shared.calculateAndApplyLayout(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height
            )
            
            result(allSucceeded)
        }
    }
}
