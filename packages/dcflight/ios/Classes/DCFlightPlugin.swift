//
//  DCFlightPlugin.swift
//  dcflight
//
//  Created by Tahiru Agbanwa on 4/15/25.
//

import Flutter
import UIKit

@objc public class DCFlightPlugin: NSObject, FlutterPlugin {
    @objc public static func register(with registrar: FlutterPluginRegistrar) {
        print("✅ Registering DCFlight plugin")
        
        // Initialize method channels
        DCMauiBridgeMethodChannel.shared.initialize(with: registrar.messenger())
        DCMauiEventMethodHandler.shared.initialize(with: registrar.messenger())
        DCMauiLayoutMethodHandler.shared.initialize(with: registrar.messenger())
        
        // Initialize screen utilities
        DCFScreenUtilities.shared.initialize(with: registrar.messenger())
        
        // Call initialization method on DCAppDelegate
        DCAppDelegate.registerWithRegistrar(registrar)
        
        // Initialize the bridge implementation
        let _ = DCMauiBridgeImpl.shared.initialize()
    }
}
