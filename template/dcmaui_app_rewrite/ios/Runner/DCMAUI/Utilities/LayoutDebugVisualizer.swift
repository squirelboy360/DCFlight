import UIKit
import yoga

/// Utility class for visualizing and debugging layout issues
class LayoutDebugVisualizer {
    /// Singleton instance
    static let shared = LayoutDebugVisualizer()
    
    /// Whether visualization is currently enabled
    private(set) var isEnabled = false
    
    /// Color palette for visualization
    private let colors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen,
        .systemOrange, .systemPurple, .systemTeal,
        .systemYellow, .systemPink
    ]
    
    /// Initialize with default settings
    private init() {
        // Check if debug is enabled via environment variable or user defaults
        isEnabled = ProcessInfo.processInfo.environment["DCMAUI_DEBUG_LAYOUT"] == "1" ||
                   UserDefaults.standard.bool(forKey: "DCMauiDebugLayout")
    }
    
    /// Enable or disable layout visualization
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        
        // Store setting in UserDefaults
        UserDefaults.standard.set(enabled, forKey: "DCMauiDebugLayout")
        
        // Update YogaShadowTree debug state
        YogaShadowTree.shared.setDebugLayoutEnabled(enabled)
    }
    
    /// Add debug visualization to a view
    func visualizeView(_ view: UIView, nodeId: String, level: Int = 0) {
        guard isEnabled else { return }
        
        DispatchQueue.main.async {
            // Remove existing debug views first
            view.subviews.forEach { subview in
                if subview.tag >= 90000 && subview.tag <= 90010 {
                    subview.removeFromSuperview()
                }
            }
            
            // Define color based on level in hierarchy
            let color = self.colors[level % self.colors.count]
            
            // Add colored border
            view.layer.borderColor = color.cgColor
            view.layer.borderWidth = 1.0
            
            // Create debug overlay
            let overlay = UIView(frame: .zero)
            overlay.backgroundColor = color.withAlphaComponent(0.1)
            overlay.isUserInteractionEnabled = false
            overlay.tag = 90000
            view.insertSubview(overlay, at: 0)
            
            // Position overlay to fill view
            overlay.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                overlay.topAnchor.constraint(equalTo: view.topAnchor),
                overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            
            // Create info label
            let infoLabel = UILabel()
            infoLabel.text = "ID: \(nodeId)\nSize: \(Int(view.bounds.width))×\(Int(view.bounds.height))"
            infoLabel.font = UIFont.systemFont(ofSize: 10)
            infoLabel.textColor = .white
            infoLabel.backgroundColor = color.withAlphaComponent(0.7)
            infoLabel.layer.cornerRadius = 4
            infoLabel.clipsToBounds = true
            infoLabel.numberOfLines = 0
            infoLabel.textAlignment = .center
            infoLabel.tag = 90001
            infoLabel.isUserInteractionEnabled = false
            view.addSubview(infoLabel)
            
            // Position label
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                infoLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 2),
                infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2),
                infoLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
            ])
        }
    }
    
    /// Visualize padding areas
    func visualizePadding(_ view: UIView, top: CGFloat, right: CGFloat, bottom: CGFloat, left: CGFloat) {
        guard isEnabled, top > 0 || right > 0 || bottom > 0 || left > 0 else { return }
        
        DispatchQueue.main.async {
            // Create padding indicators as colored areas
            let createPaddingView = { (color: UIColor, tag: Int) -> UIView in
                let view = UIView()
                view.backgroundColor = color.withAlphaComponent(0.3)
                view.tag = tag
                view.isUserInteractionEnabled = false
                return view
            }
            
            // Remove existing padding visualizers
            for tag in 90002...90005 {
                view.viewWithTag(tag)?.removeFromSuperview()
            }
            
            // Top padding
            if top > 0 {
                let topView = createPaddingView(.systemBlue, 90002)
                view.addSubview(topView)
                topView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    topView.topAnchor.constraint(equalTo: view.topAnchor),
                    topView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    topView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    topView.heightAnchor.constraint(equalToConstant: top)
                ])
            }
            
            // Right padding
            if right > 0 {
                let rightView = createPaddingView(.systemGreen, 90003)
                view.addSubview(rightView)
                rightView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    rightView.topAnchor.constraint(equalTo: view.topAnchor),
                    rightView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    rightView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    rightView.widthAnchor.constraint(equalToConstant: right)
                ])
            }
            
            // Bottom padding
            if bottom > 0 {
                let bottomView = createPaddingView(.systemOrange, 90004)
                view.addSubview(bottomView)
                bottomView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    bottomView.heightAnchor.constraint(equalToConstant: bottom)
                ])
            }
            
            // Left padding
            if left > 0 {
                let leftView = createPaddingView(.systemPurple, 90005)
                view.addSubview(leftView)
                leftView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    leftView.topAnchor.constraint(equalTo: view.topAnchor),
                    leftView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    leftView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                    leftView.widthAnchor.constraint(equalToConstant: left)
                ])
            }
        }
    }
    
    /// Take a screenshot of the current layout for debugging
    func captureLayoutSnapshot() -> UIImage? {
        guard let rootView = UIApplication.shared.keyWindow else { return nil }
        
        UIGraphicsBeginImageContextWithOptions(rootView.bounds.size, false, 0.0)
        rootView.drawHierarchy(in: rootView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Save to documents directory for easier access
        if let image = image, let data = image.pngData() {
            let fileManager = FileManager.default
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let timestamp = Int(Date().timeIntervalSince1970)
            let filePath = "\(documentsPath)/layout_debug_\(timestamp).png"
            
            do {
                try data.write(to: URL(fileURLWithPath: filePath))
                print("📸 Layout snapshot saved to: \(filePath)")
            } catch {
                print("❌ Failed to save snapshot: \(error)")
            }
        }
        
        return image
    }
    
    /// Generate a layout report for the current view hierarchy
    func generateLayoutReport() -> String {
        var report = "DCMAUI Layout Debug Report\n"
        report += "========================\n"
        report += "Generated: \(Date())\n\n"
        
        // Get root nodes from YogaShadowTree
        report += "Node Tree:\n"
        
        // Recursively print nodes
        if let rootNodeId = YogaShadowTree.shared.nodes.first(where: { $0.key == "root" })?.key {
            report += nodeTreeToString(nodeId: rootNodeId, indent: 0)
        }
        
        // Add performance metrics
        report += "\nPerformance:\n"
        report += "  - Total Nodes: \(YogaShadowTree.shared.nodes.count)\n"
        
        return report
    }
    
    /// Helper to convert node tree to string representation
    private func nodeTreeToString(nodeId: String, indent: Int) -> String {
        var result = ""
        let indentStr = String(repeating: "  ", count: indent)
        
        guard let node = YogaShadowTree.shared.nodes[nodeId] else {
            return "\(indentStr)⚠️ Node \(nodeId) not found\n"
        }
        
        // Get node dimensions
        let left = CGFloat(YGNodeLayoutGetLeft(node))
        let top = CGFloat(YGNodeLayoutGetTop(node))
        let width = CGFloat(YGNodeLayoutGetWidth(node))
        let height = CGFloat(YGNodeLayoutGetHeight(node))
        
        // Get view
        let view = DCMauiLayoutManager.shared.getView(withId: nodeId)
        let viewType = view.map { String(describing: type(of: $0)) } ?? "Unknown"
        
        result += "\(indentStr)📦 \(nodeId) (\(viewType)): [\(Int(left)), \(Int(top)), \(Int(width)), \(Int(height))]\n"
        
        // Get children
        let childNodeIds = YogaShadowTree.shared.getChildrenIds(for: nodeId)
        for childId in childNodeIds {
            result += nodeTreeToString(nodeId: childId, indent: indent + 1)
        }
        
        return result
    }
}

// Add extension to YogaShadowTree to expose needed functionality
extension YogaShadowTree {
    /// Get children IDs for a node
    func getChildrenIds(for nodeId: String) -> [String] {
        return nodeParents.filter { $0.value == nodeId }.map { $0.key }
    }
}
