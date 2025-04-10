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
        
        // Set up the method channel for events
        DCMauiNativeBridgeCoordinator.shared.setupEventChannel(binaryMessenger: flutterEngine.binaryMessenger)
        
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
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
        
        // CRITICAL FIX: Force initial layout calculation with screen dimensions
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("🚀 Performing initial layout calculation")
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            // Calculate layout directly
            YogaShadowTree.shared.calculateAndApplyLayout(width: screenWidth, height: screenHeight)
            
            // CRITICAL FIX: Enable debug view borders for development
//            UserDefaults.standard.set(true, forKey: "DCMauiDebugViewBorders")
            
            // Print debug info about all views
            print("📋 View hierarchy after initial layout:")
            LayoutDebugging.shared.printViewHierarchy(rootContainer)
            
            // CRITICAL FIX: Enable visual debugging for all views EXCEPT root
//            #if DEBUG
//            LayoutDebugging.shared.enableVisualDebuggingExceptRoot(for: rootContainer)
//            #endif
        }
    }
}
