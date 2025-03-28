//
//  DCActionSheetIOS.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// ActionSheetIOS component that matches React Native's ActionSheetIOS API
class DCActionSheetIOS: NSObject {
    // Keep track of completion handlers for action sheets
    private static var completionHandlers: [String: ([Any]) -> Void] = [:]
    
    /// Show an action sheet with the specified options
    static func showActionSheet(viewId: String, options: [String: Any]) {
        // Get required parameters
        guard let title = options["title"] as? String,
              let optionsArr = options["options"] as? [String] else {
            return
        }
        
        // Get optional parameters
        let cancelButtonIndex = options["cancelButtonIndex"] as? Int
        let destructiveButtonIndex = options["destructiveButtonIndex"] as? Int ?? -1
        let message = options["message"] as? String
        let anchor = options["anchor"] as? Int // Used for iPad
        let tintColor = options["tintColor"] as? String
        
        // Find the topmost view controller to present from
        guard let topViewController = UIApplication.shared.keyWindow?.rootViewController?.topMostViewController() else {
            return
        }
        
        // Create alert controller
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        // Set tint color if specified
        if let tintColorStr = tintColor, tintColorStr.hasPrefix("#") {
            actionSheet.view.tintColor = UIColor(hexString: tintColorStr)
        }
        
        // Add action buttons
        for (index, option) in optionsArr.enumerated() {
            let style: UIAlertAction.Style
            
            if index == destructiveButtonIndex {
                style = .destructive
            } else if index == cancelButtonIndex {
                style = .cancel
            } else {
                style = .default
            }
            
            let action = UIAlertAction(title: option, style: style) { _ in
                // Send selection event back to JS
                DCViewCoordinator.shared?.sendEvent(
                    viewId: viewId,
                    eventName: "onActionSheetSelection",
                    params: [
                        "buttonIndex": index,
                        "target": viewId
                    ]
                )
                
                // Remove completion handler reference
                DCActionSheetIOS.completionHandlers.removeValue(forKey: viewId)
            }
            
            actionSheet.addAction(action)
        }
        
        // For iPad, we need to set the source view for the popover
        if let popoverController = actionSheet.popoverPresentationController {
            // Default to center of the screen if no anchor is provided
            if let anchorView = topViewController.view {
                popoverController.sourceView = anchorView
                
                if let anchorPoint = anchor {
                    // Try to find the view with the specified tag
                    if let sourceView = topViewController.view.viewWithTag(anchorPoint) {
                        popoverController.sourceRect = sourceView.frame
                    } else {
                        popoverController.sourceRect = CGRect(x: anchorView.bounds.midX, y: anchorView.bounds.midY, width: 0, height: 0)
                    }
                } else {
                    popoverController.sourceRect = CGRect(x: anchorView.bounds.midX, y: anchorView.bounds.midY, width: 0, height: 0)
                }
            }
        }
        
        // Present the action sheet
        topViewController.present(actionSheet, animated: true, completion: nil)
    }
}

// Extension to UIViewController to find the top most view controller
extension UIViewController {
    func topMostViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        } else if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController() ?? self
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController() ?? self
        } else {
            return self
        }
    }
}
