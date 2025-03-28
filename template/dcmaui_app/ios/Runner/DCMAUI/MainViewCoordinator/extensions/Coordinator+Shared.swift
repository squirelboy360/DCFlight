//
//  Coordinator+Shared.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import Foundation
import Flutter
import UIKit

extension DCViewCoordinator {
    private static var _shared: DCViewCoordinator?
    
    static var shared: DCViewCoordinator? {
        get {
            return _shared
        }
        set {
            _shared = newValue
        }
    }
    
    
    // MARK: - Plugin Registration
       static func register(with registrar: FlutterPluginRegistrar) {
           let instance = DCViewCoordinator()
           let channel = FlutterMethodChannel(
               name: "com.dcmaui.framework",
               binaryMessenger: registrar.messenger()
           )
           registrar.addMethodCallDelegate(instance, channel: channel)
           instance.methodChannel = channel
           
           
           // Set up event channel and register the stream handler
           let eventChannel = FlutterEventChannel(name: "com.dcmaui.framework/events",
                                                binaryMessenger: registrar.messenger())
           
           // Set the coordinator as the stream handler for the event channel
           eventChannel.setStreamHandler(instance)
           print("DC MAUI: Event channel registered successfully")
           
           // Store shared instance
           shared = instance
           
           print("DC MAUI: Coordinator registered successfully")
           
           
           
           // Initialize after a brief delay to ensure Flutter is ready
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
               instance.setupRootView()
           }
       }
    
    /// Find the current root view controller for presenting views
    func findRootViewController() -> UIViewController? {
        // Find the key window in iOS 13+
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first(where: { $0.isKeyWindow })
            return window?.rootViewController
        } else {
            // Fallback for earlier versions
            return UIApplication.shared.keyWindow?.rootViewController
        }
    }
    
    // MARK: - Utility Methods 
    
    /// Safely access the shared coordinator instance
    static func getShared() -> DCViewCoordinator? {
        if shared == nil {
            print("DCViewCoordinator: Warning - Trying to access shared coordinator before initialization")
        }
        return shared
    }
    
    /// Helper to check if a view exists in registry
    func viewExists(_ viewId: String) -> Bool {
        return viewRegistry.getView(viewId) != nil
    }
    
    /// Helper to run UI updates safely on main thread
    func runOnMainThread(_ action: @escaping () -> Void) {
        if Thread.isMainThread {
            action()
        } else {
            DispatchQueue.main.async {
                action()
            }
        }
    }
    
    /// Safer version of sendEvent that handles null checks
    func safelySendEvent(viewId: String, eventName: String, params: [String: Any] = [:]) {
        if viewExists(viewId) {
            self.sendEvent(viewId: viewId, eventName: eventName, params: params)
        } else {
            print("DCViewCoordinator: Warning - Attempted to send event to non-existent view: \(viewId)")
        }
    }
}

