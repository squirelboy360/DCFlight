//
//  DCInputAccessoryView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// InputAccessoryView component that matches React Native's InputAccessoryView
class DCInputAccessoryView: DCBaseView {
    // Static registry of input accessory views by nativeID
    private static var registry: [String: DCInputAccessoryView] = [:]
    
    // Properties
    private var nativeID: String?
    private var accessoryBackgroundColor: UIColor = UIColor.systemBackground
    
    // Use a computed property with the same type as superclass (UIColor?)
    override var backgroundColor: UIColor? {
        get {
            return accessoryBackgroundColor
        }
        set {
            accessoryBackgroundColor = newValue ?? UIColor.systemBackground
            super.backgroundColor = accessoryBackgroundColor
        }
    }

    override func setupView() {
        super.setupView()
        
        // Setup basic properties
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.systemBackground
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Update properties
        if let nativeID = props["nativeID"] as? String {
            self.nativeID = nativeID
            registerAccessoryView()
        }
        
        if let backgroundColorStr = props["backgroundColor"] as? String, backgroundColorStr.hasPrefix("#") {
            backgroundColor = UIColor(hexString: backgroundColorStr)
            self.backgroundColor = backgroundColor
        }
    }
    
    private func registerAccessoryView() {
        guard let nativeID = self.nativeID else { return }
        
        // Register this view so it can be linked to text inputs
        DCInputAccessoryView.registry[nativeID] = self
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        // Make sure our frame takes the safe area into account
        if #available(iOS 11.0, *) {
            let safeAreaHeight = window?.safeAreaInsets.bottom ?? 0
            if frame.size.height > 0 && safeAreaHeight > 0 {
                let updatedFrame = CGRect(
                    x: frame.origin.x,
                    y: frame.origin.y,
                    width: frame.size.width,
                    height: frame.size.height + safeAreaHeight
                )
                frame = updatedFrame
            }
        }
    }
    
    // MARK: - Static Methods
    
    /// Get an input accessory view by its native ID
    static func getInputAccessoryViewWithNativeID(_ nativeID: String) -> DCInputAccessoryView? {
        return DCInputAccessoryView.registry[nativeID]
    }
    
    /// Remove an accessory view from the registry
    static func unregisterAccessoryView(_ nativeID: String) {
        DCInputAccessoryView.registry.removeValue(forKey: nativeID)
    }
    
    deinit {
        if let nativeID = self.nativeID {
            DCInputAccessoryView.registry.removeValue(forKey: nativeID)
        }
    }
}

// Extension for DCTextInput to support input accessory views
extension DCTextInput {
    /// Set an input accessory view by native ID
    func setInputAccessoryViewNativeID(_ nativeID: String?) {
        guard let nativeID = nativeID else {
            // Use a public method instead of direct property access
            self.setInputAccessoryView(nil)
            return
        }
        
        if let accessoryView = DCInputAccessoryView.getInputAccessoryViewWithNativeID(nativeID) {
            // Use a public method instead of direct property access
            self.setInputAccessoryView(accessoryView)
        }
    }
}

// Important: Add this method to DCTextInput.swift
// This comment is to remind you to implement this method in DCTextInput.swift
