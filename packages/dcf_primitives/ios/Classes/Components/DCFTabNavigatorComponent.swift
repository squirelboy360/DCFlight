import UIKit
import dcflight
import yoga

class DCFTabNavigatorComponent: NSObject, DCFComponent, ComponentMethodHandler, UITabBarControllerDelegate {
    // The tab bar controller
    private let tabBarController = UITabBarController()
    
    // Tab configuration
    private var tabConfigurations: [[String: Any]] = []
    
    // Navigation controllers for each tab
    private var tabNavigationControllers: [UINavigationController] = []
    
    // Event callback for handling events
    private var eventCallback: ((String, String, [String: Any]) -> Void)?
    private var componentId: String?
    
    required override init() {
        super.init()
        tabBarController.delegate = self
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a container view that will hold the tab bar controller's view
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        containerView.backgroundColor = .clear
        
        // Add the tab bar controller's view to the container
        tabBarController.view.frame = containerView.bounds
        tabBarController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(tabBarController.view)
        
        // Configure tab bar controller with initial props
        updateView(containerView, withProps: props)
        
        return containerView
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
        
        // Force layout update to handle orientation changes
        if let containerView = view as? UIView {
            tabBarController.view.frame = containerView.bounds
            tabBarController.view.setNeedsLayout()
            tabBarController.view.layoutIfNeeded()
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
        
        // Get the proper view to trigger the event on (tabBarController.view)
        let eventData: [String: Any] = ["index": tabBarController.selectedIndex]
        
        // Use the standard event mechanism through the DCFComponent protocol
        // This will properly route through the centralized event system
        triggerEvent(on: tabBarController.view, eventType: "onTabChange", eventData: eventData)
    }
}

// MARK: - DCFComponent Protocol Implementation

extension DCFTabNavigatorComponent {
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        // Apply the layout to the view
        let newFrame = CGRect(
            x: CGFloat(layout.left),
            y: CGFloat(layout.top),
            width: CGFloat(layout.width),
            height: CGFloat(layout.height)
        )
        
        // Update frame and force layout for the entire tab bar controller
        view.frame = newFrame
        tabBarController.view.frame = view.bounds
        tabBarController.view.setNeedsLayout()
        tabBarController.view.layoutIfNeeded()
        
        // Update safe area insets if needed for proper layout
        if #available(iOS 11.0, *) {
            for viewController in tabBarController.viewControllers ?? [] {
                viewController.additionalSafeAreaInsets = .zero
            }
        }
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        // Tab navigator doesn't have intrinsic size, it takes the full space available
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
        
        // Create a container view for tab content with proper constraints
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
