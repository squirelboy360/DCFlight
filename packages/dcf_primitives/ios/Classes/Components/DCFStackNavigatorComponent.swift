import UIKit
import dcflight

class DCFStackNavigatorComponent: NSObject, DCFComponent, ComponentMethodHandler, UINavigationControllerDelegate {
    // The navigation controller
    private let navigationController = UINavigationController()
    
    // Map of route names to screen data
    private var routes: [String: [String: Any]] = [:]
    
    // Current screen view controllers
    private var screenViewControllers: [String: UIViewController] = [:]
    
    required override init() {
        super.init()
        navigationController.delegate = self
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Configure navigation controller with initial props
        navigationController.navigationBar.prefersLargeTitles = true
        
        // Apply props
        updateView(navigationController.view, withProps: props)
        
        return navigationController.view
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Show/hide navigation bar
        if let showNavigationBar = props["showNavigationBar"] as? Bool {
            navigationController.isNavigationBarHidden = !showNavigationBar
        }
        
        // Configure navigation bar appearance
        if let barBackgroundColor = props["barBackgroundColor"] as? String {
            navigationController.navigationBar.barTintColor = ColorUtilities.color(fromHexString: barBackgroundColor)
        }
        
        if let barTextColor = props["barTextColor"] as? String {
            navigationController.navigationBar.tintColor = ColorUtilities.color(fromHexString: barTextColor)
            navigationController.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: ColorUtilities.color(fromHexString: barTextColor)
            ]
        }
        
        // Enable/disable swipe back gesture
        if let enableSwipeBack = props["enableSwipeBack"] as? Bool {
            navigationController.interactivePopGestureRecognizer?.isEnabled = enableSwipeBack
        }
        
        // Initial route
        if let initialRoute = props["initialRoute"] as? String, 
           navigationController.viewControllers.isEmpty {
            // Create a placeholder view controller
            let viewController = DCFRouteViewController(routeName: initialRoute)
            navigationController.setViewControllers([viewController], animated: false)
        }
        
        return true
    }
    
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        switch methodName {
        case "push":
            if let routeInfo = args["routeInfo"] as? [String: Any],
               let routeName = routeInfo["name"] as? String {
                let params = routeInfo["params"] as? [String: Any] ?? [:]
                let transition = args["transition"] as? [String: Any]
                return pushRoute(routeName: routeName, params: params, transition: transition)
            }
            return false
            
        case "pop":
            let result = args["result"]
            return popRoute(result: result)
            
        case "popToRoot":
            let animated = args["animated"] as? Bool ?? true
            return popToRootRoute(animated: animated)
            
        case "replace":
            if let routeInfo = args["routeInfo"] as? [String: Any],
               let routeName = routeInfo["name"] as? String {
                let params = routeInfo["params"] as? [String: Any] ?? [:]
                let transition = args["transition"] as? [String: Any]
                return replaceRoute(routeName: routeName, params: params, transition: transition)
            }
            return false
            
        default:
            return false
        }
    }
    
    // MARK: - Navigation Methods
    
    private func pushRoute(routeName: String, params: [String: Any], transition: [String: Any]?) -> Bool {
        // Create a DCF route view controller
        let viewController = DCFRouteViewController(routeName: routeName, params: params)
        
        // Configure transition if provided
        if let transition = transition {
            let routeTransition = DCFRouteTransition(dictionary: transition)
            DCFNavigationUtilities.applyTransition(routeTransition, to: viewController)
        }
        
        // Push view controller
        navigationController.pushViewController(viewController, animated: true)
        return true
    }
    
    private func popRoute(result: Any?) -> Bool {
        if navigationController.viewControllers.count > 1 {
            // Capture current view controller to send result
            if let currentViewController = navigationController.topViewController as? DCFRouteViewController {
                currentViewController.setResult(result)
            }
            
            navigationController.popViewController(animated: true)
            return true
        }
        return false
    }
    
    private func popToRootRoute(animated: Bool) -> Bool {
        if navigationController.viewControllers.count > 1 {
            navigationController.popToRootViewController(animated: animated)
            return true
        }
        return false
    }
    
    private func replaceRoute(routeName: String, params: [String: Any], transition: [String: Any]?) -> Bool {
        // Create a view controller for the new route
        let viewController = DCFRouteViewController(routeName: routeName, params: params)
        
        // Configure transition if provided
        if let transition = transition {
            let routeTransition = DCFRouteTransition(dictionary: transition)
            DCFNavigationUtilities.applyTransition(routeTransition, to: viewController)
        }
        
        // Replace the top view controller
        var viewControllers = navigationController.viewControllers
        if !viewControllers.isEmpty {
            viewControllers.removeLast()
            viewControllers.append(viewController)
            navigationController.setViewControllers(viewControllers, animated: true)
            return true
        } else {
            // If no view controllers exist, just push it
            navigationController.pushViewController(viewController, animated: false)
            return true
        }
    }
}

// MARK: - Route View Controller

/// A view controller that represents a route in the stack
class DCFRouteViewController: UIViewController {
    private let routeName: String
    private let params: [String: Any]
    private var result: Any?
    private var contentView: UIView?
    
    init(routeName: String, params: [String: Any] = [:]) {
        self.routeName = routeName
        self.params = params
        super.init(nibName: nil, bundle: nil)
        self.title = routeName.capitalized
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Create a container view for route content
        let containerView = UIView(frame: view.bounds)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(containerView)
        contentView = containerView
        
        // Route content will be set by DCFlight framework
    }
    
    func setResult(_ result: Any?) {
        self.result = result
    }
    
    func getResult() -> Any? {
        return result
    }
    
    func getContentView() -> UIView {
        if contentView == nil {
            contentView = UIView(frame: view.bounds)
            contentView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(contentView!)
        }
        return contentView!
    }
}
