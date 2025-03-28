import UIKit
import yoga

class DCMauiTextComponent: NSObject, DCMauiComponentProtocol {
    static func createView(props: [String: Any]) -> UIView {
        let label = UILabel()
        
        // Essential for visibility
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        // Default text alignment left (natural) - will be overridden by props
        label.textAlignment = .center
        
        // Set default color - white (visible on most backgrounds)
        label.textColor = .white
        
        // Set default font size if not specified
        label.font = UIFont.systemFont(ofSize: 18)
        
        // Create Yoga node for this view
        let _ = DCMauiLayoutManager.shared.createYogaNode(for: label)
        
        // Apply all props including layout
        updateView(label, props: props)
        
        return label
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        guard let textView = view as? UILabel else { return }
        
        // Set content if available
        if let content = props["content"] as? String {
            textView.text = content
            print("DEBUG: Set text content: \(content)")
        }
        
        // Text color handling - now supporting both string and Color object from Dart
        if let color = props["color"] as? String {
            textView.textColor = UIColorFromHex(color)
            print("DEBUG: Set text color to: \(color)")
        }
        
        // Debug existing color
        if textView.textColor != nil {
            print("DEBUG: Current text color: \(textView.textColor!)")
        }
        
        // Font properties
        var fontDescriptor: UIFontDescriptor? = textView.font.fontDescriptor
        var fontSize: CGFloat = textView.font.pointSize
        
        if let fontFamily = props["fontFamily"] as? String {
            // Check if this is a custom font from assets or system font
            if let customFont = loadCustomFont(fontFamily, size: fontSize) {
                textView.font = customFont
            } else {
                fontDescriptor = UIFontDescriptor(name: fontFamily, size: fontSize)
            }
        }
        
        if let newFontSize = props["fontSize"] as? CGFloat {
            fontSize = newFontSize
        }
        
        // Font weight handling
        if let fontWeight = props["fontWeight"] as? String {
            var traits: [UIFontDescriptor.TraitKey: Any] = [:]
            
            switch fontWeight {
            case "bold":
                traits[.weight] = UIFont.Weight.bold
            case "100":
                traits[.weight] = UIFont.Weight.ultraLight
            case "200":
                traits[.weight] = UIFont.Weight.thin
            case "300":
                traits[.weight] = UIFont.Weight.light
            case "400":
                traits[.weight] = UIFont.Weight.regular
            case "500":
                traits[.weight] = UIFont.Weight.medium
            case "600":
                traits[.weight] = UIFont.Weight.semibold
            case "700":
                traits[.weight] = UIFont.Weight.bold
            case "800":
                traits[.weight] = UIFont.Weight.heavy
            case "900":
                traits[.weight] = UIFont.Weight.black
            default:
                break
            }
            
            if !traits.isEmpty {
                fontDescriptor = fontDescriptor?.addingAttributes([.traits: traits])
            }
        }
        
        // Font style handling
        if let fontStyle = props["fontStyle"] as? String, fontStyle == "italic" {
            fontDescriptor = fontDescriptor?.withSymbolicTraits(.traitItalic)
        }
        
        // Apply font if we have changes and we're not using custom fonts
        if let descriptor = fontDescriptor, textView.font?.fontName.lowercased().contains("custom") != true {
            textView.font = UIFont(descriptor: descriptor, size: fontSize)
        } else if textView.font?.fontName.lowercased().contains("custom") != true {
            textView.font = UIFont.systemFont(ofSize: fontSize)
        }
        
        // Text alignment
        if let textAlign = props["textAlign"] as? String {
            switch textAlign {
            case "center":
                textView.textAlignment = .center
            case "right":
                textView.textAlignment = .right
            case "justify":
                textView.textAlignment = .justified
            default:
                textView.textAlignment = .left
            }
        }
        
        // Letter spacing
        if let letterSpacing = props["letterSpacing"] as? CGFloat {
            textView.attributedText = NSAttributedString(
                string: textView.text ?? "",
                attributes: [.kern: letterSpacing]
            )
        }
        
        // Line height
        if let lineHeight = props["lineHeight"] as? CGFloat {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineHeight - textView.font.lineHeight
            textView.attributedText = NSAttributedString(
                string: textView.text ?? "",
                attributes: [.paragraphStyle: paragraphStyle]
            )
        }
        
        // Text decoration
        if let textDecorationLine = props["textDecorationLine"] as? String {
            var attributes: [NSAttributedString.Key: Any] = [:]
            
            switch textDecorationLine {
            case "underline":
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            case "line-through":
                attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            default:
                break
            }
            
            if !attributes.isEmpty {
                let attributedString = NSMutableAttributedString(string: textView.text ?? "")
                attributedString.addAttributes(
                    attributes,
                    range: NSRange(location: 0, length: attributedString.length)
                )
                textView.attributedText = attributedString
            }
        }
        
        // Text transform
        if let textTransform = props["textTransform"] as? String,
           let text = textView.text {
            switch textTransform {
            case "uppercase":
                textView.text = text.uppercased()
            case "lowercase":
                textView.text = text.lowercased()
            case "capitalize":
                textView.text = text.capitalized
            default:
                break
            }
        }
        
        // Number of lines - iOS specific
        if let numberOfLines = props["numberOfLines"] as? Int {
            textView.numberOfLines = numberOfLines
        }
        
        // Text adjustments - Fixed property name
        if let adjustsFontSizeToFit = props["adjustsFontSizeToFit"] as? Bool {
            textView.adjustsFontSizeToFitWidth = adjustsFontSizeToFit
            
            if adjustsFontSizeToFit {
                if let minimumFontSize = props["minimumFontSize"] as? CGFloat {
                    textView.minimumScaleFactor = minimumFontSize / fontSize
                } else {
                    textView.minimumScaleFactor = 0.5 // Default
                }
            }
        }
        
        // Apply standard View styling
        applyViewStyling(view: textView, props: props)
        
        // Apply layout properties
        applyLayoutProps(textView, props: props)
        
        // Important: After settings are applied, make sure the text view can 
        // calculate its own intrinsic content size to help layout
        if textView.text?.isEmpty == false {
            textView.setNeedsLayout()
            textView.layoutIfNeeded()
        }
    }
    
