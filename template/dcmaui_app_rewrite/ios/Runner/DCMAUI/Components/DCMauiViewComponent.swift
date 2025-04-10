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
        // FIXED: Use common approach for all components:
        // Apply styles directly via the extension
        view.applyStyles(props: props)
        
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

