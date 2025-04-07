import UIKit
import yoga

/// Manages layout for DCMAUI components using Yoga
/// Under the React Native-style architecture, layout calculations happen on the native side
class DCMauiLayoutManager {
    // Singleton instance
    static let shared = DCMauiLayoutManager()
    
    // Flag indicating if layout needs recalculation
    private var _needsLayout: Bool = false
    
    // Root view dimensions
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    private var screenHeight: CGFloat = UIScreen.main.bounds.height
    
    // Layout calculation throttling
    private var lastLayoutCalculation: Date = Date.distantPast
    private let minimumLayoutInterval: TimeInterval = 1.0 / 120.0 // 120fps max
    
    // Timer for batching layout updates
    private var layoutTimer: Timer?
    
    // Map view IDs to actual UIViews for direct access
    private var viewRegistry = [String: UIView]()
    
    // Private initializer for singleton
    private init() {
        // Set up layout update timer
        layoutTimer = Timer.scheduledTimer(withTimeInterval: minimumLayoutInterval, repeats: true) { [weak self] _ in
            self?.layoutTimerFired()
        }
        layoutTimer?.tolerance = minimumLayoutInterval / 2
        RunLoop.main.add(layoutTimer!, forMode: .common)
        
        // Listen for orientation changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    deinit {
        layoutTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Registry Management
    
    /// Register a view with an ID
    func registerView(_ view: UIView, withId viewId: String) {
        viewRegistry[viewId] = view
    }
    
    /// Unregister a view
    func unregisterView(withId viewId: String) {
        viewRegistry.removeValue(forKey: viewId)
    }
    
    /// Get view by ID
    func getView(withId viewId: String) -> UIView? {
        return viewRegistry[viewId]
    }
    
    // MARK: - Layout Management
    
    /// Mark that layout needs to be recalculated
    func setNeedsLayout() {
        _needsLayout = true
    }
    
    /// Layout timer callback
    @objc private func layoutTimerFired() {
        if _needsLayout && Date().timeIntervalSince(lastLayoutCalculation) >= minimumLayoutInterval {
            performLayoutCalculation()
            _needsLayout = false
        }
    }
    
    /// Handle orientation changes
    @objc private func orientationChanged() {
        // Update screen dimensions after orientation change
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.screenWidth = UIScreen.main.bounds.width
            self.screenHeight = UIScreen.main.bounds.height
            self.setNeedsLayout()
            print("Orientation changed, new dimensions: \(self.screenWidth)x\(self.screenHeight)")
        }
    }
    
    /// Force layout calculation immediately
    func calculateLayoutNow() {
        if !_needsLayout { return }
        
        performLayoutCalculation()
        _needsLayout = false
    }
    
    /// Update screen dimensions and trigger layout
    func updateScreenDimensions(width: CGFloat, height: CGFloat) {
        screenWidth = width
        screenHeight = height
        setNeedsLayout()
    }
    
    /// Perform actual layout calculation
    private func performLayoutCalculation() {
        lastLayoutCalculation = Date()
        
        // Calculate layout using Yoga shadow tree
        YogaShadowTree.shared.calculateLayout(
            width: Float(screenWidth),
            height: Float(screenHeight)
        )
        
        print("Layout calculation completed for \(screenWidth)x\(screenHeight)")
    }
    
    // MARK: - Node Management
    
    /// Create or update a node with layout props
    func updateNodeWithLayoutProps(nodeId: String, componentType: String, props: [String: Any]) {
        let shadowTree = YogaShadowTree.shared
        
        // Create node if it doesn't exist
        if !shadowTree.hasNode(id: nodeId) {
            _ = shadowTree.createNode(id: nodeId, componentType: componentType)
        }
        
        // Apply layout properties
        shadowTree.applyLayoutProps(nodeId: nodeId, props: props)
        
        // Mark that layout needs to be recalculated
        setNeedsLayout()
    }
    
    /// Register a view with the layout system
    func registerView(_ view: UIView, withNodeId nodeId: String, componentType: String, componentInstance: DCMauiComponent) {
        YogaShadowTree.shared.associateView(view, withNodeId: nodeId, componentType: componentType, componentInstance: componentInstance)
        registerView(view, withId: nodeId) // Register in view registry
    }
    
    /// Add a child node to a parent node
    func addChildNode(parentId: String, childId: String, index: Int) {
        YogaShadowTree.shared.addChild(parentId: parentId, childId: childId, index: index)
        setNeedsLayout()
    }
    
    /// Remove a node from the layout system
    func removeNode(nodeId: String) {
        YogaShadowTree.shared.removeNode(id: nodeId)
        unregisterView(withId: nodeId)
        setNeedsLayout()
    }
    
    // MARK: - Style Application
    
    /// Apply styles to a view
    func applyStyles(to view: UIView, props: [String: Any]) {
        // Extract only style-related properties
        let styleProps = props.filter { key, _ in
            // Check if it's a style property (not layout)
            return !LayoutProps.all.contains(key) || key == "borderWidth"
        }
        
        // Apply styles using the UIView extension
        if !styleProps.isEmpty {
            view.applyStyles(props: styleProps)
        }
    }
}

/// Static list of layout property names
class LayoutProps {
    static let all = [
        "width", "height", "minWidth", "maxWidth", "minHeight", "maxHeight",
        "margin", "marginTop", "marginRight", "marginBottom", "marginLeft",
        "marginHorizontal", "marginVertical",
        "padding", "paddingTop", "paddingRight", "paddingBottom", "paddingLeft",
        "paddingHorizontal", "paddingVertical",
        "left", "top", "right", "bottom", "position",
        "flexDirection", "justifyContent", "alignItems", "alignSelf", "alignContent",
        "flexWrap", "flex", "flexGrow", "flexShrink", "flexBasis",
        "display", "overflow", "direction"
    ]
}
