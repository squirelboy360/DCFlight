import UIKit
import yoga

/// Visualization tool for debugging layout issues
class LayoutDebugVisualizer {
    /// Shared instance
    static let shared = LayoutDebugVisualizer()
    
    /// Whether debug visualization is enabled
    private var isEnabled = false
    
    /// Debug labels
    private var debugLabels = [UIView: UILabel]()
    
    /// Debug borders (original border info to restore when disabled)
    private var originalBorders = [UIView: (color: CGColor?, width: CGFloat)]()
    
    /// Private initializer
    private init() {
        // Check if debug is enabled via environment variable or user defaults
        isEnabled = ProcessInfo.processInfo.environment["DCMAUI_DEBUG_LAYOUT"] == "1" ||
                   UserDefaults.standard.bool(forKey: "DCMauiDebugLayout")
    }
    
    /// Enable or disable debug visualization
    func setEnabled(_ enabled: Bool) {
        if enabled == isEnabled { return }
        
        isEnabled = enabled
        
        // Store setting in UserDefaults
        UserDefaults.standard.set(enabled, forKey: "DCMauiDebugLayout")
        
        // Apply or remove visualization from all views
        if enabled {
            applyToAllViews()
        } else {
            removeFromAllViews()
        }
    }
    
    /// Apply debug visualization to all views
    private func applyToAllViews() {
        guard let rootView = UIApplication.shared.windows.first?.rootViewController?.view else { return }
        
        // Start at the root and traverse the view hierarchy
        applyToViewHierarchy(rootView)
    }
    
    /// Remove debug visualization from all views
    private func removeFromAllViews() {
        // Remove all debug labels
        for (view, label) in debugLabels {
            label.removeFromSuperview()
        }
        debugLabels.removeAll()
        
        // Restore original borders
        for (view, borderInfo) in originalBorders {
            view.layer.borderColor = borderInfo.color
            view.layer.borderWidth = borderInfo.width
        }
        originalBorders.removeAll()
    }
    
    /// Apply debug visualization to view hierarchy
    private func applyToViewHierarchy(_ view: UIView) {
        // Store original border info
        originalBorders[view] = (view.layer.borderColor, view.layer.borderWidth)
        
        // Add a unique color border
        view.layer.borderColor = randomColor().cgColor
        view.layer.borderWidth = 1.0
        
        // Add debug label
        let label = createDebugLabel(for: view)
        view.addSubview(label)
        debugLabels[view] = label
        
        // Process children
        for subview in view.subviews {
            applyToViewHierarchy(subview)
        }
    }
    
    /// Create a debug label for a view
    private func createDebugLabel(for view: UIView) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 8)
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        // Get node ID if available or try to calculate a description
        let nodeId = getNodeIdFromView(view) ?? "unknown"
        let viewType = String(describing: type(of: view))
        let dimensions = "\(Int(view.frame.width))×\(Int(view.frame.height))"
        
        label.text = "\(nodeId)\n\(dimensions)"
        label.numberOfLines = 2
        label.textAlignment = .center
        
        // Position at bottom-right corner
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -1),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -1),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: 100)
        ])
        
        return label
    }
    
    /// Generate a random color for debugging
    private func randomColor() -> UIColor {
        let hue = CGFloat.random(in: 0...1)
        return UIColor(hue: hue, saturation: 0.8, brightness: 0.8, alpha: 0.7)
    }
    
    /// Log layout hierarchy to console
    func logViewHierarchy(startingAt view: UIView? = nil, depth: Int = 0) {
        let rootView = view ?? UIApplication.shared.windows.first?.rootViewController?.view
        guard let startView = rootView else { return }
        
        printViewHierarchy(startView, depth: depth)
    }
    
    /// Print view hierarchy with indentation
    private func printViewHierarchy(_ view: UIView, depth: Int) {
        let indent = String(repeating: "  ", count: depth)
        let nodeId = getNodeIdFromView(view) ?? "unknown"
        let frame = view.frame
        
        print("\(indent)🟦 \(nodeId): \(frame.width)×\(frame.height) at (\(frame.minX), \(frame.minY))")
        
        for subview in view.subviews {
            printViewHierarchy(subview, depth: depth + 1)
        }
    }
    
    /// Get node ID from a view using objc_getAssociatedObject directly
    private func getNodeIdFromView(_ view: UIView) -> String? {
        return objc_getAssociatedObject(view, UnsafeRawPointer(bitPattern: "nodeId".hashValue)!) as? String
    }
}

// Add extension to YogaShadowTree to expose needed functionality
extension YogaShadowTree {
    /// Get children IDs for a node
    func getChildrenIds(for nodeId: String) -> [String] {
        return nodeParents.filter { $0.value == nodeId }.map { $0.key }
    }
    
    /// Get debug visualizer
    func getDebugVisualizer() -> LayoutDebugVisualizer {
        return LayoutDebugVisualizer.shared
    }
}

// Extension to UIView for node ID access
extension UIView {
    /// Node ID accessor
    var nodeId: String? {
        get {
            return objc_getAssociatedObject(self, 
                                          UnsafeRawPointer(bitPattern: "nodeId".hashValue)!) as? String
        }
        set {
            objc_setAssociatedObject(self, 
                                   UnsafeRawPointer(bitPattern: "nodeId".hashValue)!, 
                                   newValue, 
                                   .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
