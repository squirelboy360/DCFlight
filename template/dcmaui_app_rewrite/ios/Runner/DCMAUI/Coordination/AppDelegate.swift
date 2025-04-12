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
        
        // OPTIMIZED: Initialize both method channels early but with less overhead
        initializeMethodChannels()
        
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
        
        // OPTIMIZED: Single initial layout calculation with fence
        DispatchQueue.main.async {
            // Create a dispatch group to coordinate layout operations
            let layoutGroup = DispatchGroup()
            layoutGroup.enter()
            
            // Perform initial layout calculation
            self.performInitialLayoutCalculation(completion: {
                layoutGroup.leave()
            })
            
            // Wait with reasonable timeout to prevent hanging
            let result = layoutGroup.wait(timeout: .now() + 2.0)
            if result == .timedOut {
                print("⚠️ Initial layout calculation timed out - continuing anyway")
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // OPTIMIZED: Separate method channel initialization for better organization
    private func initializeMethodChannels() {
        // Minimize logging during initialization
        let oldLogLevel = OSLog.setLogLevel(.error)
        defer { OSLog.setLogLevel(oldLogLevel) }
        
        // Initialize event handler with minimal logging
        DCMauiEventMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
        
        // Initialize layout handler with minimal logging
        DCMauiLayoutMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
        
        // Setup Native-to-Dart event forwarding with minimal overhead
        DCMauiEventMethodHandler.shared.setEventCallback { [weak self] viewId, eventType, eventData in
            // Only log on debug builds
            #if DEBUG
            print("📲 Event to Dart: \(eventType) for \(viewId)")
            #endif
            
            DCMauiEventMethodHandler.shared.methodChannel?.invokeMethod(
                "onEvent",
                arguments: [
                    "viewId": viewId,
                    "eventType": eventType,
                    "eventData": eventData
                ]
            )
        }
    }
    
    // OPTIMIZED: Improved layout calculation with completion handler and reduced overhead
    private func performInitialLayoutCalculation(completion: @escaping () -> Void = {}) {
        print("🚀 Performing initial layout calculation")
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // CRITICAL FIX: Calculate layout immediately and force apply
        _ = YogaShadowTree.shared.calculateAndApplyLayout(width: screenWidth, height: screenHeight)
        
        // Ensure root view is properly sized
        if let rootView = DCMauiLayoutManager.shared.getView(withId: "root") {
            rootView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            rootView.setNeedsLayout()
            rootView.layoutIfNeeded()
            print("📏 Root view frame after initial layout: \(rootView.frame)")
        }
        
        // IMPORTANT: Use method channel approach which has better synchronization
        DCMauiLayoutMethodHandler.shared.methodChannel?.invokeMethod(
            "calculateLayout", 
            arguments: [
                "screenWidth": screenWidth,
                "screenHeight": screenHeight
            ]
        )
        
        completion()
    }
    
    private func setupDCMauiNativeBridge(rootView: UIView) {
        // Set up the root container view - FULL SIZE
        let rootContainer = UIView(frame: rootView.bounds)
        rootContainer.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(rootContainer)
        
        NSLayoutConstraint.activate([
            rootContainer.topAnchor.constraint(equalTo: rootView.topAnchor),
            rootContainer.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            rootContainer.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            rootContainer.trailingAnchor.constraint(equalTo: rootView.trailingAnchor)
        ])
        
        // Set up the root with minimal props 
        DCMauiNativeBridgeCoordinator.shared.manuallyCreateRootView(rootContainer, viewId: "root", props: ["flex":1])
        
        // Register with FFI bridge for direct access
        DCMauiFFIBridge.shared.registerView(rootContainer, withId: "root")
        
        // REDUCED LOGGING: Print only essential information
        print("DC MAUI: Root view registered")
        
        // Initialize screen utilities with the Flutter binary messenger
        DCMauiScreenUtilities.shared.initialize(with: flutterEngine.binaryMessenger)
        
        // OPTIMIZED: Initialize the yoga layout system with fewer operations
        YogaShadowTree.shared.optimizedInitialization()
        _ = DCMauiLayoutManager.shared
        
        // Register for notifications about layout changes
        registerLayoutObservers()
    }
    
    // OPTIMIZED: Separate method for registering layout observers
    private func registerLayoutObservers() {
        // Register for status bar changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLayoutChange(_:)),
            name: UIApplication.didChangeStatusBarFrameNotification,
            object: nil
        )
        
        // Register for device orientation changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    // OPTIMIZED: More efficient layout change handler
    @objc private func handleLayoutChange(_ notification: Notification) {
        guard let view = notification.object as? UIView,
              let nodeId = view.getNodeId() else { return }
        
        // Only process container views with multiple subviews
        if view.subviews.count > 1 {
            // Use a more efficient approach with less overhead
            DispatchQueue.main.async {
                YogaShadowTree.shared.performIncrementalLayoutUpdate(
                    nodeId: nodeId,
                    props: ["width": view.frame.width, "height": view.frame.height]
                )
            }
        }
    }
    
    // OPTIMIZED: More efficient orientation change handler
    @objc private func orientationChanged() {
        print("📱 Orientation changed - recalculating layouts")
        
        // CRITICAL FIX: Force layout calculation immediately
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Don't use a dispatch - do it immediately
        if let rootView = DCMauiFFIBridge.shared.views["root"] {
            print("📏 Root view frame before orientation change: \(rootView.frame)")
        }
        
        // CRITICAL FIX: Calculate layout synchronously
        _ = YogaShadowTree.shared.calculateAndApplyLayout(width: screenWidth, height: screenHeight)
        
        // Force immediate layout for root view
        if let rootView = DCMauiFFIBridge.shared.views["root"] {
            rootView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            rootView.setNeedsLayout()
            rootView.layoutIfNeeded()
            print("📏 Root view frame after orientation change: \(rootView.frame)")
        }
        
        // Also use the method channel
        DCMauiLayoutMethodHandler.shared.methodChannel?.invokeMethod(
            "calculateLayout", 
            arguments: [
                "screenWidth": screenWidth,
                "screenHeight": screenHeight
            ]
        )
    }
}

// Add OSLog helper for controlling log levels
class OSLog {
    enum LogLevel: Int {
        case verbose = 0
        case debug = 1
        case info = 2
        case warning = 3
        case error = 4
        case none = 5
    }
    
    private static var currentLogLevel: LogLevel = .info
    
    static func setLogLevel(_ level: LogLevel) -> LogLevel {
        let oldLevel = currentLogLevel
        currentLogLevel = level
        return oldLevel
    }
    
    static func shouldLog(forLevel level: LogLevel) -> Bool {
        return level.rawValue >= currentLogLevel.rawValue
    }
}
