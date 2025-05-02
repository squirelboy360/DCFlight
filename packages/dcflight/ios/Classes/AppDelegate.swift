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
        // Register the plugin with the Flutter engine
        print("✅ DCFlight plugin registered with Flutter")
        
        // Set up method channels directly through the registrar
        let messenger = registrar.messenger()
        
        // Initialize method channels for bridge, events, and layout
        DCMauiBridgeMethodChannel.shared.initialize(with: messenger)
        DCMauiEventMethodHandler.shared.initialize(with: messenger)
        DCMauiLayoutMethodHandler.shared.initialize(with: messenger)
        
        // Initialize screen utilities
        DCFScreenUtilities.shared.initialize(with: messenger)
    }
    
    override open func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      // Create and run engine before diverging to ensure Dart code executes
      self.flutterEngine = FlutterEngine(name: "io.dcflight.engine")
      self.flutterEngine?.run(withEntrypoint: "main", libraryURI: nil)
      
      // Register generated plugins with this engine if available
      if let registrarMethod = NSClassFromString("GeneratedPluginRegistrant") {
          let registerSelector = NSSelectorFromString("registerWithRegistry:")
          if registrarMethod.responds(to: registerSelector) {
              registrarMethod.perform(registerSelector, with: self, afterDelay: 0.2)
          }
      }
      
      // Now diverge to DCFlight setup
      divergeToFlight()
      print("divergence complete")
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
