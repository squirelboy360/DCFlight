import UIKit

/// Helper class for debugging color-related issues
class ColorDebugHelper {
    static let shared = ColorDebugHelper()
    
    private init() {}
    
    /// Test and log all color conversion paths
    func runColorTests() {
        print("🧪 Running color conversion tests")
        
        let testCases = [
            "transparent",
            "clear",
            "rgba(0,0,0,0)",
            "#00000000",
            "0",
            "0x0",
            "#FF0000",
            "#00FF00",
            "#0000FF",
            "#FFFFFF",
            "#000000",
            "red",
            "blue",
            "green"
        ]
        
        for testCase in testCases {
            if let color = ColorUtilities.color(fromHexString: testCase) {
                let isTransparent = color.cgColor.alpha == 0
                print("✅ Converted '\(testCase)' -> \(color) (Transparent: \(isTransparent))")
            } else {
                print("❌ Failed to convert '\(testCase)'")
            }
        }
    }
    
    /// Log all current colors in view hierarchy
    func logViewHierarchyColors(_ rootView: UIView) {
        print("🎨 View Hierarchy Colors:")
        logViewColors(rootView, indent: 0)
    }
    
    private func logViewColors(_ view: UIView, indent: Int) {
        let indentation = String(repeating: "  ", count: indent)
        let viewType = String(describing: type(of: view))
        let viewId = view.accessibilityIdentifier ?? "unknown"
        
        let backgroundColor = view.backgroundColor
        var colorDesc = "nil"
        var isTransparent = false
        
        if let bgColor = backgroundColor {
            isTransparent = bgColor.cgColor.alpha == 0
            colorDesc = isTransparent ? "transparent" : ColorUtilities.hexString(from: bgColor)
        }
        
        print("\(indentation)📱 \(viewType)(id: \(viewId)): backgroundColor=\(colorDesc) (transparent: \(isTransparent))")
        
        for subview in view.subviews {
            logViewColors(subview, indent: indent + 1)
        }
    }
}
