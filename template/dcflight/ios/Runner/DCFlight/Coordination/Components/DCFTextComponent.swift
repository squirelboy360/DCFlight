import UIKit
import yoga

class DCFTextComponent: NSObject, DCFComponent {
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
        // Find the container and the label
        guard let containerView = view as? UIView, // It's always the container
              let label = containerView.viewWithTag(1001) as? UILabel else {
            print("❌ DCFTextComponent: updateView failed - Could not find container or label (tag 1001)")
            return false
        }

        // Determine if this is a content-only update
        let isContentOnlyUpdate = self.isContentOnlyUpdate(props)

        // Store current style state before any updates if it's content-only
        let currentState = isContentOnlyUpdate ? captureLabelState(label) : nil

        // Apply container styling (background, borders, etc.) using the generic extension
        // Skip container styling if it's a content-only update to avoid unnecessary work
        if !isContentOnlyUpdate {
             print("🎨 Applying container styles for Text component")
             containerView.applyStyles(props: props)
        } else {
             print("⚡️ Skipping container style update for content-only change.")
        }


        // Apply text-specific props directly to the label
        let success = updateLabelDirectly(label, withProps: props, isContentOnlyUpdate: isContentOnlyUpdate)

        // Restore styling if this was a content-only update and styling was captured
        if isContentOnlyUpdate, let state = currentState {
             print("🔄 Restoring label style state after content-only update.")
             restoreLabelState(label, state: state)
        }

        // Force layout update after potential text content or style changes
        // Use async to avoid potential layout loops if called during layout pass
        DispatchQueue.main.async {
             containerView.setNeedsLayout()
             containerView.layoutIfNeeded()
             // Also layout the label itself if needed
             label.setNeedsLayout()
             label.layoutIfNeeded()
        }


