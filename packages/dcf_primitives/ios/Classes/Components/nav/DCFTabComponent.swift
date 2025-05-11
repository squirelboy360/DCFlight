import UIKit
import dcflight

/// Component implementation for _TabComponent used by TabNavigator
class DCFTabComponent: NSObject, DCFComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a container view for tab content
        let containerView = UIView()
        containerView.backgroundColor = UIColor.clear
        
        // Store tab ID with the view
        if let tabId = props["id"] as? String {
            print("⚙️ Creating _TabComponent view for tab: \(tabId)")
            objc_setAssociatedObject(containerView, 
                                   UnsafeRawPointer(bitPattern: "tabId".hashValue)!, 
                                   tabId, 
                                   .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            // Store the view in the tab views dictionary
            DCFTabNavigatorComponent.tabViewsByTabId[tabId] = containerView
            print("✅ Stored tab view for tabId: \(tabId)")
        } else {
            print("⚠️ _TabComponent created without tab ID")
        }
        
        return containerView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Not much to update here as this is mostly a container
        return true
    }
}
