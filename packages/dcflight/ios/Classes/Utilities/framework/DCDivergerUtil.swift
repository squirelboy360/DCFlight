//
//  DCDivergerUtil.swift
//  
//
//  Created by Tahiru Agbanwa on 4/15/25.
//
import Flutter

@objc public extension FlutterAppDelegate {
    func divergeToFlight() {
        let appDelegate = self as? DCAppDelegate
        let flutterEngine = appDelegate?.flutterEngine ?? FlutterEngine(name: "main engine")
        
        if appDelegate?.flutterEngine == nil {
            flutterEngine.run(withEntrypoint: "main", libraryURI: nil)
        }
        
        let flutterVC = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        flutterEngine.viewController = flutterVC
        sharedFlutterViewController = flutterVC // ✅ Store globally
        
        // Initialize method channels
        DCMauiBridgeMethodChannel.shared.initialize(with: flutterEngine.binaryMessenger)
        DCMauiEventMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)
        DCMauiLayoutMethodHandler.shared.initialize(with: flutterEngine.binaryMessenger)

        // Set up the native root view
        let nativeRootVC = UIViewController()
        nativeRootVC.view.backgroundColor = .white
        nativeRootVC.title = "Root View (DCFlight)"
        self.window.rootViewController = nativeRootVC
        setupDCF(rootView: nativeRootVC.view, flutterEngine: flutterEngine)

        _ = DCFScreenUtilities.shared
    }

    private func setupDCF(rootView: UIView, flutterEngine: FlutterEngine) {
        DCMauiBridgeImpl.shared.registerView(rootView, withId: "root")
        DCFScreenUtilities.shared.initialize(with: flutterEngine.binaryMessenger)
        _ = YogaShadowTree.shared
        _ = DCFLayoutManager.shared

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        logAllFlutterAssets()

    }

    @objc private func orientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            YogaShadowTree.shared.calculateAndApplyLayout(width: screenWidth, height: screenHeight)
        }
    }
}



func logAllFlutterAssets() {
    guard let resourcePath = Bundle.main.resourcePath else {
        print("❌ Could not get resource path.")
        return
    }

    let assetsPath = resourcePath + "/Frameworks/"
    print("🔍 Looking inside Flutter assets at: \(assetsPath)\n")

    let fileManager = FileManager.default

    do {
        let files = try fileManager.subpathsOfDirectory(atPath: assetsPath)

        if files.isEmpty {
            print("📦 No Flutter assets found.")
            return
        }

        print("📦 Flutter assets found (\(files.count) items):")
        for file in files {
            if file.contains("packages/") {
                print(" - 📦 Package asset: \(file)")
            } else {
                print(" - \(file)")
            }
        }
    } catch {
        print("❌ Error reading flutter_assets directory: \(error)")
    }
}
