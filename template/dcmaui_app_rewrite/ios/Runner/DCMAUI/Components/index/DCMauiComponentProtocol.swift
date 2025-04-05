import UIKit
import yoga

/// Protocol that all DCMAUI components must implement
protocol DCMauiComponent {
    /// Initialize the component
    init()
    
    /// Create a view with the given props
    func createView(props: [String: Any]) -> UIView
    
    /// Update a view with new props
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool
    
    /// Add event listeners to a view
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                         eventCallback: @escaping (String, String, [String: Any]) -> Void)
    
    /// Remove event listeners from a view
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String])
}

// To resolve initializer requirement issues, make the extension provide a default implementation
extension DCMauiComponent {
    // Default implementation for addEventListeners - do nothing by default
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // Default implementation does nothing
    }
    
    // Default implementation for removeEventListeners - do nothing by default
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // Default implementation does nothing
    }
}