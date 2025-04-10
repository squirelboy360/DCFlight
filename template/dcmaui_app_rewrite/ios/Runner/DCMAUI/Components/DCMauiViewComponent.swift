import UIKit
import yoga

/// Implementation of a basic View component
class DCMauiViewComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        let view = UIView()
        
        // Apply props to the newly created view
        _ = updateView(view, withProps: props)
        
        return view
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // Extract style-related properties
        let styleProps = props.filter { key, _ in
            // Filter for style properties (not layout)
            !LayoutProps.all.contains(key)
        }
        
        // Apply styles directly to view
        if !styleProps.isEmpty {
            view.applyStyles(props: styleProps)
        }
        
        // CRITICAL FIX: Apply background color directly if specified
        if let backgroundColor = props["backgroundColor"] as? String {
            print("🎨 Setting background color directly: \(backgroundColor)")
            view.backgroundColor = ColorUtilities.color(fromHexString: backgroundColor)
        }
        
        // CRITICAL FIX: Add debug border if needed
        #if DEBUG
        if ProcessInfo.processInfo.environment["DCMAUI_DEBUG_VIEW_BORDERS"] == "1" || 
           UserDefaults.standard.bool(forKey: "DCMauiDebugViewBorders") {
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.red.cgColor
        }
        #endif
        
        return true
    }
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        view.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        return view.intrinsicContentSize
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        view.nodeId = nodeId
        
        // CRITICAL FIX: Set accessibility identifier for easier debugging
        view.accessibilityIdentifier = nodeId
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
