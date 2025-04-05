import UIKit
import yoga

class DCMauiViewComponent: NSObject, DCMauiComponent {
    // Required initializer to conform to DCMauiComponent
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a new UIView
        let view = UIView()
        
        // Apply styling directly using the UIView extension
        view.applyStyles(props: props)
        
        // Return the view (layout will be applied directly by layout manager)
        return view
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Apply styling directly using the UIView extension
        view.applyStyles(props: props)
        return true
    }
    
    // Add missing required methods from the protocol
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                         eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // Views typically don't have events, but we could add tap gestures if needed
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // Clean up any event listeners if added
    }
}

// Helper extension for gesture handling
extension UITapGestureRecognizer {
    private class ActionHandler {
        let action: (UITapGestureRecognizer) -> Void
        
        init(action: @escaping (UITapGestureRecognizer) -> Void) {
            self.action = action
        }
        
        @objc func handleTap(sender: UITapGestureRecognizer) {
            action(sender)
        }
    }
    
    private struct AssociatedKeys {
        static var actionHandler = "ActionHandler"
    }
    
    private var actionHandler: ActionHandler? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.actionHandler) as? ActionHandler
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.actionHandler, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addTarget(action: @escaping (UITapGestureRecognizer) -> Void) {
        actionHandler = ActionHandler(action: action)
        addTarget(actionHandler, action: #selector(ActionHandler.handleTap))
    }
}
