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
    
        // Apply styles directly via the extension
        view.applyStyles(props: props)
        
      
        
        return true
    }
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        view.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        return view.intrinsicContentSize
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // CRITICAL FIX: Set accessibility identifier for easier debugging
        view.accessibilityIdentifier = nodeId
    }
}

