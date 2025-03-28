//
//  DCSafeAreaView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// SafeAreaView component matching React Native's SafeAreaView
class DCSafeAreaView: DCBaseView {
    private var currentSafeAreaInsets = UIEdgeInsets.zero
    private var edgesToApply = ["top", "left", "right", "bottom"]
    
    override func setupView() {
        super.setupView()
        
        backgroundColor = UIColor.clear
        
        // Register for safe area change notifications
        if #available(iOS 11.0, *) {
            NotificationCenter.default.addObserver(
                self, 
                selector: #selector(safeAreaInsetsDidChange), 
                name: UIDevice.orientationDidChangeNotification, 
                object: nil
            )
        }
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Process which edges to apply safe area to
        if let edges = props["edges"] as? [String] {
            edgesToApply = edges
        }
        
        updateInsets()
        setNeedsLayout()
    }
    
    override func safeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.safeAreaInsetsDidChange()
            updateInsets()
        }
    }
    
    @objc private func orientationDidChange() {
        updateInsets()
    }
    
    private func updateInsets() {
        if #available(iOS 11.0, *) {
            let newInsets = getSafeAreaInsets()
            
            // Only update if insets have changed
            if !areSafeAreaInsetsEqual(currentSafeAreaInsets, newInsets) {
                currentSafeAreaInsets = newInsets
                applyInsets()
                
                // Send onInsetsChange event like React Native
                DCViewCoordinator.shared?.sendEvent(
                    viewId: viewId,
                    eventName: "onInsetsChange",
                    params: [
                        "insets": [
                            "top": newInsets.top,
                            "left": newInsets.left,
                            "right": newInsets.right,
                            "bottom": newInsets.bottom
                        ]
                    ]
                )
            }
        }
    }
    
    private func getSafeAreaInsets() -> UIEdgeInsets {
        if #available(iOS 11.0, *) {
            // Get safe area insets from window if available
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }
            if let window = window {
                var safeAreaInsets = window.safeAreaInsets
                
                // iOS-specific edge protection: Prevent zero insets
                // when device has notch but safe area is covered by navigation bar
                if safeAreaInsets.top <= 0 && UIDevice.current.hasNotch {
                    safeAreaInsets.top = 44.0 // Default notch height
                }
                
                // Ensure bottom inset for home indicator on newer iPhones
                if safeAreaInsets.bottom <= 0 && UIDevice.current.hasHomeIndicator {
                    safeAreaInsets.bottom = 34.0 // Default home indicator height
                }
                
                return safeAreaInsets
            }
        }
        
        // Fallback for older iOS versions with safety adjustments
        var insets = UIEdgeInsets(
            top: UIApplication.shared.statusBarFrame.height,
            left: 0,
            bottom: 0,
            right: 0
        )
        
        // Add bottom inset for iPhone X and newer
        if UIDevice.current.hasHomeIndicator {
            insets.bottom = 34.0
        }
        
        return insets
    }
    
    private func areSafeAreaInsetsEqual(_ insets1: UIEdgeInsets, _ insets2: UIEdgeInsets) -> Bool {
        return insets1.top == insets2.top &&
               insets1.left == insets2.left &&
               insets1.right == insets2.right &&
               insets1.bottom == insets2.bottom
    }
    
    private func applyInsets() {
        // Apply safe area insets to padding
        var newPadding = self.padding
        
        if edgesToApply.contains("top") {
            newPadding.top += currentSafeAreaInsets.top
        }
        
        if edgesToApply.contains("left") {
            newPadding.left += currentSafeAreaInsets.left
        }
        
        if edgesToApply.contains("right") {
            newPadding.right += currentSafeAreaInsets.right
        }
        
        if edgesToApply.contains("bottom") {
            newPadding.bottom += currentSafeAreaInsets.bottom
        }
        
        // Apply new padding to adjust layout
        self.padding = newPadding
        setNeedsLayout()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
