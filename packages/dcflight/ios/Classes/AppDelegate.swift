//
//  AppDelegate.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 4/15/25.
//



import Flutter
import UIKit


@objc open class DCAppDelegate: FlutterAppDelegate {
    
    // Flutter engine instance that will be used by the whole app
    var flutterEngine: FlutterEngine?
    
    @objc public static func registerWithRegistrar(_ registrar: FlutterPluginRegistrar) {
        // This method is required by Flutter's plugin system
        // The actual initialization happens in divergeToFlight
        print("✅ DCFlight plugin registered with Flutter")
    }
    
    override open func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      // Create and run engine before diverging to ensure Dart code executes
      self.flutterEngine = FlutterEngine(name: "io.dcflight.engine")
      self.flutterEngine?.run(withEntrypoint: "main", libraryURI: nil)
      
      // Register plugins with this engine
//      GeneratedPluginRegistrant.register(with: self)
      
      // Now diverge to DCFlight setup
      divergeToFlight()
      print("divergence complete")
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
