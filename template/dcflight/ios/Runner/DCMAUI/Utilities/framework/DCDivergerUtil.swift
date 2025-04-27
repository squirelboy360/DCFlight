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
        
        // Initialize method channels
        DCMauiBridgeMethodChannel.shared.initialize(with: flutterEngine.binaryMessenger)
        DCMauiEventMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
        DCMauiLayoutMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
        
   
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let nativeRootVC = UIViewController()
        nativeRootVC.view.backgroundColor = .white
        nativeRootVC.title = "Root View (DCMAUI)"
        self.window.rootViewController = nativeRootVC
        setupDCMauiNativeBridge(rootView: nativeRootVC.view)
        
        // Initialize screen utilities
        _ = DCMauiScreenUtilities.shared
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
        DCMauiBridgeImpl.shared.registerView(rootContainer, withId: "root")
        // Initialize screen utilities with the Flutter binary messenger
        DCMauiScreenUtilities.shared.initialize(with: flutterEngine.binaryMessenger)
        
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


