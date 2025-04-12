import UIKit
import Flutter

/// Method channel handler for all layout-related operations
class DCMauiLayoutMethodHandler: NSObject {
    // Singleton instance
    static let shared = DCMauiLayoutMethodHandler()
    
    // Method channel for layout operations
    private var methodChannel: FlutterMethodChannel?
    
    // Private initializer for singleton
    private override init() {
        super.init()
        // Setup will be done later when binary messenger is available
    }
    
    // Initialize with Flutter binary messenger
    func initialize(with binaryMessenger: FlutterBinaryMessenger) {
        methodChannel = FlutterMethodChannel(
            name: "com.dcmaui.layout",
            binaryMessenger: binaryMessenger
        )
        
        setupMethodCallHandler()
        print("📐 Layout method channel initialized")
    }
    
    // Register method call handler
    private func setupMethodCallHandler() {
        methodChannel?.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterError(code: "UNAVAILABLE", 
                                   message: "Layout handler not available", 
                                   details: nil))
                return
            }
            
            switch call.method {
                case "calculateLayout":
                    self.handleCalculateLayout(call, result)
                    
                case "updateViewLayout":
                    self.handleUpdateViewLayout(call, result)
                    
                case "syncNodeHierarchy":
                    self.handleSyncNodeHierarchy(call, result)
                    
                case "getNodeHierarchy":
                    self.handleGetNodeHierarchy(call, result)
                    
                case "setVisualDebugEnabled":
                    self.handleSetVisualDebugEnabled(call, result)
                    
                default:
                    result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // Handle calculateLayout calls
    private func handleCalculateLayout(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let screenWidth = args["screenWidth"] as? CGFloat,
              let screenHeight = args["screenHeight"] as? CGFloat else {
            result(FlutterError(code: "INVALID_ARGS", 
                               message: "Invalid arguments for calculateLayout", 
                               details: nil))
            return
        }
        
        print("📐 METHOD CHANNEL: calculateLayout called with dimensions: \(screenWidth)x\(screenHeight)")
        
        // Execute on main thread
        DispatchQueue.main.async {
            let success = YogaShadowTree.shared.calculateAndApplyLayout(
                width: screenWidth, 
                height: screenHeight
            )
            result(success)
        }
    }
    
    // Handle updateViewLayout calls
    private func handleUpdateViewLayout(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? String,
              let left = args["left"] as? CGFloat,
              let top = args["top"] as? CGFloat,
              let width = args["width"] as? CGFloat,
              let height = args["height"] as? CGFloat else {
            result(FlutterError(code: "INVALID_ARGS", 
                               message: "Invalid arguments for updateViewLayout", 
                               details: nil))
            return
        }
        
        print("📐 METHOD CHANNEL: updateViewLayout called for \(viewId): (\(left), \(top), \(width), \(height))")
        
        // Apply layout on main thread
        DispatchQueue.main.async {
            let success = DCMauiLayoutManager.shared.applyLayout(
                to: viewId,
                left: left, 
                top: top, 
                width: width, 
                height: height
            )
            result(success)
        }
    }
    
    // Handle syncNodeHierarchy calls
    private func handleSyncNodeHierarchy(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let rootId = args["rootId"] as? String,
              let nodeTree = args["nodeTree"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", 
                               message: "Invalid arguments for syncNodeHierarchy", 
                               details: nil))
            return
        }
        
        print("📐 METHOD CHANNEL: syncNodeHierarchy called for root \(rootId)")
        
        // Execute on main thread
        DispatchQueue.main.async {
            if let nodeTreeData = nodeTree.data(using: .utf8),
               let nodeTreeDict = try? JSONSerialization.jsonObject(with: nodeTreeData) as? [String: Any] {
                
                let syncResults = YogaShadowTree.shared.validateAndRepairHierarchy(
                    nodeTree: nodeTreeDict, 
                    rootId: rootId
                )
                
                let resultDict: [String: Any] = [
                    "success": syncResults.success,
                    "error": syncResults.errorMessage ?? NSNull(),
                    "nodesChecked": syncResults.nodesChecked,
                    "nodesMismatched": syncResults.nodesMismatched,
                    "nodesRepaired": syncResults.nodesRepaired,
                    "timestamp": Date().timeIntervalSince1970
                ]
                
                result(resultDict)
            } else {
                result(FlutterError(code: "INVALID_JSON", 
                                   message: "Could not parse node tree JSON", 
                                   details: nil))
            }
        }
    }
    
    // Handle getNodeHierarchy calls
    private func handleGetNodeHierarchy(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let nodeId = args["nodeId"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", 
                               message: "Invalid arguments for getNodeHierarchy", 
                               details: nil))
            return
        }
        
        print("📐 METHOD CHANNEL: getNodeHierarchy called for node \(nodeId)")
        
        // Execute on main thread
        DispatchQueue.main.async {
            let hierarchyJson = YogaShadowTree.shared.getHierarchyAsJson(startingAt: nodeId)
            
            if let jsonData = hierarchyJson.data(using: .utf8),
               let hierarchyDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                result(hierarchyDict)
            } else {
                result(FlutterError(code: "INVALID_RESPONSE", 
                                   message: "Could not parse hierarchy JSON", 
                                   details: nil))
            }
        }
    }
    
    // Handle setVisualDebugEnabled calls
    private func handleSetVisualDebugEnabled(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let enabled = args["enabled"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGS", 
                               message: "Invalid arguments for setVisualDebugEnabled", 
                               details: nil))
            return
        }
        
        print("📐 METHOD CHANNEL: setVisualDebugEnabled called with value \(enabled)")
        
        // Execute on main thread
        DispatchQueue.main.async {
            YogaShadowTree.shared.setDebugLayoutEnabled(enabled)
            result(true)
        }
    }
}
