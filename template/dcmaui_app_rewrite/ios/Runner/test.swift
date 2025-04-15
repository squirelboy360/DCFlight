//
//  test.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 4/15/25.
//


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