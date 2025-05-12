import UIKit
import dcflight

class DCFTabNavigatorComponent: NSObject, DCFComponent, ComponentMethodHandler, UITabBarControllerDelegate {
    // The tab bar controller
    private let tabBarController = UITabBarController()
    
    // Tab configuration
    private var tabConfigurations: [[String: Any]] = []
    
    // Navigation controllers for each tab
    private var tabNavigationControllers: [UINavigationController] = []
    
    // Observer for tab changes
    private var tabChangeObserver: ((Int) -> Void)?
    
    required override init() {
        super.init()
        tabBarController.delegate = self
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Configure tab bar controller with initial props
        updateView(tabBarController.view, withProps: props)
        
        return tabBarController.view
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Configure tab bar appearance
        if let tabBarBackgroundColor = props["tabBarBackgroundColor"] as? String {
            tabBarController.tabBar.barTintColor = ColorUtilities.color(fromHexString: tabBarBackgroundColor)
        }
        
        if let tabTextColor = props["tabTextColor"] as? String {
            tabBarController.tabBar.unselectedItemTintColor = ColorUtilities.color(fromHexString: tabTextColor)
        }
        
        if let selectedTabTextColor = props["selectedTabTextColor"] as? String {
            tabBarController.tabBar.tintColor = ColorUtilities.color(fromHexString: selectedTabTextColor)
        }
        
        // Set tab position (only for iOS 13+)
        if #available(iOS 13.0, *) {
            if let tabBarPosition = props["tabBarPosition"] as? String {
                // Only "top" is non-standard and requires special handling on iOS
                // Standard position is bottom
            }
        }
        
        // Show/hide tab bar
        if let showTabBar = props["showTabBar"] as? Bool {
            tabBarController.tabBar.isHidden = !showTabBar
        }
        
        // Set up tabs
        if let tabsConfig = props["tabs"] as? [[String: Any]], !tabsConfig.isEmpty {
            setupTabs(tabsConfig)
        }
        
        // Set initial tab
        if let initialTabIndex = props["initialTabIndex"] as? Int {
            if initialTabIndex >= 0 && initialTabIndex < tabBarController.viewControllers?.count ?? 0 {
                tabBarController.selectedIndex = initialTabIndex
            }
        }
        
        return true
    }
    
    private func setupTabs(_ tabConfigurations: [[String: Any]]) {
        self.tabConfigurations = tabConfigurations
        
        // Create view controllers for each tab
        var viewControllers: [UIViewController] = []
        
        for (index, tabConfig) in tabConfigurations.enumerated() {
            let title = tabConfig["title"] as? String ?? "Tab \(index + 1)"
            let icon = tabConfig["icon"] as? String
            let selectedIcon = tabConfig["selectedIcon"] as? String
            
            // Create a container view controller for this tab
            let tabViewController = TabViewController(tabIndex: index, title: title)
            
            // Wrap in a navigation controller for consistent navigation
            let navController = UINavigationController(rootViewController: tabViewController)
            navController.navigationBar.prefersLargeTitles = true
            
            // Configure tab bar item
            tabViewController.tabBarItem = UITabBarItem(title: title, image: nil, tag: index)
            
            // Set icon if provided
            if let iconName = icon {
                tabViewController.tabBarItem.image = UIImage(named: iconName)
            }
            
            // Set selected icon if provided
            if let selectedIconName = selectedIcon {
                tabViewController.tabBarItem.selectedImage = UIImage(named: selectedIconName)
            }
            
            viewControllers.append(navController)
            tabNavigationControllers.append(navController)
        }
        
        // Set all tabs
        tabBarController.setViewControllers(viewControllers, animated: false)
    }
    
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        switch methodName {
        case "switchTab":
            if let index = args["index"] as? Int {
                return switchTab(index: index)
            }
            return false
            
        case "getSelectedIndex":
            return (tabBarController.selectedIndex != 0)
            
        default:
            return false
        }
    }
    
    // MARK: - Tab Methods
    
    private func switchTab(index: Int) -> Bool {
        if index >= 0 && index < tabBarController.viewControllers?.count ?? 0 {
            tabBarController.selectedIndex = index
            return true
        }
        return false
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Notify Dart side of tab change
        print("Tab selected: \(tabBarController.selectedIndex)")
        
        // Send event to DCFlight
        let eventData: [String: Any] = ["index": tabBarController.selectedIndex]
        DCFEventBridge.shared.sendEvent(name: "onTabChange", data: eventData)
    }
}

// MARK: - Tab View Controller

/// A view controller that represents a tab
class TabViewController: UIViewController {
    private let tabIndex: Int
    private var contentView: UIView?
    
    init(tabIndex: Int, title: String) {
        self.tabIndex = tabIndex
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Create a container view for tab content
        let containerView = UIView(frame: view.bounds)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(containerView)
        contentView = containerView
        
        // Tab content will be set by DCFlight framework
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