        return success
    }
    
    // Helper to check if this is a content-only update
    private func isContentOnlyUpdate(_ props: [String: Any]) -> Bool {
        return props.count == 1 && (props["content"] != nil || props["text"] != nil) ||
               props.count == 2 && props["content"] != nil && props["text"] != nil
    }
    
    // Capture all relevant label state
    private func captureLabelState(_ label: UILabel) -> [String: Any] {
        var state: [String: Any] = [
            "textColor": label.textColor,
            "font": label.font,
            "textAlignment": label.textAlignment
        ]
        
        // Capture attributed text attributes if available
        if let attributedText = label.attributedText, attributedText.length > 0 {
            state["attributedTextAttributes"] = attributedText.attributes(at: 0, effectiveRange: nil)
        }
        
        return state
    }
    
    // Restore label state from captured state
    private func restoreLabelState(_ label: UILabel, state: [String: Any]) {
        // Restore basic properties
        if let textColor = state["textColor"] as? UIColor {
            label.textColor = textColor
        }
        
        if let font = state["font"] as? UIFont {
            label.font = font
        }
        
        if let textAlignment = state["textAlignment"] as? NSTextAlignment {
            label.textAlignment = textAlignment
        }
        
        // Restore attributed text formatting
        if let attributedTextAttributes = state["attributedTextAttributes"] as? [NSAttributedString.Key: Any],
           let text = label.text {
            label.attributedText = NSAttributedString(string: text, attributes: attributedTextAttributes)
        }
    }
    
    private func updateLabelDirectly(_ label: UILabel, withProps props: [String: Any], isContentOnlyUpdate: Bool = false) -> Bool {
        // Update content first
        updateLabelContent(label, props: props)
        
        // Skip style updates if this is a content-only update
        if isContentOnlyUpdate {
            // Preserve attributed formatting if any
            if let attributedText = label.attributedText, attributedText.length > 0,
               let plainText = label.text {
                let attributes = attributedText.attributes(at: 0, effectiveRange: nil)
                label.attributedText = NSAttributedString(string: plainText, attributes: attributes)
            }
            return true
        }
        
        // Update styling
        updateLabelStyling(label, props: props)
        
        // Ensure proper sizing
        label.sizeToFit()
        
        // Ensure minimum height
        if label.frame.height < 24 {
            var frame = label.frame
            frame.size.height = 24
            label.frame = frame
        }
        
        return true
    }
    
    // Special handling for text content update
    private func updateTextContent(_ label: UILabel, text: String) {
        // Store the original text for diff checking
        let oldText = objc_getAssociatedObject(
            label,
            UnsafeRawPointer(bitPattern: "previousText".hashValue)!
        ) as? String
        
        // Only log if text actually changed
        if oldText != text {
            print("📝 Text updated: '\(oldText ?? "nil")' -> '\(text)'")
            
            // Store the new text for future comparison
            objc_setAssociatedObject(
                label,
                UnsafeRawPointer(bitPattern: "previousText".hashValue)!,
                text,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
        
        // Set text with animation to ensure UI updates
        UIView.transition(with: label, duration: 0.1, options: .transitionCrossDissolve, animations: {
            label.text = text
        }, completion: nil)
        
        // Force layout immediately rather than waiting for next render cycle
        label.setNeedsDisplay()
        label.superview?.setNeedsLayout()
        label.superview?.layoutIfNeeded()
    }
    
    // Update label content
    private func updateLabelContent(_ label: UILabel, props: [String: Any]) {
        // Check for content prop first (preferred)
        if let content = props["content"] {
            var contentStr = ""
            if let contentAsString = content as? String {
                contentStr = contentAsString
            } else {
                // Convert any type to string for display
                contentStr = "\(content)"
            }
            
            // Use special update method
            updateTextContent(label, text: contentStr)
            
        } else if let text = props["text"] as? String {
            // Use special update method
            updateTextContent(label, text: text)
            
        } else if let numContent = props["content"] as? Int {
            // Handle numeric content specifically
            updateTextContent(label, text: String(numContent))
        }
    }
    
    // Update styling of the label
    private func updateLabelStyling(_ label: UILabel, props: [String: Any]) {
        // Store font properties for atomic update
        let currentFontSize = label.font.pointSize
        let currentFontWeight = label.font.getFontWeight()
        var newFontSize: CGFloat? = nil
        var newFontWeight: UIFont.Weight? = nil
        
        // Text color
        if let color = props["color"] as? String {
            if ColorUtilities.isTransparent(color) {
                label.textColor = UIColor.clear
            } else {
                label.textColor = ColorUtilities.color(fromHexString: color) ?? .black
            }
        }
        
        // Font size
        if let fontSize = props["fontSize"] as? CGFloat {
            newFontSize = fontSize
        }
        
        // Font weight
        if let fontWeight = props["fontWeight"] as? String {
            newFontWeight = fontWeightFromString(fontWeight)
        }
        
        // Apply font changes atomically
        if newFontSize != nil || newFontWeight != nil {
            let fontSize = newFontSize ?? currentFontSize
            let fontWeight = newFontWeight ?? currentFontWeight
            label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
        
        // Text alignment
        if let textAlign = props["textAlign"] as? String {
            label.textAlignment = textAlignmentFromString(textAlign)
        }
        
        // Line height
        if let lineHeight = props["lineHeight"] as? CGFloat {
            applyLineHeight(lineHeight, to: label)
        }
    }
    
    // Helper to convert string alignment to NSTextAlignment
    private func textAlignmentFromString(_ align: String) -> NSTextAlignment {
        switch align {
        case "left":     return .left
        case "center":   return .center
        case "right":    return .right
        case "justify":  return .justified
        default:         return .natural
        }
    }
    
    // Helper to apply line height
    private func applyLineHeight(_ lineHeight: CGFloat, to label: UILabel) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight - label.font.lineHeight
        
        // Create attributed string preserving the current content
        label.attributedText = NSAttributedString(
            string: label.text ?? "",
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
    }
    
    // Layout methods
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
        // Get the label
        let label: UILabel?
        if let directLabel = view as? UILabel {
            label = directLabel
        } else {
            label = view.viewWithTag(1001) as? UILabel
        }
        
        guard let textLabel = label else { return .zero }
        
        // Get text content
        let text = props["content"] as? String ?? props["text"] as? String ?? ""
        if text.isEmpty { return CGSize(width: 0, height: 24) }
        
        // Get font
        let font = (props["fontSize"] as? CGFloat).map { 
            UIFont.systemFont(ofSize: $0)
        } ?? UIFont.systemFont(ofSize: 14)
        
        // Create temp label for measurement
        let tempLabel = UILabel()
        tempLabel.text = text
        tempLabel.font = font
        tempLabel.numberOfLines = 0
        
        // Calculate size with constraints
        let maxWidth = props["maxWidth"] as? CGFloat ?? 
                      view.superview?.frame.width ?? 
                      CGFloat.greatestFiniteMagnitude
                      
        let size = tempLabel.sizeThatFits(CGSize(width: maxWidth, height: .greatestFiniteMagnitude))
        return CGSize(width: size.width, height: max(size.height, 24))
    }
    
    func viewRegisteredWithShadowTree(_ view: UIView, nodeId: String) {
        // Set accessibility identifier for easier debugging
        view.accessibilityIdentifier = "text_\(nodeId)"
        
        // Ensure proper tag is maintained on the label
        if let label = view.viewWithTag(1001) as? UILabel {
            // Tag is already set correctly
        } else if let containerView = view as? UIView, let label = containerView.subviews.first as? UILabel {
            // Ensure the label has the expected tag
            label.tag = 1001
        }
    }
}
