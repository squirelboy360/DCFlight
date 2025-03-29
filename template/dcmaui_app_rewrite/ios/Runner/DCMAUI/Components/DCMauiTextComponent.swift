import UIKit
import yoga

class DCMauiTextComponent: NSObject, DCMauiComponentProtocol {
    static func createView(props: [String: Any]) -> UIView {
        // Create custom label implementation with built-in size guarantees
        let label = RobustLabel()
        
        // Configure default properties
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear
        label.textColor = .black // Set default text color to ensure visibility
        
        // Create Yoga node for layout
        let _ = DCMauiLayoutManager.shared.createYogaNode(for: label)
        
        // Apply props
        updateView(label, props: props)
        
        return label
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        guard let label = view as? UILabel else { return }
        
        // TRACKING
        let textContent = props["content"] as? String ?? ""
        print("📝 TEXT COMPONENT UPDATE: '\(textContent)'")
        
        // STEP 1: Set text content DIRECTLY - no async, no complex processing
        label.text = textContent
        
        // STEP 2: Apply styling directly
        applyTextStyling(label, props: props)
        
        // STEP 3: Force layout if needed
        if let robustLabel = label as? RobustLabel {
            robustLabel.enforceMinimumSize()
        }
        
        // STEP 4: Apply layout properties AFTER setting content
        if let yogaNode = DCMauiLayoutManager.shared.yogaNode(for: label) {
            // Calculate size needed for text
            let idealSize = label.sizeThatFits(CGSize(width: 10000, height: 10000))
            print("📏 Text needs size: \(idealSize.width) x \(idealSize.height) for: '\(textContent)'")
            
            // Set minimum width and height
            YGNodeStyleSetMinWidth(yogaNode, Float(idealSize.width))
            YGNodeStyleSetMinHeight(yogaNode, Float(idealSize.height))
        }
        
        // Apply other layout props
        applyLayoutProps(label, props: props)
    }
    
    private static func applyTextStyling(_ label: UILabel, props: [String: Any]) {
        // Set basic text color - CRITICAL for visibility
        if let color = props["color"] as? String {
            label.textColor = UIColorFromHex(color)
        } else {
            // Default to black if no color specified
            label.textColor = .black
        }
        
        // Font size - ensure reasonable default
        var fontSize: CGFloat = 17.0
        if let size = props["fontSize"] as? CGFloat {
            fontSize = size
        }
        
        // Font weight
        var fontWeight: UIFont.Weight = .regular
        if let weight = props["fontWeight"] as? String {
            switch weight {
            case "bold": fontWeight = .bold
            case "100": fontWeight = .ultraLight
            case "200": fontWeight = .thin
            case "300": fontWeight = .light
            case "400": fontWeight = .regular
            case "500": fontWeight = .medium
            case "600": fontWeight = .semibold
            case "700": fontWeight = .bold
            case "800": fontWeight = .heavy
            case "900": fontWeight = .black
            default: fontWeight = .regular
            }
        }
        
        // Apply font with weight
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        
        // Apply text alignment
        if let textAlign = props["textAlign"] as? String {
            switch textAlign {
            case "left": label.textAlignment = .left
            case "center": label.textAlignment = .center
            case "right": label.textAlignment = .right
            case "justify": label.textAlignment = .justified
            default: label.textAlignment = .natural
            }
        }
    }
    
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // No standard events for text
    }
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // No standard events for text
    }
}

// Custom label class with built-in size guarantees
class RobustLabel: UILabel {
    // Override intrinsic content size to provide minimum size
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: max(size.width, 10),  // At least 10pt wide
            height: max(size.height, 10) // At least 10pt high
        )
    }
    
    // Override text property to always update size
    override var text: String? {
        didSet {
            print("🔤 Text set to: '\(text ?? "")'")
            super.text = text
            self.setNeedsLayout()
            self.invalidateIntrinsicContentSize()
            enforceMinimumSize()
        }
    }
    
    // Ensure visibility by forcing layout
    func enforceMinimumSize() {
        let textSize = self.sizeThatFits(CGSize(width: 10000, height: 10000))
        if textSize.width > 0 && textSize.height > 0 {
            // If we have valid text size, ensure view can accommodate it
            let minFrame = CGRect(
                x: self.frame.origin.x,
                y: self.frame.origin.y,
                width: max(self.frame.width, textSize.width),
                height: max(self.frame.height, textSize.height)
            )
            
            // Only update if needed
            if self.frame.width < textSize.width || self.frame.height < textSize.height {
                print("📏 Enforcing minimum size: \(minFrame.width) x \(minFrame.height) for text: '\(self.text ?? "")'")
                self.frame = minFrame
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure our frame is visible after layout
        if let text = self.text, !text.isEmpty, (frame.width < 1 || frame.height < 1) {
            print("⚠️ Label frame too small after layout: \(frame) for text: '\(text)'")
            sizeToFit()
        }
    }
    
    // Force drawing of the text even for zero-sized frames
    override func draw(_ rect: CGRect) {
        if let text = self.text, !text.isEmpty, rect.width < 1 || rect.height < 1 {
            // Force a minimum drawing rect
            let minRect = CGRect(x: rect.origin.x, y: rect.origin.y, 
                                width: max(rect.width, 100), height: max(rect.height, 20))
            super.draw(minRect)
        } else {
            super.draw(rect)
        }
    }
}
