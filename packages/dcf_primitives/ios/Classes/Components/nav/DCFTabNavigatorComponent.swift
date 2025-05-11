import UIKit
import dcflight

// MARK: - Internal Tab Component

/// Component implementation for _TabComponent - used internally by TabNavigator
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

// MARK: - Tab Navigator Component

class DCFTabNavigatorComponent: NSObject, DCFComponent, ComponentMethodHandler, UITabBarControllerDelegate {
    // Keep track of active tab controllers
    private static var activeTabControllers = [String: UITabBarController]()
    
    // Keep track of tab configurations by tab controller
    private static var tabConfigsByNavigator = [String: [[String: Any]]]()
    
    // Keep track of tab views by tab ID
    static var tabViewsByTabId = [String: UIView]()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a tab bar controller with our custom safe implementation
        let tabBarController = DCFSafeTabBarController()
        tabBarController.delegate = self
        
        // Extract tab configurations
        if let tabs = props["tabs"] as? [[String: Any]] {
            // Create view controllers for tabs
            var viewControllers: [UIViewController] = []
            
            for (index, tabConfig) in tabs.enumerated() {
                // Create a placeholder view controller for the tab
                let tabViewController = DCFTabViewController()
                tabViewController.title = tabConfig["title"] as? String
                tabViewController.tabId = tabConfig["id"] as? String
                
                // Create tab bar item
                let tabBarItem = UITabBarItem(
                    title: tabConfig["title"] as? String,
                    image: getImage(from: tabConfig["icon"] as? String),
                    selectedImage: getImage(from: tabConfig["selectedIcon"] as? String)
                )
                tabViewController.tabBarItem = tabBarItem
                
                // Find the tab's content view
                if let tabId = tabConfig["id"] as? String, 
                   let tabView = DCFTabNavigatorComponent.tabViewsByTabId[tabId] {
                    print("✅ Found tab view for \(tabId), adding to tab controller")
                    tabViewController.addContent(tabView)
                } else if let tabId = tabConfig["id"] as? String {
                    print("⚠️ Tab view not found for \(tabId) - tab will be empty")
                }
                
                viewControllers.append(tabViewController)
            }
            
            // Set the view controllers
            tabBarController.viewControllers = viewControllers
            
            // Set initial selected index
            if let initialIndex = props["initialIndex"] as? Int, 
               initialIndex < viewControllers.count {
                tabBarController.selectedIndex = initialIndex
            }
        }
        
        // Apply props
        _ = updateView(tabBarController.view, withProps: props)
        
        // Create a simple container view for the tab controller
        let containerView = SafeContainerView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        containerView.backgroundColor = UIColor.clear
        
        // Store the tab controller with this container view
        objc_setAssociatedObject(containerView, 
                               UnsafeRawPointer(bitPattern: "tabController".hashValue)!, 
                               tabBarController, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // CRITICAL FIX: Use autoresizing mask instead of constraints
        tabBarController.view.frame = containerView.bounds
        tabBarController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(tabBarController.view)
        
        return containerView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Find the tab controller for this view
        guard let tabBarController = findTabController(for: view) else {
            return false
        }
        
        // Store initial props for potential use later
        objc_setAssociatedObject(view, 
                               UnsafeRawPointer(bitPattern: "initialProps".hashValue)!, 
                               props, 
                               .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Apply tab bar visibility
        if let tabBarHidden = props["tabBarHidden"] as? Bool {
            tabBarController.tabBar.isHidden = tabBarHidden
        }
        
        // Apply tint color
        if let tintColor = props["tintColor"] as? String {
            tabBarController.tabBar.tintColor = ColorUtilities.color(fromHexString: tintColor)
        }
        
        // Apply unselected tint color
        if let unselectedTintColor = props["unselectedTintColor"] as? String {
            tabBarController.tabBar.unselectedItemTintColor = ColorUtilities.color(fromHexString: unselectedTintColor)
        }
        
        // Store tab configurations
        if let tabs = props["tabs"] as? [[String: Any]], let viewId = getViewId(for: view) {
            DCFTabNavigatorComponent.tabConfigsByNavigator[viewId] = tabs
        }
        
        return true
    }
    
    // Get an image from an image name
    private func getImage(from imageName: String?) -> UIImage? {
        guard let imageName = imageName else {
            return nil
        }
        
        // Check for system images first (SF Symbols)
        if #available(iOS 13.0, *), imageName.hasPrefix("system:") {
            let systemName = imageName.replacingOccurrences(of: "system:", with: "")
            return UIImage(systemName: systemName)
        }
        
        // Try to get an image from the bundle
        return UIImage(named: imageName)
    }
    
