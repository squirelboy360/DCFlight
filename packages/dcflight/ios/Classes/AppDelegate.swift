//
//  AppDelegate.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 4/15/25.
//

import UIKit
import Flutter
import yoga

@UIApplicationMain
@objc public class AppDelegate: FlutterAppDelegate {
    lazy var flutterEngine = FlutterEngine(name: "main engine")
    
    // Add Flutter plugin registration method
    @objc public static func registerWithRegistrar(_ registrar: FlutterPluginRegistrar) {
        // This method is required by Flutter's plugin system
        // The actual initialization happens in divergeToFlight
        print("✅ DCFlight plugin registered with Flutter")
    }
   
    override public func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        divergeToFlight()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

