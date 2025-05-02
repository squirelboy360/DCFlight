//
//  DCDivergerUtil.swift
//  
//
//  Created by Tahiru Agbanwa on 4/15/25.
//
import Flutter

@objc public extension FlutterAppDelegate {
    func divergeToFlight() {
        // Get the Flutter engine from the app delegate
        let flutterEngine = FlutterEngine(name: "main engine")
        // Initialize and run the Flutter engine with explicit entry point
        flutterEngine.run(withEntrypoint: "main", libraryURI: nil)
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        flutterEngine.viewController = flutterViewController
        
        // Initialize method channels
        DCMauiBridgeMethodChannel.shared.initialize(with: flutterEngine.binaryMessenger)
        DCMauiEventMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
        DCMauiLayoutMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
        
   
        let nativeRootVC = UIViewController()
        nativeRootVC.view.backgroundColor = .white
        nativeRootVC.title = "Root View (DCFLight)"
        self.window.rootViewController = nativeRootVC
        setupDCF(rootView: nativeRootVC.view, flutterEngine: flutterEngine)
        
        // Initialize screen utilities
        _ = DCFScreenUtilities.shared
    }
    
    // Setup the DCMauiNativeBridge
    private func setupDCF(rootView: UIView, flutterEngine: FlutterEngine) {

        // Set up the root with the props
        DCMauiBridgeImpl.shared.registerView(rootView, withId: "root")
        // Initialize screen utilities with the Flutter binary messenger
        DCFScreenUtilities.shared.initialize(with: flutterEngine.binaryMessenger)
        
        // Initialize the yoga layout system
        _ = YogaShadowTree.shared
        _ = DCFLayoutManager.shared

    
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func orientationChanged() {
        // Allow a moment for the UI to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Get the current screen dimensions
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            YogaShadowTree.shared.calculateAndApplyLayout(width: screenWidth, height: screenHeight)
        }
    }
}


