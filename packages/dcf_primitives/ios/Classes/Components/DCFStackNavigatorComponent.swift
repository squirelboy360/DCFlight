import UIKit
import dcflight
import yoga

class DCFStackNavigatorComponent: NSObject, DCFComponent, ComponentMethodHandler, UINavigationControllerDelegate {
    // The navigation controller
    private let navigationController = UINavigationController()
    
    // Map of route names to screen data
    private var routes: [String: [String: Any]] = [:]
    
    // Current screen view controllers
    private var screenViewControllers: [String: UIViewController] = [:]
    
    // Event callback and component ID for event handling
    private var eventCallback: ((String, String, [String: Any]) -> Void)?
    private var componentId: String?
    
    required override init() {
        super.init()
        navigationController.delegate = self
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a container view that will hold the navigation controller's view
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        containerView.backgroundColor = .clear
        
        // Configure navigation controller with initial props
        navigationController.navigationBar.prefersLargeTitles = true
        
        // Add the navigation controller's view to the container with proper constraints
        navigationController.view.frame = containerView.bounds
        navigationController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(navigationController.view)
        
        // Apply props
        updateView(containerView, withProps: props)
        
        return containerView
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
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let routeVC = viewController as? DCFRouteViewController else { return }
        
        // Send events to inform Dart about navigation changes
        let eventData: [String: Any] = [
            "routeName": routeVC.routeName,
            "params": routeVC.params
        ]
        
        // Use the standard event mechanism through the DCFComponent protocol
        triggerEvent(on: navigationController.view, eventType: "onRouteActivated", eventData: eventData)
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
    let routeName: String
    let params: [String: Any]
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
        
        // Create a container view for route content with proper constraints
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        // Add proper constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentView = containerView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure content view fills the available space
        contentView?.frame = view.bounds
    }
    
    func setResult(_ result: Any?) {
        self.result = result
    }
    
    func getResult() -> Any? {
        return result
    }
    
    func getContentView() -> UIView {
        if contentView == nil {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(containerView)
            
            // Add proper constraints
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: view.topAnchor),
                containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            contentView = containerView
        }
        return contentView!
    }
}

// MARK: - DCFComponent Protocol Implementation

extension DCFStackNavigatorComponent {
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        // Apply the layout to the view
        let newFrame = CGRect(
            x: CGFloat(layout.left),
            y: CGFloat(layout.top),
            width: CGFloat(layout.width),
            height: CGFloat(layout.height)
        )
        
        // Update frame and force layout for the entire navigation controller
        view.frame = newFrame
        navigationController.view.frame = view.bounds
        navigationController.view.setNeedsLayout()
        navigationController.view.layoutIfNeeded()
        
        // Update safe area insets if needed for proper layout
        if #available(iOS 11.0, *) {
            for viewController in navigationController.viewControllers {
                viewController.additionalSafeAreaInsets = .zero
            }
        }
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        // Stack navigator doesn't have intrinsic size, it takes the full space available
        return CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Store the node ID for later use
        self.componentId = nodeId
    }
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // Store the event callback
        self.eventCallback = eventCallback
        self.componentId = viewId
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // Clear the event callback if we're removing listeners for this view
        if viewId == self.componentId {
            self.eventCallback = nil
        }
    }
    
    func triggerEvent(on view: UIView, eventType: String, eventData: [String: Any]) {
        // Forward to the registered callback
        if let componentId = self.componentId {
            self.eventCallback?(componentId, eventType, eventData)
        }
    }
}
