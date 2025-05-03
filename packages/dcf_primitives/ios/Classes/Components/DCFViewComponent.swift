import UIKit
import dcflight

class DCFViewComponent: NSObject, DCFComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a basic UIView
        let view = UIView()
        
        // Apply initial styling
        view.backgroundColor = UIColor.clear
        
        // Apply any props that were passed
        updateView(view, withProps: props)
        
        return view
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let view = view as? UIView else { return false }
        
        // Apply background color if specified
        if let backgroundColor = props["backgroundColor"] as? String {
            view.backgroundColor = ColorUtilities.color(fromHexString:backgroundColor)
        }
        
        // Apply border radius if specified
        if let borderRadius = props["borderRadius"] as? CGFloat {
            view.layer.cornerRadius = borderRadius
        }
        
        // Apply opacity if specified
        if let opacity = props["opacity"] as? CGFloat {
            view.alpha = opacity
        }
        
        return true
    }
    
    // Use default implementations for the remaining methods
}
