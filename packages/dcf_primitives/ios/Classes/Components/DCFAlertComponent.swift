import UIKit
import dcflight

class DCFAlertComponent: NSObject, DCFComponent, ComponentMethodHandler {
    // Keep track of active alerts
    private static var activeAlerts = [String: UIAlertController]()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a container view (invisible)
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        
        // Apply props
        _ = _ = updateView(containerView, withProps: props)
        
        return containerView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Store initial props for potential use later
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "initialProps".hashValue)!, 
                               props, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Check if we should show initially
        if let visible = props["visible"] as? Bool, visible {
            // Get the view ID
            if let viewId = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String {
                _ = showAlert(viewId: viewId, containerView: view, props: props)
            }
        }
        
        return true
    }
    
    // Get the appropriate alert style
    private func getAlertStyle(from styleName: String?) -> UIAlertController.Style {
        guard let styleName = styleName else {
            return .alert
        }
        
        switch styleName {
        case "actionSheet":
            return .actionSheet
        default:
            return .alert
        }
    }
    
    // Get the appropriate action style
    private func getActionStyle(from styleName: String?) -> UIAlertAction.Style {
        guard let styleName = styleName else {
            return .default
        }
        
        switch styleName {
        case "cancel":
            return .cancel
        case "destructive":
            return .destructive
        default:
            return .default
        }
    }
    
    // Handle Alert-specific methods
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        // Get the view ID associated with this view
        guard let viewId = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String else {
            print("❌ Cannot handle method for alert: missing viewId")
            return false
        }
        
        switch methodName {
        case "show":
            // Get stored props
            let props = objc_getAssociatedObject(view, 
                                               UnsafeRawPointer(bitPattern: "initialProps".hashValue)!) as? [String: Any] ?? [:]
            return showAlert(viewId: viewId, containerView: view, props: props)
            
        case "dismiss":
            return dismissAlert(viewId: viewId)
            
        case "addAction":
            return addActionToAlert(viewId: viewId, action: args)
            
        default:
            return false
        }
    }
    
    // Show the alert
    private func showAlert(viewId: String, containerView: UIView, props: [String: Any]) -> Bool {
        // Get root view controller - iOS 13 compatible way
        let rootVC: UIViewController?
        if #available(iOS 13.0, *) {
            // Use the scene-based approach for iOS 13+
            rootVC = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.rootViewController
        } else {
            // Use the old approach for iOS 12 and earlier
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        guard let rootViewController = rootVC else {
            print("❌ Cannot show alert: no root view controller")
            return false
        }
        
        // Get the top-most presented view controller
        var topVC = rootViewController
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        
        // Create the alert controller
        let title = props["title"] as? String ?? ""
        let message = props["message"] as? String ?? ""
        let style = getAlertStyle(from: props["style"] as? String)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        
        // Add actions if provided in props
        if let actions = props["actions"] as? [[String: Any]] {
            for action in actions {
                _ = addActionToAlert(viewId: viewId, controller: alertController, action: action)
            }
        }
        
        // Present the alert
        topVC.present(alertController, animated: true) {
            print("✅ Alert presented: \(viewId)")
        }
        
        // Store the alert controller
        DCFAlertComponent.activeAlerts[viewId] = alertController
        
        return true
    }
    
    // Dismiss the alert
    private func dismissAlert(viewId: String) -> Bool {
        // Get the alert controller
        guard let alertController = DCFAlertComponent.activeAlerts[viewId] else {
            print("❌ Cannot dismiss alert: not found")
            return false
        }
        
        // Dismiss the alert
        alertController.dismiss(animated: true) {
            print("✅ Alert dismissed: \(viewId)")
            
            // Remove from active alerts
            DCFAlertComponent.activeAlerts.removeValue(forKey: viewId)
        }
        
        return true
    }
    
    // Add an action to an alert
    private func addActionToAlert(viewId: String, action: [String: Any]) -> Bool {
        // Get the alert controller
        guard let alertController = DCFAlertComponent.activeAlerts[viewId] else {
            print("❌ Cannot add action to alert: alert not found")
            return false
        }
        
        return addActionToAlert(viewId: viewId, controller: alertController, action: action)
    }
    
    // Add an action to an alert controller
    private func addActionToAlert(viewId: String, controller: UIAlertController, action: [String: Any]) -> Bool {
        // Get action properties
        let title = action["title"] as? String ?? ""
        let style = getActionStyle(from: action["style"] as? String)
        
        // Create the action
        let alertAction = UIAlertAction(title: title, style: style) { [weak self] _ in
            print("👆 Alert action tapped: \(title)")
            
            // Trigger event with the action data
            if let containerView = self?.getContainerView(for: viewId) {
                self?.triggerEvent(on: containerView, eventType: "onAction", eventData: [
                    "title": title,
                    "style": action["style"] as? String ?? "default"
                ])
            }
            
            // Remove from active alerts after action
            DCFAlertComponent.activeAlerts.removeValue(forKey: viewId)
        }
        
        // Add the action to the alert controller
        controller.addAction(alertAction)
        
        return true
    }
    
    // Find the container view for an alert
    private func getContainerView(for viewId: String) -> UIView? {
        // Ideally we'd have a better way to find the container view,
        // but for now we'll just iterate through all views
        for window in UIApplication.shared.windows {
            if let containerView = findContainerView(in: window, viewId: viewId) {
                return containerView
            }
        }
        return nil
    }
    
    // Recursively search for container view
    private func findContainerView(in view: UIView, viewId: String) -> UIView? {
        // Check if this view has the right viewId
        if let id = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String,
           id == viewId {
            return view
        }
        
        // Check all subviews
        for subview in view.subviews {
            if let containerView = findContainerView(in: subview, viewId: viewId) {
                return containerView
            }
        }
        
        return nil
    }
    
    // Add a custom view hook for when the view is registered with the shadow tree
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Store node ID on the view
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "viewId".hashValue)!, 
                               nodeId, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
