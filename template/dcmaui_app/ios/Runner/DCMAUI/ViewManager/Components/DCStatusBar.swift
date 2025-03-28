//
//  DCStatusBar.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

class DCStatusBar: DCBaseView {
    // Use var instead of let for controller
    var controller = UIApplication.shared.keyWindow?.rootViewController
    
    override func setupView() {
        super.setupView()
        // Status bar is a special view that doesn't render visually
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Update status bar style
        if let barStyle = props["barStyle"] as? String {
            updateStatusBarStyle(barStyle)
        }
        
        // Update status bar hidden state
        if let hidden = props["hidden"] as? Bool {
            updateStatusBarVisibility(hidden)
        }
        
        // Update status bar background color
        if let style = props["style"] as? [String: Any], 
           let backgroundColor = style["backgroundColor"] as? String {
            updateStatusBarBackgroundColor(backgroundColor)
        }
        
        // Update status bar animation
        let animated = props["animated"] as? Bool ?? true
        updateStatusBarAnimation(animated)
    }
    
    private func updateStatusBarStyle(_ style: String) {
        var statusBarStyle: UIStatusBarStyle
        
        switch style {
        case "dark-content":
            if #available(iOS 13.0, *) {
                statusBarStyle = .darkContent
            } else {
                statusBarStyle = .default
            }
        case "light-content":
            statusBarStyle = .lightContent
        default:
            statusBarStyle = .default
        }
        
        if let viewController = controller as? UIViewController & StatusBarStyleController {
            viewController.preferredStatusBarStyle = statusBarStyle
            viewController.setNeedsStatusBarAppearanceUpdate()
        } else {
            // Use application-level fallback
            if #available(iOS 13.0, *) {
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let window = windowScene?.windows.first
                window?.overrideUserInterfaceStyle = statusBarStyle == .darkContent ? .light : .dark
            }
            // For iOS versions that allow direct status bar style manipulation
            if #available(iOS 9.0, *), UIApplication.shared.responds(to: #selector(UIApplication.shared.setStatusBarStyle(_:animated:))) {
                UIApplication.shared.setStatusBarStyle(statusBarStyle, animated: true)
            }
        }
    }
    
    private func updateStatusBarVisibility(_ hidden: Bool) {
        if let viewController = controller as? UIViewController & StatusBarStyleController {
            viewController.prefersStatusBarHidden = hidden
            viewController.setNeedsStatusBarAppearanceUpdate()
        } else {
            // Use application-level fallback
            if #available(iOS 9.0, *), UIApplication.shared.responds(to: #selector(UIApplication.shared.setStatusBarHidden(_:with:))) {
                UIApplication.shared.setStatusBarHidden(hidden, with: .fade)
            }
        }
    }
    
    private func updateStatusBarBackgroundColor(_ colorString: String) {
        // Fix the conditional binding error by removing 'if let' since UIColor(hexString:) is not optional
        let color = UIColor(hexString: colorString)
        
        if let viewController = controller as? UIViewController & StatusBarStyleController {
            viewController.statusBarBackgroundColor = color
        } else {
            // For versions where we can directly modify status bar background
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusBar.backgroundColor = color
            }
        }
    }
    
    private func updateStatusBarAnimation(_ animated: Bool) {
        // Animation settings are applied when changes are made
        // This is just a placeholder for future use if we want to store the preference
    }
}

// Define a protocol for view controllers that want to control status bar
protocol StatusBarStyleController {
    var preferredStatusBarStyle: UIStatusBarStyle { get set }
    var prefersStatusBarHidden: Bool { get set }
    var statusBarBackgroundColor: UIColor? { get set }
    func setNeedsStatusBarAppearanceUpdate()
}

// Create a default UIViewController extension to implement the protocol
extension UIViewController: StatusBarStyleController {
    // These properties already exist in UIViewController, so no need to redefine
    open var preferredStatusBarStyle: UIStatusBarStyle {
        get { return .default }
        set { } // Empty setter - will be overridden by subclasses
    }
    
    open var prefersStatusBarHidden: Bool {
        get { return false }
        set { } // Empty setter - will be overridden by subclasses
    }
    
    @objc var statusBarBackgroundColor: UIColor? {
        get {
            return nil
        }
        set {
            // Find status bar view and set background
            if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
                statusBar.backgroundColor = newValue
            }
        }
    }
}
