import UIKit
import dcflight

class DCFStackNavigatorComponent: NSObject, DCFComponent, ComponentMethodHandler, UINavigationControllerDelegate {
    // Keep track of active navigation controllers
    private static var activeNavigationControllers = [String: UINavigationController]()
    
    // Keep track of route configurations by navigation controller
    private static var routeConfigsByNavigator = [String: [[String: Any]]]()
    
    // Keep track of route views by route ID
    private static var routeViewsByRouteId = [String: UIView]()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a navigation controller
        let navigationController = UINavigationController()
        navigationController.delegate = self
        
        // Do NOT modify the navigation bar's translatesAutoresizingMaskIntoConstraints
        // UIKit manages the navigation bar's layout internally
        
        // Extract route configurations
        if let routes = props["routes"] as? [[String: Any]] {
            // Process initial route ID
            if let initialRouteId = props["initialRouteId"] as? String {
                // Find the initial route configuration
                if let initialRoute = routes.first(where: { $0["id"] as? String == initialRouteId }) {
                    // Create a placeholder view controller for the initial route
                    let initialViewController = DCFRouteViewController()
                    initialViewController.title = initialRoute["title"] as? String
                    initialViewController.routeId = initialRouteId
                    
                    // Set root view controller
                    navigationController.viewControllers = [initialViewController]
                }
            }
        }
        
        // Apply props
        _ = updateView(navigationController.view, withProps: props)
        
        // Create a container view to hold the navigation controller's view
        let containerView = UIView(frame: navigationController.view.bounds)
        containerView.backgroundColor = UIColor.clear
        
        // Store the navigation controller with this container view
        objc_setAssociatedObject(containerView, 
                               UnsafeRawPointer(bitPattern: "navController".hashValue)!, 
                               navigationController, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Add navigation controller's view as a subview
        containerView.addSubview(navigationController.view)
        
        // Set up proper constraints instead of autoresizing mask
        navigationController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navigationController.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            navigationController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            navigationController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            navigationController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        return containerView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Find the navigation controller for this view
        guard let navigationController = findNavigationController(for: view) else {
            return false
        }
        
        // Store initial props for potential use later
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "initialProps".hashValue)!, 
                               props, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Apply navigation bar visibility
        if let navigationBarHidden = props["navigationBarHidden"] as? Bool {
            navigationController.setNavigationBarHidden(navigationBarHidden, animated: false)
        }
        
        // Apply bar style
        if let barStyle = props["barStyle"] as? String {
            switch barStyle {
            case "largeTitles":
                navigationController.navigationBar.prefersLargeTitles = true
            case "transparent":
                navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
                navigationController.navigationBar.shadowImage = UIImage()
                navigationController.navigationBar.isTranslucent = true
            default:
                navigationController.navigationBar.prefersLargeTitles = false
                navigationController.navigationBar.setBackgroundImage(nil, for: .default)
                navigationController.navigationBar.shadowImage = nil
            }
        }
        
        // Apply bar tint color
        if let barTintColor = props["barTintColor"] as? String {
            navigationController.navigationBar.tintColor = ColorUtilities.color(fromHexString: barTintColor)
        }
        
        // Store route configurations
        if let routes = props["routes"] as? [[String: Any]], let viewId = getViewId(for: view) {
            DCFStackNavigatorComponent.routeConfigsByNavigator[viewId] = routes
        }
        
