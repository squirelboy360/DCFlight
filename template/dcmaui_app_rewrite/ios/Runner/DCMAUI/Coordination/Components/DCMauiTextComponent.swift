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
        print("📝 Text updateView called with props: \(props)")
        
        // First find the label inside the container
        guard let label = view.viewWithTag(1001) as? UILabel else {
            // Direct label case (legacy)
            if let directLabel = view as? UILabel {
                return updateLabelDirectly(directLabel, withProps: props)
            }
            print("❌ ERROR: Could not find label inside container")
            return false
        }
        
        // ENHANCED: Store current style properties before update
        let currentTextColor = label.textColor
        let currentFont = label.font
        let currentTextAlignment = label.textAlignment
        
        // CRITICAL FIX: Only apply container styling if specific container props exist
        if props.keys.contains(where: { $0 != "content" && $0 != "text" }) {
            // Apply styling props to container view
            view.applyStyles(props: props)
        }
        
        // CRITICAL DEBUGGING: Print content before update
        print("📄 Label text BEFORE update: \(label.text ?? "nil")")
        
        // Check if this is a content-only update
        let isContentOnlyUpdate = props.count == 1 && (props["content"] != nil || props["text"] != nil)
        print("🔍 Is content-only update: \(isContentOnlyUpdate)")
        
        // Apply text-specific props to label
        let success = updateLabelDirectly(label, withProps: props, isContentOnlyUpdate: isContentOnlyUpdate)
        
        // ENHANCED: If content-only update but styles were lost, restore them
        if isContentOnlyUpdate {
            // Check if styles were inadvertently reset and restore if needed
            if label.textColor != currentTextColor {
                print("🎨 Restoring text color after content update")
                label.textColor = currentTextColor
            }
            
            if label.font != currentFont {
                print("🔤 Restoring font after content update")
                label.font = currentFont
            }
            
            if label.textAlignment != currentTextAlignment {
                print("📏 Restoring text alignment after content update")
                label.textAlignment = currentTextAlignment
            }
        }
        
        // CRITICAL DEBUGGING: Print content after update
        print("📄 Label text AFTER update: \(label.text ?? "nil")")
        
        // FORCE LAYOUT UPDATE after text content changes
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        return success
    }
    
    private func updateLabelDirectly(_ label: UILabel, withProps props: [String: Any], isContentOnlyUpdate: Bool = false) -> Bool {
        // CRITICAL DEBUGGING: Log initial props
        print("🔍 Updating label with props: \(props)")
        
        // Track whether content was updated
        var contentUpdated = false
        
        // Apply text properties - CRITICAL FIX: More explicit content handling
        if let text = props["content"] as? String {
            print("📝 Setting text content directly: '\(text)'")
            label.text = text
            contentUpdated = true
        } else if let text = props["text"] as? String {
            print("📝 Setting text content via 'text' prop: '\(text)'")
            label.text = text
            contentUpdated = true
        } else if let numContent = props["content"] as? Int {
            // Handle integer content (common for counters)
            print("📝 Setting numeric content: \(numContent)")
            label.text = String(numContent)
            contentUpdated = true
        }
        
        // Skip style updates if this is a content-only update
        if isContentOnlyUpdate && contentUpdated {
            print("🔒 Content-only update: preserving existing styles")
            // CRITICAL FIX: Make sure line height is preserved when using attributed string
            if let attributedText = label.attributedText, let plainText = label.text {
                // Create a copy of the attributed text with the new content
                let newAttributes = attributedText.attributes(at: 0, effectiveRange: nil)
                label.attributedText = NSAttributedString(string: plainText, attributes: newAttributes)
                print("📝 Preserved attributed text formatting while updating content")
            }
            
            // ADDED CRITICAL DEBUGGING: Check text was set
            print("📄 Text label now contains: '\(label.text ?? "nil")'")
            return true
        }
        
        // Only apply style properties if not a content-only update or if we haven't updated content yet
        
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
            // Preserve font weight when changing size
            let currentWeight = label.font?.getFontWeight() ?? .regular
            label.font = UIFont.systemFont(ofSize: fontSize, weight: currentWeight)
            print("📏 Updated font size to \(fontSize) while preserving weight \(currentWeight)")
        }
        
        if let fontWeight = props["fontWeight"] as? String {
            // Preserve current font size when changing weight
            let currentSize = label.font?.pointSize ?? 14.0
            
            switch fontWeight {
            case "bold":
                label.font = UIFont.boldSystemFont(ofSize: currentSize)
            case "100":
                label.font = UIFont.systemFont(ofSize: currentSize, weight: .ultraLight)
            case "200":
                label.font = UIFont.systemFont(ofSize: currentSize, weight: .thin)
            case "300":
                label.font = UIFont.systemFont(ofSize: currentSize, weight: .light)
            case "400":
                label.font = UIFont.systemFont(ofSize: currentSize, weight: .regular)
            case "500":
                label.font = UIFont.systemFont(ofSize: currentSize, weight: .medium)
            case "600":
                label.font = UIFont.systemFont(ofSize: currentSize, weight: .semibold)
            case "700":
                label.font = UIFont.systemFont(ofSize: currentSize, weight: .bold)
            case "800":
                label.font = UIFont.systemFont(ofSize: currentSize, weight: .heavy)
            case "900":
                label.font = UIFont.systemFont(ofSize: currentSize, weight: .black)
            default:
                break
            }
            
            print("🔤 Updated font weight to \(fontWeight) while preserving size \(currentSize)")
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
            
            // Create attributed string but preserve the current content
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
        
        // CRITICAL FIX: Force layout update
        label.setNeedsDisplay()
        
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
