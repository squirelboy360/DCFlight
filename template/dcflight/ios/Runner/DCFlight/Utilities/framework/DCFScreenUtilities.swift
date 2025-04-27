import UIKit
import Flutter

class DCFScreenUtilities {
    static let shared = DCFScreenUtilities()
    
    // Store the Flutter binary messenger
    private var flutterBinaryMessenger: FlutterBinaryMessenger?
    private var methodChannel: FlutterMethodChannel?
    
    private init() {
        // Method channel will be set up later when binary messenger is available
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    // Initialize with a binary messenger from the Flutter app delegate
    func initialize(with binaryMessenger: FlutterBinaryMessenger) {
        self.flutterBinaryMessenger = binaryMessenger
        
        // Now create the method channel with the provided messenger
        methodChannel = FlutterMethodChannel(
            name: "com.dcmaui.screen_dimensions",
            binaryMessenger: binaryMessenger
        )
        
        setupMethodChannel()
    }
    
    private func setupMethodChannel() {
        guard let methodChannel = methodChannel else { return }
        
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { 
                result(FlutterError(code: "UNAVAILABLE", 
                                   message: "Screen utilities not available", 
                                   details: nil))
                return
            }
            
            if call.method == "getScreenDimensions" {
                // Return current screen dimensions
                let bounds = UIScreen.main.bounds
                result([
                    "width": bounds.width,
                    "height": bounds.height,
                    "scale": UIScreen.main.scale,
                    "statusBarHeight": UIApplication.shared.statusBarFrame.height
                ])
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        print("📱 Screen dimensions method channel set up successfully")
    }
    
    @objc private func orientationChanged() {
        guard let methodChannel = methodChannel else { return }
        
        // Allow a moment for the UI to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Post notification to Flutter about updated dimensions
            let bounds = UIScreen.main.bounds
            methodChannel.invokeMethod("dimensionsChanged", arguments: [
                "width": bounds.width,
                "height": bounds.height,
                "scale": UIScreen.main.scale,
                "statusBarHeight": UIApplication.shared.statusBarFrame.height
            ])
            
            print("📱 Notified Flutter of screen dimension change: \(bounds.width)x\(bounds.height)")
        }
    }
    
    // Get current screen width
    var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Get current screen height
    var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}
