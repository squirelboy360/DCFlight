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
    // Add Flutter plugin registration method
    @objc public static func registerWithRegistrar(_ registrar: FlutterPluginRegistrar) {
        // This method is required by Flutter's plugin system
        // The actual initialization happens in divergeToFlight
        print("✅ DCFlight plugin registered with Flutter")
    }

}

