import UIKit

class DCMauiTextComponent: NSObject, DCMauiComponent {
    // Required initializer to conform to DCMauiComponent
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create label
        let label = UILabel()
        
        // Configure default properties
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear
        label.textColor = .black // Default text color for visibility
        
        // Apply initial props
        updateView(label, withProps: props)
        
        return label
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let label = view as? UILabel else { return false }
        
        // Apply text content
        if let textContent = props["content"] as? String {
            label.text = textContent
        }
        
        // Apply text styling
        applyTextStyling(label, props: props)
        
        // Apply non-layout styling using shared layout manager
        DCMauiLayoutManager.shared.applyStyles(to: label, props: props)
        
        // Handle specific text properties not covered by the general style applier
        if let numberOfLines = props["numberOfLines"] as? Int {
            label.numberOfLines = numberOfLines
        }
        
        // Don't position the view here - layout is handled by Dart side
        
        return true
    }
    
    // MARK: - Helper Methods
    
    private func applyTextStyling(_ label: UILabel, props: [String: Any]) {
        // Text color
        if let color = props["color"] as? String {
            label.textColor = ColorUtilities.color(fromHexString: color) ?? .black
        }
        
        // Font size
        var fontSize: CGFloat = 17.0
        if let size = props["fontSize"] as? CGFloat {
            fontSize = size
        } else if let size = props["fontSize"] as? Double {
            fontSize = CGFloat(size)
        } else if let size = props["fontSize"] as? Int {
            fontSize = CGFloat(size)
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
        
        // Custom font family
        if let fontFamily = props["fontFamily"] as? String {
            if let customFont = UIFont(name: fontFamily, size: fontSize) {
                label.font = customFont
            } else {
                label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
            }
        } else {
            label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
        
        // Text alignment
        if let textAlign = props["textAlign"] as? String {
            switch textAlign {
            case "left": label.textAlignment = .left
            case "center": label.textAlignment = .center
            case "right": label.textAlignment = .right
            case "justify": label.textAlignment = .justified
            default: label.textAlignment = .natural
            }
        }
        
        // Letter spacing
        if let letterSpacing = props["letterSpacing"] as? CGFloat {
            if letterSpacing != 0 {
                label.attributedText = NSAttributedString(
                    string: label.text ?? "",
                    attributes: [.kern: letterSpacing]
                )
            }
        }
    }
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // Most texts don't have events, but could add tap gesture if needed
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // Clean up any event listeners if added
    }
}
