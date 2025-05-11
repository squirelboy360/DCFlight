import UIKit
import dcflight

/// Component implementation for _RouteComponent used by StackNavigator
class DCFRouteComponent: NSObject, DCFComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a container view for route content
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        
        // Store route ID with the view
        if let routeId = props["id"] as? String {
            print("⚙️ Creating _RouteComponent view for route: \(routeId)")
            objc_setAssociatedObject(containerView, 
                                   UnsafeRawPointer(bitPattern: "routeId".hashValue)!, 
                                   routeId, 
                                   .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // Store the view in the route views dictionary
            DCFStackNavigatorComponent.routeViewsByRouteId[routeId] = containerView
            print("✅ Stored route view for routeId: \(routeId)")
        } else {
            print("⚠️ _RouteComponent created without route ID")
        }
        
        return containerView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Not much to update here as this is mostly a container
        return true
    }
}
