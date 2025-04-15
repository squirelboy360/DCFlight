//
//  DCDivergerUtil.swift
//  
//
//  Created by Tahiru Agbanwa on 4/15/25.
//

extension AppDelegate {
    internal func DivergeToDCMAUI() {
        // Initialize and run the Flutter engine
        flutterEngine.run(withEntrypoint: nil, initialRoute: "/")
        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        flutterEngine.viewController = flutterViewController
        DCMauiEventMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
        DCMauiLayoutMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
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
   
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let nativeRootVC = UIViewController()
        nativeRootVC.view.backgroundColor = .white
        nativeRootVC.title = "Root View (DCMAUI)"
        self.window.rootViewController = nativeRootVC
        setupDCMauiNativeBridge(rootView: nativeRootVC.view)
        // Initialize screen utilities
        _ = DCMauiScreenUtilities.shared
//??        Defer the trigger to tghe dart side. Only uncomment if you know what you are doing else you may leave this unchanged. Removing the comment is allowed but it's only here for reference in case there is a          layout issue and u want to quickly debug
        // CRITICAL FIX: Trigger layout calculations on main thread after a very short delay
        // This ensures the root view is properly set up when running from Flutter CLI
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//            self?.performInitialLayoutCalculation()
//            
//            // Schedule another calculation after the Flutter engine is fully initialized
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//                self?.performInitialLayoutCalculation()
//                print("🔄 Performed delayed secondary layout calculation")
//            }
//        }
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
        
        // Set up the root with the props
        DCMauiNativeBridgeCoordinator.shared.manuallyCreateRootView(rootContainer, viewId: "root", props: ["flex":1])
        // Initialize screen utilities with the Flutter binary messenger
        DCMauiScreenUtilities.shared.initialize(with: flutterEngine.binaryMessenger)
        
        // Initialize the yoga layout system
        _ = YogaShadowTree.shared
        _ = DCMauiLayoutManager.shared

        
        // Add this observer for device orientation changes
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
            
            print("📱 Device orientation changed: \(screenWidth)x\(screenHeight)")
            // Update layouts with new dimensions - use BOTH methods for reliability
            YogaShadowTree.shared.calculateAndApplyLayout(width: screenWidth, height: screenHeight)
        }
    }
}
