import UIKit

class DCMauiTextComponent: NSObject, DCMauiComponent {
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
        label.textColor = .black
        
        // Apply initial props
        updateView(label, withProps: props)
        
        return label
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let label = view as? UILabel else { return false }
        
        // Store original properties that might get wiped out
        let existingFontSize = label.font?.pointSize ?? 17
        let existingFontName = label.font?.fontName
        let existingColor = label.textColor
        let existingAlignment = label.textAlignment
        let existingNumberOfLines = label.numberOfLines
        
        // Get text content - this is the critical part
        let textContent = props["content"] as? String ?? ""
        
        // Create an attributed string for the text
        let attributedString = NSMutableAttributedString(string: textContent)
        
        // Get or preserve font properties
        var fontSize: CGFloat = existingFontSize
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
        } else if let attributedText = label.attributedText, attributedText.length > 0 {
            // Try to preserve existing font weight
            if let existingFont = attributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
                for trait in [
                    UIFont.Weight.ultraLight, .thin, .light, .regular,
                    .medium, .semibold, .bold, .heavy, .black
                ] {
                    let testFont = UIFont.systemFont(ofSize: existingFontSize, weight: trait)
                    if testFont.fontName == existingFontName {
                        fontWeight = trait
                        break
                    }
                }
            }
        }
        
        // Create font
        var font: UIFont?
        if let fontFamily = props["fontFamily"] as? String {
            font = UIFont(name: fontFamily, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        } else {
            font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
        
        // Get or preserve text color
        var textColor = existingColor
        if let color = props["color"] as? String {
            textColor = ColorUtilities.color(fromHexString: color) ?? existingColor
        }
        
        // Create paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        
        // Get or preserve text alignment
        var textAlignment = existingAlignment
        if let textAlign = props["textAlign"] as? String {
            switch textAlign {
            case "left": textAlignment = .left
            case "center": textAlignment = .center
            case "right": textAlignment = .right
            case "justify": textAlignment = .justified
            default: break
            }
        }
        paragraphStyle.alignment = textAlignment
        
        // Get letter spacing
        var letterSpacing: CGFloat? = nil
        if let spacing = props["letterSpacing"] as? CGFloat {
            letterSpacing = spacing
        }
        
        // Line height
        if let lineHeight = props["lineHeight"] as? CGFloat {
            paragraphStyle.lineSpacing = lineHeight - (font?.lineHeight ?? fontSize)
        }
        
        // Build attribute dictionary
        var attributes: [NSAttributedString.Key: Any] = [:]
        if let font = font {
            attributes[.font] = font
        }
        attributes[.foregroundColor] = textColor
        attributes[.paragraphStyle] = paragraphStyle
        
        if let letterSpacing = letterSpacing {
            attributes[.kern] = letterSpacing
        }
        
        // Apply all attributes to the entire string
        let range = NSRange(location: 0, length: textContent.count)
        attributedString.addAttributes(attributes, range: range)
        
        // Set the attributed text
        label.attributedText = attributedString
        
        // Handle specific text properties
        if let numberOfLines = props["numberOfLines"] as? Int {
            label.numberOfLines = numberOfLines
        } else {
            // Keep existing setting
            label.numberOfLines = existingNumberOfLines
        }
        
        // Apply general styles like background, border, etc.
        DCMauiLayoutManager.shared.applyStyles(to: label, props: props)
        
        // Apply layout if specified
        if let width = props["width"] as? CGFloat, let height = props["height"] as? CGFloat {
            label.frame = CGRect(x: label.frame.origin.x, y: label.frame.origin.y, width: width, height: height)
        }
        
        return true
    }
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        // Text elements typically don't have events
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        // Clean up any event listeners if added
    }
}