        return true
    }
    
    // Handle StackNavigator-specific methods
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        // Get the view ID associated with this view
        guard let viewId = getViewId(for: view),
              let navigationController = DCFStackNavigatorComponent.activeNavigationControllers[viewId] else {
            print("❌ Cannot handle method for navigator: missing viewId or navigation controller")
            return false
        }
        
        switch methodName {
        case "push":
            return pushScreen(navigationController: navigationController, 
                            viewId: viewId, 
                            screenId: args["screenId"] as? String ?? "",
                            animated: args["animated"] as? Bool ?? true)
            
        case "pop":
            return popScreen(navigationController: navigationController,
                           animated: args["animated"] as? Bool ?? true)
            
        case "popToRoot":
            return popToRoot(navigationController: navigationController,
                           animated: args["animated"] as? Bool ?? true)
            
        case "setNavigationBarHidden":
            navigationController.setNavigationBarHidden(
                args["hidden"] as? Bool ?? false,
                animated: args["animated"] as? Bool ?? true
            )
            return true
            
        case "setTitle":
            if let title = args["title"] as? String,
               let topViewController = navigationController.topViewController {
                topViewController.title = title
                return true
            }
            return false
            
        default:
            return false
        }
    }
    
    // Push a screen onto the navigation stack
    private func pushScreen(navigationController: UINavigationController, viewId: String, screenId: String, animated: Bool) -> Bool {
        // Find route configuration for the screen ID
        guard let routes = DCFStackNavigatorComponent.routeConfigsByNavigator[viewId],
              let routeConfig = routes.first(where: { $0["id"] as? String == screenId }) else {
            print("❌ Cannot push screen: route configuration not found for \(screenId)")
            return false
        }
        
        // Create a view controller for the route
        let viewController = DCFRouteViewController()
        viewController.title = routeConfig["title"] as? String
        viewController.routeId = screenId
        
        // Push the view controller
        navigationController.pushViewController(viewController, animated: animated)
        
        // Trigger navigate event
        triggerEvent(on: navigationController.view, eventType: "onNavigate", eventData: [
            "type": "push",
            "routeId": screenId
        ])
        
        return true
    }
    
    // Pop a screen from the navigation stack
    private func popScreen(navigationController: UINavigationController, animated: Bool) -> Bool {
        // Ensure we have more than one view controller
        guard navigationController.viewControllers.count > 1 else {
            print("⚠️ Cannot pop screen: already at root")
            return false
        }
        
        // Get the current and previous view controllers
        if let currentVC = navigationController.topViewController as? DCFRouteViewController,
           let previousVC = navigationController.viewControllers[navigationController.viewControllers.count - 2] as? DCFRouteViewController {
            
            // Pop view controller
            navigationController.popViewController(animated: animated)
            
            // Trigger navigate event
            triggerEvent(on: navigationController.view, eventType: "onNavigate", eventData: [
                "type": "pop",
                "routeId": previousVC.routeId ?? "",
                "poppedRouteId": currentVC.routeId ?? ""
            ])
            
            return true
        }
        
        return false
    }
    
    // Pop to root screen
    private func popToRoot(navigationController: UINavigationController, animated: Bool) -> Bool {
        // Ensure we have more than one view controller
        guard navigationController.viewControllers.count > 1 else {
            print("⚠️ Cannot pop to root: already at root")
            return false
        }
        
        // Get the root view controller
        if let rootVC = navigationController.viewControllers.first as? DCFRouteViewController {
            // Pop to root
            navigationController.popToRootViewController(animated: animated)
            
            // Trigger navigate event
            triggerEvent(on: navigationController.view, eventType: "onNavigate", eventData: [
                "type": "popToRoot",
                "routeId": rootVC.routeId ?? ""
            ])
            
            return true
        }
        
        return false
    }
    
    // Find the navigation controller for a view
    private func findNavigationController(for view: UIView) -> UINavigationController? {
        // Check if this is our container view with an associated navigation controller
        if let navController = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "navController".hashValue)!) as? UINavigationController {
            return navController
        }
        
        // Otherwise, look through active navigation controllers
        if let viewId = getViewId(for: view), 
           let navigationController = DCFStackNavigatorComponent.activeNavigationControllers[viewId] {
            return navigationController
        }
        
        return nil
    }
    
    // Get the view ID for a view
    private func getViewId(for view: UIView) -> String? {
        return objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "viewId".hashValue)!) as? String
    }
    
    // Add a custom view hook for when the view is registered with the shadow tree
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Store node ID on the view
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "viewId".hashValue)!, 
                               nodeId, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Check if this is our container view with an associated navigation controller
        if let navigationController = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "navController".hashValue)!) as? UINavigationController {
            // Store in active navigation controllers
            DCFStackNavigatorComponent.activeNavigationControllers[nodeId] = navigationController
        }
    }
    
    // MARK: - Navigation Controller Delegate
    
    func navigationController(_ navigationController: UINavigationController, 
                            didShow viewController: UIViewController, 
                            animated: Bool) {
        // Handle navigation controller events if needed
        if let routeVC = viewController as? DCFRouteViewController,
           let routeId = routeVC.routeId {
            print("✅ Navigated to route: \(routeId)")
        }
    }
}

// Custom view controller for route screens
class DCFRouteViewController: UIViewController {
    // Route identifier
    var routeId: String?
    
    // Content view for route content
    let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up content view
        contentView.backgroundColor = UIColor.white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Set up constraints - use edges instead of safeArea to avoid constraint conflicts
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // Add content to the route
    func addContent(_ contentView: UIView) {
        // Remove existing content
        for subview in self.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        // Add new content
        self.contentView.addSubview(contentView)
        
        // Set up constraints
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])
    }
}
