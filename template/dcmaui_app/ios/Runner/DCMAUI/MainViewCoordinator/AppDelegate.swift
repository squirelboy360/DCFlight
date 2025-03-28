import UIKit
import Flutter

@available(iOS 13.0, *)
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
        
        // Create window with proper frame
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create a native container view controller with explicit background
        let nativeRootVC = UIViewController()
        nativeRootVC.view.backgroundColor = .white
        nativeRootVC.title = "DC MAUI Native UI"
        
        // Use the native view controller as root
        self.window.rootViewController = nativeRootVC
        self.window.makeKeyAndVisible()
        
        // Register our native UI manager with proper registrar
        let registrar = flutterEngine.registrar(forPlugin: "com.dcmaui.framework")
        DCViewCoordinator.register(with: registrar!)

        let flutterViewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil)
        flutterEngine.viewController = flutterViewController
        
        print("DC MAUI: Running in headless mode with native UI container")
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
