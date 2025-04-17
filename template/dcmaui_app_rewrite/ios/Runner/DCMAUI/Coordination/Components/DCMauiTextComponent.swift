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
        
        // Store current style state before any updates
        let currentState = captureLabelState(label)
        
        // CRITICAL FIX: Apply container styling if needed
        if !isContentOnlyUpdate(props) {
            view.applyStyles(props: props)
        }
        
        // CRITICAL DEBUGGING: Print content before update
        print("📄 Label text BEFORE update: \(label.text ?? "nil")")
        
        // Apply text-specific props to label
        let success = updateLabelDirectly(label, withProps: props)
        
        // Check if we need to restore styles - relies on Dart-side _preserveStyleProps
        if isContentOnlyUpdate(props) {
            // If we determined this is content-only, restore style state
            restoreLabelState(label, state: currentState)
            print("🔄 Restored label state after content-only update")
        }
        
        // CRITICAL DEBUGGING: Print content after update
        print("📄 Label text AFTER update: \(label.text ?? "nil")")
        
        // FORCE LAYOUT UPDATE after text content changes
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        return success
    }
    
    // Helper to check if this is a content-only update
    private func isContentOnlyUpdate(_ props: [String: Any]) -> Bool {
        // If props has only content or only text, or both with nothing else
        let contentOnly = props.count == 1 && (props["content"] != nil || props["text"] != nil)
        let contentAndText = props.count == 2 && props["content"] != nil && props["text"] != nil
        return contentOnly || contentAndText
    }
    
    // Capture all relevant label state
    private func captureLabelState(_ label: UILabel) -> [String: Any] {
        var state: [String: Any] = [:]
        
        // Capture basic properties
        state["textColor"] = label.textColor
        state["font"] = label.font
        state["textAlignment"] = label.textAlignment
        
        // Capture attributed text attributes if available
        if let attributedText = label.attributedText, attributedText.length > 0 {
            state["attributedTextAttributes"] = attributedText.attributes(at: 0, effectiveRange: nil)
        }
        
        return state
    }
    
    // Restore label state from captured state
    private func restoreLabelState(_ label: UILabel, state: [String: Any]) {
        // Restore text color
        if let textColor = state["textColor"] as? UIColor {
            label.textColor = textColor
        }
        
        // Restore font
        if let font = state["font"] as? UIFont {
            label.font = font
        }
        
        // Restore text alignment
        if let textAlignment = state["textAlignment"] as? NSTextAlignment {
            label.textAlignment = textAlignment
        }
        
        // Restore attributed text formatting
        if let attributedTextAttributes = state["attributedTextAttributes"] as? [NSAttributedString.Key: Any],
           let text = label.text {
            label.attributedText = NSAttributedString(string: text, attributes: attributedTextAttributes)
        }
    }
    
    private func updateLabelDirectly(_ label: UILabel, withProps props: [String: Any]) -> Bool {
        // CRITICAL DEBUGGING: Log initial props
        print("🔍 Updating label with props: \(props)")
        
        // Store font properties before any changes for preserving during updates
        let currentFontSize = label.font.pointSize
        let currentFontWeight = label.font.getFontWeight()
        
        // Apply text content first
        var contentUpdated = false
        
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
        
        // Only update styles if they are explicitly provided
        
        // Color
        if let color = props["color"] as? String {
            print("🎨 Setting text color directly: \(color)")
            if ColorUtilities.isTransparent(color) {
                label.textColor = UIColor.clear
            } else {
                label.textColor = ColorUtilities.color(fromHexString: color) ?? .black
            }
        }
        
        // Process font properties - collect changes first
        var newFontSize: CGFloat? = nil
        var newFontWeight: UIFont.Weight? = nil
        
        // Font size
        if let fontSize = props["fontSize"] as? CGFloat {
            newFontSize = fontSize
        }
        
        // Font weight
        if let fontWeight = props["fontWeight"] as? String {
            // Map string weight to UIFont.Weight
            switch fontWeight {
            case "bold", "700":
                newFontWeight = .bold
            case "600":
                newFontWeight = .semibold
            case "500":
                newFontWeight = .medium
            case "400", "normal", "regular":
                newFontWeight = .regular
            case "300":
                newFontWeight = .light
            case "200":
                newFontWeight = .thin
            case "100":
                newFontWeight = .ultraLight
            case "800":
                newFontWeight = .heavy
            case "900":
                newFontWeight = .black
            default:
                // Preserve current weight
                break
            }
        }
        
        // Apply font changes atomically to prevent intermediate states
        if newFontSize != nil || newFontWeight != nil {
            // Use the new properties where provided, fall back to current properties
            let fontSize = newFontSize ?? currentFontSize
            let fontWeight = newFontWeight ?? currentFontWeight
            
            // Create new font with combined properties
            label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
            print("🔤 Applied font - size: \(fontSize), weight: \(fontWeight)")
        }
        
        // Text alignment
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
        
        // Line height
        if let lineHeight = props["lineHeight"] as? CGFloat {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight - label.font.lineHeight
            
            // Create attributed string
            label.attributedText = NSAttributedString(
                string: label.text ?? "",
                attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
            )
        }
        
        // Apply proper sizing
        label.sizeToFit()
        
        // Ensure minimum height
        if label.frame.height < 24 {
            var frame = label.frame
            frame.size.height = 24
            label.frame = frame
        }
        
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
