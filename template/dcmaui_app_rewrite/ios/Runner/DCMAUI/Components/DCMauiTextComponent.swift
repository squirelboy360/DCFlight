import UIKit
import yoga

class DCMauiTextComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a container view to handle background styling
        let containerView = UIView()
        let label = UILabel()
        label.numberOfLines = 0 // Allow multiple lines by default
        
        // Tag the label for identification
        label.tag = 1001
        
        // Add label to container
        containerView.addSubview(label)
        
        // Setup constraints to make label fill the container
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // Set minimum size and ensure text doesn't disappear
        label.text = props["content"] as? String ?? "" 
        
        // Apply properties
        _ = updateView(containerView, withProps: props)
        
        return containerView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        // First find the label inside the container
        guard let label = view.viewWithTag(1001) as? UILabel else {
            // Direct label case (legacy)
            if let directLabel = view as? UILabel {
                return updateLabelDirectly(directLabel, withProps: props)
            }
            return false
        }
        
        // FIXED: Apply all styling props to container view first
        // Extract style properties and apply directly to the view
        view.applyStyles(props: props)
        
        // Apply text-specific props to label
        return updateLabelDirectly(label, withProps: props)
    }
    
    private func updateLabelDirectly(_ label: UILabel, withProps props: [String: Any]) -> Bool {
        // Apply text properties
        if let text = props["content"] as? String {
            print("📝 Setting text content: \(text)")
            label.text = text
        } else if let text = props["text"] as? String {
            print("📝 Setting text content: \(text)")
            label.text = text
        }
        
        // Apply text-specific styles
        if let color = props["color"] as? String {
            print("🎨 Setting text color directly: \(color)")
            // CRITICAL FIX: Handle transparent color
            if ColorUtilities.isTransparent(color) {
                label.textColor = UIColor.clear
            } else {
                label.textColor = ColorUtilities.color(fromHexString: color) ?? .black
            }
        }
        
        if let fontSize = props["fontSize"] as? CGFloat {
            label.font = UIFont.systemFont(ofSize: fontSize)
        } else {
            // Default font size if not provided
            label.font = UIFont.systemFont(ofSize: 14)
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
        
        // CRITICAL FIX: Ensure text has proper sizing by calling sizeToFit if needed
        label.sizeToFit()
        
        // CRITICAL FIX: Force minimum height for text
        if label.frame.height < 24 {
            var frame = label.frame
            frame.size.height = 24
            label.frame = frame
        }
        
        // Store intrinsic height as associated object to ensure consistent layout calculation
        objc_setAssociatedObject(
            label,
            UnsafeRawPointer(bitPattern: "intrinsicHeight".hashValue)!,
            label.frame.height,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
        
        print("📐 Final text size after update: \(label.frame.size)")
        
        return true
    }
    
    func applyLayout(_ view: UIView, layout: YGNodeLayout) {
        // Apply the layout to the container
        view.frame = CGRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)
        
        // If this is a direct label (legacy), also resize it
        if let label = view as? UILabel {
            label.frame.size = CGSize(width: layout.width, height: layout.height)
        } else if let label = view.viewWithTag(1001) as? UILabel {
            // Make sure label fills container
            label.frame = view.bounds
        }
    }
    
    func getIntrinsicSize(_ view: UIView, forProps props: [String: Any]) -> CGSize {
        // Get the label - either direct or from container
        let label: UILabel?
        if let directLabel = view as? UILabel {
            label = directLabel
        } else {
            label = view.viewWithTag(1001) as? UILabel
        }
        
        // If no label found, return zero size
        guard let textLabel = label else {
            return .zero
        }
        
        // Use text content if available
        let text = props["content"] as? String ?? props["text"] as? String ?? ""
        
        if text.isEmpty {
            return CGSize(width: 0, height: 24) // Minimum height 
        }
        
        // Use stored font or create one with props
        let font: UIFont
        if let fontSize = props["fontSize"] as? CGFloat {
            font = UIFont.systemFont(ofSize: fontSize)
        } else {
            font = UIFont.systemFont(ofSize: 14)
        }
        
        // Create a temporary label to measure text with the same properties
        let tempLabel = UILabel()
        tempLabel.text = text
        tempLabel.font = font
        tempLabel.numberOfLines = 0
        
        // Calculate size with constraints
        let maxWidth = props["maxWidth"] as? CGFloat ?? view.superview?.frame.width ?? CGFloat.greatestFiniteMagnitude
        let constraintSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        var size = tempLabel.sizeThatFits(constraintSize)
        
        // Ensure minimum height
        if size.height < 24 {
            size.height = 24
        }
        
        print("📏 Text intrinsic size measurement: \"\(text)\" -> \(size)")
        
        return size
    }
}
