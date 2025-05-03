import UIKit
import dcflight

class DCFTextComponent: NSObject, DCFComponent, ComponentMethodHandler {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a label
        let label = UILabel()
        
        // Apply initial styling
        label.numberOfLines = 0
        label.textColor = UIColor.black
        
        // Apply props
        updateView(label, withProps: props)
        
        return label
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let label = view as? UILabel else { return false }
        
        // Set content if specified
        if let content = props["content"] as? String {
            label.text = content
        }
        
        // Set font size if specified
        if let fontSize = props["fontSize"] as? CGFloat {
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        // Set font weight if specified
        if let fontWeight = props["fontWeight"] as? String {
            // Convert string weight to UIFont.Weight
            var weight = UIFont.Weight.regular
            
            switch fontWeight {
            case "bold":
                weight = .bold
            case "semibold":
                weight = .semibold
            case "light":
                weight = .light
            case "medium":
                weight = .medium
            default:
                weight = .regular
            }
            
            label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: weight)
        }
        
        // Set font family if specified
        if let fontFamily = props["fontFamily"] as? String {
            label.font = UIFont(name: fontFamily, size: label.font.pointSize) ?? label.font
        }
        
        // Set text color if specified with enhanced error handling
        if let color = props["color"] as? String {
            // Safely parse the color string - will use a default color if the string is invalid
            label.textColor = ColorUtilities.color(fromHexString:color)
        }
        
        // Set text alignment if specified
        if let textAlign = props["textAlign"] as? String {
            switch textAlign {
            case "center":
                label.textAlignment = .center
            case "right":
                label.textAlignment = .right
            case "justify":
                label.textAlignment = .justified
            default:
                label.textAlignment = .left
            }
        }
        
        // Set number of lines if specified
        if let numberOfLines = props["numberOfLines"] as? Int {
            label.numberOfLines = numberOfLines
        }
        
        return true
    }
    
   
      
    
    
    // Get intrinsic content size
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        guard let label = view as? UILabel else { return CGSize(width: 0, height: 0) }
        
        // Force layout if needed
        if label.bounds.size.width == 0 {
            return label.intrinsicContentSize
        }
        
        return label.sizeThatFits(CGSize(width: label.bounds.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    // Handle component methods
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        guard let label = view as? UILabel else { return false }
        
        switch methodName {
        case "setText":
            if let text = args["text"] as? String {
                label.text = text
                return true
            }
        default:
            return false
        }
        
        return false
    }
}
