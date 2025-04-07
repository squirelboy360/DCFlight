import UIKit
import yoga

class DCMauiTextComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        let label = UILabel()
        label.numberOfLines = 0 // Allow multiple lines by default
        
        // Apply properties
        _ = updateView(label, withProps: props)
        
        return label
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let label = view as? UILabel else {
            return false
        }
        
        // Apply text properties
        if let text = props["text"] as? String {
            label.text = text
        }
        
        // Apply style properties using existing UIView extension
        view.applyStyles(props: props)
        
        // Apply text-specific styles
        if let color = props["color"] as? String {
            label.textColor = UIColor(named: color)
        }
        
        if let fontSize = props["fontSize"] as? CGFloat {
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        if let fontWeight = props["fontWeight"] as? String {
            switch fontWeight {
            case "bold":
                label.font = UIFont.boldSystemFont(ofSize: label.font.pointSize)
            case "100":
                label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .ultraLight)
            case "200":
                label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .thin)
            case "300":
                label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .light)
            case "400":
                label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .regular)
            case "500":
                label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .medium)
            case "600":
                label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .semibold)
            case "700":
                label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .bold)
            case "800":
                label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .heavy)
            case "900":
                label.font = UIFont.systemFont(ofSize: label.font.pointSize, weight: .black)
            default:
                break
            }
        }
        
        if let textAlign = props["textAlign"] as? String {
            switch textAlign {
            case "left":
                label.textAlignment = .left
            case "center":
                label.textAlignment = .center
            case "right":
                label.textAlignment = .right
            case "justify":
                label.textAlignment = .justified
            default:
                label.textAlignment = .natural
            }
        }
        
        if let lineHeight = props["lineHeight"] as? CGFloat {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight - label.font.lineHeight
            label.attributedText = NSAttributedString(
                string: label.text ?? "",
                attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
            )
        }
        
        return true
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        guard let label = view as? UILabel,
              let text = props["text"] as? String else {
            return .zero
        }
        
        // Create a temporary label to measure text with the same properties
        let tempLabel = UILabel()
        tempLabel.text = text
        tempLabel.font = label.font
        tempLabel.numberOfLines = 0
        
        // Calculate size with constraints
        let maxWidth = props["maxWidth"] as? CGFloat ?? CGFloat.greatestFiniteMagnitude
        let constraintSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let size = tempLabel.sizeThatFits(constraintSize)
        
        return size
    }

}
