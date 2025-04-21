import Flutter
import UIKit

/// Handles bridge method channel interactions between Flutter and native code
class DCMauiBridgeMethodChannel: NSObject {
    /// Singleton instance
    static let shared = DCMauiBridgeMethodChannel()
    
    /// Method channel for bridge operations
    var methodChannel: FlutterMethodChannel?
    
    /// Views dictionary to mimic FFIBridge (for compatibility)
    var views = [String: UIView]()
    
    // Add startup recovery system
    private var isFirstBoot = true
    private var appBootId = UUID().uuidString
    
    // Store view creation history for recovery
    private var viewCreationHistory = [ViewCreationRecord]()
    
    // Maximum history records to keep
    private let maxHistoryRecords = 100
    
    // Record for tracking view creation for recovery
    private struct ViewCreationRecord {
        let viewId: String
        let viewType: String
        let props: [String: Any]
        let parentId: String?
        let index: Int?
        let timestamp: TimeInterval
    }
    
    func initialize() {
        print("🚀 Bridge channel initializing with boot ID: \(appBootId)")
        isFirstBoot = true
        
        // Clear stale view records on startup
        viewCreationHistory.removeAll()
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
        
        print("🌉 Bridge method channel initialized directly")
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
    
    // Records view creation for recovery
    private func recordViewCreation(viewId: String, viewType: String, props: [String: Any], parentId: String? = nil, index: Int? = nil) {
        let record = ViewCreationRecord(
            viewId: viewId, 
            viewType: viewType, 
            props: props,
            parentId: parentId,
            index: index,
            timestamp: Date().timeIntervalSince1970
        )
        
        // Add to history, maintaining size limit
        viewCreationHistory.append(record)
        if viewCreationHistory.count > maxHistoryRecords {
            viewCreationHistory.removeFirst()
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
            
            // Record successful view creation for recovery
            if success {
                self.recordViewCreation(viewId: viewId, viewType: viewType, props: props)
            }
            
            result(success)
        }
    }
    
    // Check if system needs recovery
    private func checkIfRecoveryNeeded() -> Bool {
        // For simplicity, always verify view existence on first boot or after app restart
        if isFirstBoot {
            isFirstBoot = false
            return true
        }
        
        // Compare boot IDs if we have a previous one
        if let prevBootId = UserDefaults.standard.string(forKey: "lastBootId"),
           prevBootId != appBootId {
            print("🔄 App restart detected. Previous boot ID: \(prevBootId), New boot ID: \(appBootId)")
            return true
        }
        
        return false
    }
    
    // Save current boot ID
    private func saveBootState() {
        UserDefaults.standard.set(appBootId, forKey: "lastBootId")
    }
    
    // Execute recovery if needed before an update operation
    private func ensureViewExistsBeforeUpdate(viewId: String, completion: @escaping (Bool) -> Void) {
        // Check if view exists
        let viewExists = DCMauiBridgeImpl.shared.viewExists(viewId: viewId)
        
        if !viewExists {
            print("⚠️ View \(viewId) doesn't exist. Attempting recovery...")
            
            // Look for view creation history
            if let record = viewCreationHistory.first(where: { $0.viewId == viewId }) {
                // Attempt to recreate the view
                print("🔄 Attempting to recreate view \(viewId) of type \(record.viewType)")
                
                guard let propsData = try? JSONSerialization.data(withJSONObject: record.props),
                      let propsJson = String(data: propsData, encoding: .utf8) else {
                    completion(false)
                    return
                }
                
                // Create view
                let success = DCMauiBridgeImpl.shared.createView(viewId: viewId, viewType: record.viewType, propsJson: propsJson)
                
                // If successful and has parent info, try to reattach
                if success && record.parentId != nil && record.index != nil {
                    let parentExists = DCMauiBridgeImpl.shared.viewExists(viewId: record.parentId!)
                    if parentExists {
                        _ = DCMauiBridgeImpl.shared.attachView(childId: viewId, parentId: record.parentId!, index: record.index!)
                    }
                }
                
                completion(success)
                return
            }
            
            completion(false)
        } else {
            completion(true)
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
        
        // CRITICAL FIX: Ensure view exists before attempting update
        ensureViewExistsBeforeUpdate(viewId: viewId) { viewReady in
            if viewReady {
                // Normal path - view exists, update it
                let updateOperation = {
                    let success = DCMauiBridgeImpl.shared.updateView(viewId: viewId, propsJson: propsJson)
                    result(success)
                }
                
                if Thread.isMainThread {
                    updateOperation()
                } else {
                    DispatchQueue.main.sync {
                        updateOperation()
                    }
                }
            } else {
                // View couldn't be recovered
                print("❌ View \(viewId) couldn't be recovered - update failed")
                result(false)
            }
        }
    }
    
    // Helper method to extract original properties from a view
    private func extractOriginalProps(from view: UIView) -> [String: Any]? {
        // Try to infer basic properties from the view
        var props: [String: Any] = [:]
        
        // Extract basic frame information
        props["width"] = view.frame.width
        props["height"] = view.frame.height
        
        // Extract background color
        if let backgroundColor = view.backgroundColor {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let hexString = String(format: "#%02X%02X%02X%02X", 
                                  Int(red * 255), Int(green * 255), Int(blue * 255), Int(alpha * 255))
            props["backgroundColor"] = hexString
        }
        
        // Extract content for text views
        if let textView = view as? UILabel {
            props["text"] = textView.text
            props["textAlign"] = textAlignmentToString(textView.textAlignment)
            props["fontSize"] = textView.font.pointSize
            
            if let textColor = textView.textColor {
                var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
                textColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                let hexString = String(format: "#%02X%02X%02X%02X", 
                                      Int(red * 255), Int(green * 255), Int(blue * 255), Int(alpha * 255))
                props["color"] = hexString
            }
        }
        
        return props
    }
    
    // Helper method to determine view type from a UIView instance
    private func determineViewType(forView view: UIView) -> String {
        if view is UILabel {
            return "Text"
        } else if view is UIButton {
            return "Button"
        } else if view is UIImageView {
            return "Image"
        } else if view is UIScrollView {
            return "ScrollView"
        } else {
            return "View"  // Default fallback
        }
    }
    
    // Helper to convert NSTextAlignment to string
    private func textAlignmentToString(_ alignment: NSTextAlignment) -> String {
        switch alignment {
        case .center:
            return "center"
        case .left:
            return "left"
        case .right:
            return "right"
        case .justified:
            return "justified"
        case .natural:
            return "natural"
        @unknown default:
            return "left"
        }
    }
    
    // Helper to find parent view ID and child index
    private func findParentView(forViewId viewId: String) -> (String, Int)? {
        // Try to get the view
        guard let childView = DCMauiBridgeImpl.shared.views[viewId] else {
            return nil
        }
        
        // Loop through all views to find a parent
        for (potentialParentId, potentialParentView) in DCMauiBridgeImpl.shared.views {
            if potentialParentView.subviews.contains(childView) {
                // Found the parent, now determine index
                if let index = potentialParentView.subviews.firstIndex(of: childView) {
                    return (potentialParentId, index)
                }
            }
        }
        
        return nil
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
    
    // Check if a view exists
    private func handleViewExists(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String else {
            result(FlutterError(code: "VIEW_EXISTS_ERROR", message: "Invalid view ID", details: nil))
            return
        }
        
        // Execute on main thread
        DispatchQueue.main.async {
            let exists = DCMauiBridgeImpl.shared.views[viewId] != nil ||
                         ViewRegistry.shared.getView(id: viewId) != nil ||
                         DCMauiLayoutManager.shared.getView(withId: viewId) != nil
            result(exists)
        }
    }
    
    /// Helper to get a view by ID - needed for compatibility
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