    static func applyViewStyling(view: UIView, props: [String: Any]) {
        // Apply opacity
        if let opacity = props["opacity"] as? CGFloat {
            view.alpha = opacity
        }
        
        // Apply background color
        if let backgroundColor = props["backgroundColor"] as? String {
            view.backgroundColor = UIColorFromHex(backgroundColor)
        }
    }
    
    // No standard events for text components
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {}
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {}
    
    // Helper function to load custom fonts from the app bundle
    private static func loadCustomFont(_ fontFamily: String, size: CGFloat) -> UIFont? {
        // Check if font is already registered
        if let font = UIFont(name: fontFamily, size: size) {
            return font
        }
        
        // Try various font extensions
        let extensions = ["ttf", "otf"]
        
        for ext in extensions {
            // Check the app bundle for the font
            if let fontURL = Bundle.main.url(forResource: fontFamily, withExtension: ext) {
                // Register font
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
                
                // Try to create font after registration
                if let font = UIFont(name: fontFamily, size: size) {
                    print("Successfully loaded custom font: \(fontFamily)")
                    return font
                }
            }
            
            // Try asset folder structure
            let assetPathFormats = [
                "fonts/\(fontFamily)",
                "assets/fonts/\(fontFamily)",
                "flutter_assets/fonts/\(fontFamily)",
                "flutter_assets/assets/fonts/\(fontFamily)"
            ]
            
            for path in assetPathFormats {
                if let fontURL = Bundle.main.url(forResource: path, withExtension: ext) {
                    CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
                    
                    // Try to create font after registration
                    if let font = UIFont(name: fontFamily, size: size) {
                        print("Successfully loaded custom font from assets: \(fontFamily)")
                        return font
                    }
                }
            }
        }
        
        print("Could not load custom font: \(fontFamily)")
        return nil
    }
}
