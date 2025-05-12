import UIKit

/// Protocol for navigation handling in native components
public protocol DCFNavigationHandler {
    /// Push a new route onto the navigation stack
    func pushRoute(routeInfo: [String: Any], transition: [String: Any]?) -> Bool
    
    /// Pop the current route from the navigation stack
    func popRoute(result: Any?) -> Bool
    
    /// Replace the current route with a new one
    func replaceRoute(routeInfo: [String: Any], transition: [String: Any]?) -> Bool
    
    /// Pop to the root route
    func popToRootRoute(animated: Bool) -> Bool
    
    /// Select a specific tab (for tab navigation)
    func selectTab(index: Int) -> Bool
}

/// Route transition configuration
public struct DCFRouteTransition {
    public enum TransitionType: String {
        case platform = "platform"
        case fade = "fade"
        case slideRight = "slideRight"
        case slideLeft = "slideLeft"
        case slideTop = "slideTop"
        case slideBottom = "slideBottom"
        case none = "none"
    }
    
    public let type: TransitionType
    public let durationMs: Int
    
    public init(dictionary: [String: Any]) {
        let typeString = dictionary["type"] as? String ?? "platform"
        self.type = TransitionType(rawValue: typeString) ?? .platform
        self.durationMs = dictionary["durationMs"] as? Int ?? 300
    }
}

/// Helper class for navigation-related utilities
public class DCFNavigationUtilities {
    /// Convert a route dictionary to a ViewController
    public static func viewControllerForRoute(routeInfo: [String: Any]) -> UIViewController? {
        // This would be implemented by specific navigation components
        return nil
    }
    
    /// Apply a transition to a view controller presentation
    public static func applyTransition(_ transition: DCFRouteTransition, to viewController: UIViewController) {
        // Set transition style based on type
        switch transition.type {
        case .fade:
            viewController.modalTransitionStyle = .crossDissolve
        case .slideBottom:
            viewController.modalTransitionStyle = .coverVertical
        case .none:
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .overCurrentContext
        default:
            // Use platform default
            viewController.modalTransitionStyle = .coverVertical
        }
    }
}
