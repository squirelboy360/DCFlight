import UIKit
import Flutter
import yoga

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "main engine")
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Initialize and run the Flutter engine
        flutterEngine.run(withEntrypoint: nil, initialRoute: "/")
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        // IMPROVED: Initialize both method channels early in startup process
        // Initialize event handler
        DCMauiEventMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
        
        // Initialize layout handler
        DCMauiLayoutMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
        
        // IMPROVED: Setup Native-to-Dart event forwarding using the new event handler
        DCMauiEventMethodHandler.shared.setEventCallback { viewId, eventType, eventData in
            print("📲 SENDING EVENT TO DART: \(eventType) for \(viewId)")
            DCMauiEventMethodHandler.shared.methodChannel?.invokeMethod(
                "onEvent",
                arguments: [
                    "viewId": viewId,
                    "eventType": eventType,
                    "eventData": eventData
                ]
            )
        }
        
        // Create window with proper frame
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create a native container view controller with explicit background
        let nativeRootVC = UIViewController()
        nativeRootVC.view.backgroundColor = .white
        nativeRootVC.title = "Root View (DCMAUI)"
        
        // Initialize and setup DCMauiNativeBridge
        setupDCMauiNativeBridge(rootView: nativeRootVC.view)
        
        // Use the native view controller as root
        self.window.rootViewController = nativeRootVC
        self.window.makeKeyAndVisible()
        
        // Keep a reference to the Flutter view controller
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        flutterEngine.viewController = flutterViewController
        
        // Initialize screen utilities
        _ = DCMauiScreenUtilities.shared
        
        print("DC MAUI: Running in headless mode with native UI container")
        
        // CRITICAL FIX: Trigger layout calculations on main thread after a very short delay
        // This ensures the root view is properly set up when running from Flutter CLI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.performInitialLayoutCalculation()
            
            // Schedule another calculation after the Flutter engine is fully initialized
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.performInitialLayoutCalculation()
                print("🔄 Performed delayed secondary layout calculation")
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // NEW: Extract initial layout calculation to a separate method for reusability
    private func performInitialLayoutCalculation() {
        print("🚀 Performing initial layout calculation")
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Calculate layout through the method channel instead of directly
        DCMauiLayoutMethodHandler.shared.methodChannel?.invokeMethod("calculateLayout", arguments: [
            "screenWidth": screenWidth,
            "screenHeight": screenHeight
        ])
        
        // Ensure we also trigger the direct calculation as a fallback incase user runs the app on another cli like flutter or for future proofing or something like that 
        YogaShadowTree.shared.calculateAndApplyLayout(width: screenWidth, height: screenHeight)
        
        // Force all views to update
        if let rootView = DCMauiLayoutManager.shared.getView(withId: "root") {
            rootView.setNeedsLayout()
            rootView.layoutIfNeeded()
            
            print("📋 View hierarchy after initial layout:")
            LayoutDebugging.shared.printViewHierarchy(rootView)
        }
    }
    
    // Setup the DCMauiNativeBridge
    private func setupDCMauiNativeBridge(rootView: UIView) {
        // Set up the root container view - FULL SIZE
        let rootContainer = UIView(frame: rootView.bounds)
        // CRITICAL FIX: Set constraints to make sure rootContainer fills the parent view
        rootContainer.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(rootContainer)
        
        NSLayoutConstraint.activate([
            rootContainer.topAnchor.constraint(equalTo: rootView.topAnchor),
            rootContainer.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            rootContainer.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            rootContainer.trailingAnchor.constraint(equalTo: rootView.trailingAnchor)
        ])
        
        // Set up the root with our props
        DCMauiNativeBridgeCoordinator.shared.manuallyCreateRootView(rootContainer, viewId: "root", props: ["flex":1])
        
        // IMPORTANT: Register the root view with FFI bridge for direct access
        DCMauiFFIBridge.shared.registerView(rootContainer, withId: "root")
        
        print("DC MAUI: Root view registered with ID: root - size: \(rootContainer.bounds)")
        
        // Initialize screen utilities with the Flutter binary messenger
        DCMauiScreenUtilities.shared.initialize(with: flutterEngine.binaryMessenger)
        
        // Initialize the yoga layout system
        _ = YogaShadowTree.shared
        _ = DCMauiLayoutManager.shared
        
        // CRITICAL FIX: Register for notifications about layout changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLayoutChange(_:)),
            name: UIApplication.didChangeStatusBarFrameNotification,
            object: nil
        )
        
        // Add this observer for device orientation changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        // NOTE: We removed the initial layout calculation here and moved it to the main method
        // with better timing controls
    }
    
    // Add this method to handle layout changes
    @objc private func handleLayoutChange(_ notification: Notification) {
        guard let view = notification.object as? UIView,
              let nodeId = view.getNodeId() else { return }
        
        // Special optimization: we only care about container views changing size
        if view.subviews.count > 0 {
            print("📲 View \(nodeId) changed size to: \(view.frame)")
            
            // Force recalculation of this subtree
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                YogaShadowTree.shared.performIncrementalLayoutUpdate(
                    nodeId: nodeId,
                    props: ["width": view.frame.width, "height": view.frame.height]
                )
            }
        }
    }
    
    // Add this method to handle orientation changes
    @objc private func orientationChanged() {
        // Allow a moment for the UI to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Get the current screen dimensions
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            print("📱 Device orientation changed: \(screenWidth)x\(screenHeight)")
            
            // Update layouts with new dimensions - use BOTH methods for reliability
            YogaShadowTree.shared.calculateAndApplyLayout(width: screenWidth, height: screenHeight)
            
            // Also trigger via method channel
            DCMauiLayoutMethodHandler.shared.methodChannel?.invokeMethod("calculateLayout", arguments: [
                "screenWidth": screenWidth,
                "screenHeight": screenHeight
            ])
        }
    }
}
