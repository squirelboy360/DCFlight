//
//  AppDelegate.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 4/15/25.
//



import Flutter
import UIKit


@objc open class DCAppDelegate: FlutterAppDelegate {
    
    @objc public static func registerWithRegistrar(_ registrar: FlutterPluginRegistrar) {
        // This method is required by Flutter's plugin system
        // The actual initialization happens in divergeToFlight
      
        print("✅ DCFlight plugin registered with Flutter")
        
    }
    
  override open func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    divergeToFlight()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
