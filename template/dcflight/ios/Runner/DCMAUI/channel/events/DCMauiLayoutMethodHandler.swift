import Flutter
import UIKit

/// Handles layout method channel interactions between Flutter and native code
class DCMauiLayoutMethodHandler: NSObject {
    /// Singleton instance
    static let shared = DCMauiLayoutMethodHandler()
    let frame = UIScreen.main.bounds;
    
    /// Method channel for layout operations
    var methodChannel: FlutterMethodChannel?
    
    /// Initialize with Flutter binary messenger
    func initialize(with binaryMessenger: FlutterBinaryMessenger) {
        // Create method channel
        methodChannel = FlutterMethodChannel(
            name: "com.dcmaui.layout",
            binaryMessenger: binaryMessenger
        )
        
        // Set up method handler
        methodChannel?.setMethodCallHandler(handleMethodCall)
        
        print("📐 Layout method channel initialized")
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
        case "calculateLayout":
            handleCalculateLayout(args, result: result)
            
        case "updateViewLayout":
            handleUpdateViewLayout(args, result: result)
            
            
        case "getScreenDimensions":
            handleGetScreenDimensions(result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // Calculate layout for the entire view hierarchy
    private func handleCalculateLayout(_ args: [String: Any], result: @escaping FlutterResult) {
        // Use dedicated layout background queue - never on UI thread
        DispatchQueue(label: "com.dcmaui.layoutCalculation", qos: .userInitiated).async {
            // Calculate layout
            let success = YogaShadowTree.shared.calculateAndApplyLayout(width: self.frame.width, height: self.frame.height)
            
            // Send result on the main thread
            DispatchQueue.main.async {
                result(success)
            }
        }
    }
    
    // Update the layout of a specific view
    private func handleUpdateViewLayout(_ args: [String: Any], result: @escaping FlutterResult) {
        guard let viewId = args["viewId"] as? String,
              let left = args["left"] as? CGFloat,
              let top = args["top"] as? CGFloat,
              let width = args["width"] as? CGFloat,
              let height = args["height"] as? CGFloat else {
            result(FlutterError(code: "LAYOUT_ERROR", message: "Invalid layout parameters", details: nil))
            return
        }
        
        // Apply layout without main thread
        let success = DCFLayoutManager.shared.queueLayoutUpdate(
            to: viewId,
            left: left,
            top: top,
            width: width,
            height: height
        )
        
        result(success)
    }

    
    // Get screen dimensions
    private func handleGetScreenDimensions(result: @escaping FlutterResult) {
        let bounds = UIScreen.main.bounds
        let dimensions = [
            "width": bounds.width,
            "height": bounds.height,
            "scale": UIScreen.main.scale,
            "statusBarHeight": UIApplication.shared.statusBarFrame.height
        ]
        
        result(dimensions)
    }
}