    // Handle TabNavigator-specific methods
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        // Get the view ID associated with this view
        guard let viewId = getViewId(for: view),
              let tabBarController = DCFTabNavigatorComponent.activeTabControllers[viewId] else {
            print("❌ Cannot handle method for tab navigator: missing viewId or tab controller")
            return false
        }
        
        switch methodName {
        case "switchToTab":
            if let index = args["index"] as? Int, 
               index < tabBarController.viewControllers?.count ?? 0 {
                tabBarController.selectedIndex = index
                return true
            }
            return false
            
        case "switchToTabWithId":
            if let tabId = args["tabId"] as? String,
               let viewControllers = tabBarController.viewControllers as? [DCFTabViewController] {
                // Find the view controller with the matching tab ID
                for (index, vc) in viewControllers.enumerated() {
                    if vc.tabId == tabId {
                        tabBarController.selectedIndex = index
                        return true
                    }
                }
            }
            return false
            
        case "setBadge":
            if let index = args["index"] as? Int,
               let viewControllers = tabBarController.viewControllers,
               index < viewControllers.count {
                // Set badge string
                let badge = args["badge"] as? String
                viewControllers[index].tabBarItem.badgeValue = badge
                return true
            }
            return false
            
        case "setTabBarHidden":
            let hidden = args["hidden"] as? Bool ?? false
            let animated = args["animated"] as? Bool ?? true
            
            if animated {
                UIView.animate(withDuration: 0.3) {
                    tabBarController.tabBar.isHidden = hidden
                }
            } else {
                tabBarController.tabBar.isHidden = hidden
            }
            return true
            
        default:
            return false
        }
    }
    
    // Find the tab controller for a view
    private func findTabController(for view: UIView) -> UITabBarController? {
        // First, check if this view has an associated tab controller
        if let tabBarController = objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "tabController".hashValue)!) as? UITabBarController {
            return tabBarController
        }
        
        // Otherwise, check if this view belongs directly to a tab controller
        if let tabBarController = view.next as? UITabBarController {
            return tabBarController
        }
        
        // Finally, look through active tab controllers
        if let viewId = getViewId(for: view), 
           let tabBarController = DCFTabNavigatorComponent.activeTabControllers[viewId] {
            return tabBarController
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
        
        // Find the tab controller
        if let tabBarController = view.next as? UITabBarController {
            // Store in active tab controllers
            DCFTabNavigatorComponent.activeTabControllers[nodeId] = tabBarController
        }
    }
    
    // MARK: - Tab Bar Controller Delegate
    
    func tabBarController(_ tabBarController: UITabBarController, 
                        didSelect viewController: UIViewController) {
        // Get the selected tab ID and index
        let selectedIndex = tabBarController.selectedIndex
        var selectedTabId = ""
        
        if let tabVC = viewController as? DCFTabViewController, let tabId = tabVC.tabId {
            selectedTabId = tabId
        }
        
        // Find the view and view ID for this tab controller
        var navigatorView: UIView? = tabBarController.view
        var navigatorViewId: String? = nil
        
        // Search through active tab controllers to find the matching view ID
        for (viewId, controller) in DCFTabNavigatorComponent.activeTabControllers {
            if controller === tabBarController {
                navigatorViewId = viewId
                break
            }
        }
        
        // Trigger tab change event
        if let navigatorView = navigatorView, let navigatorViewId = navigatorViewId {
            triggerEvent(on: navigatorView, eventType: "onTabChange", eventData: [
                "index": selectedIndex,
                "tabId": selectedTabId
            ])
            
            print("✅ Tab changed: index=\(selectedIndex), tabId=\(selectedTabId), viewId=\(navigatorViewId)")
        }
    }
    
    // MARK: - Layout Management
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        // Apply frame to the container view
        view.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
        
        // If this is a tab container, make sure internal view fills it
        if let tabBarController = findTabController(for: view) {
            tabBarController.view.frame = view.bounds
            
            // CRITICAL FIX: Reset any internal constraints that might be causing conflicts
            for subview in tabBarController.view.subviews {
                if let tabBar = subview as? UITabBar {
                    tabBar.setNeedsLayout()
                }
            }
        }
    }
}


// Custom view controller for tab screens
class DCFTabViewController: UIViewController {
    // Tab identifier
    var tabId: String?
    
    // Content view for tab content
    let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up content view
        contentView.backgroundColor = UIColor.white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // Add content to the tab
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
