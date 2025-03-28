import UIKit
import yoga

class DCMauiTextComponent: NSObject, DCMauiComponentProtocol {
    static func createView(props: [String: Any]) -> UIView {
        let label = UILabel()
        
        // Configure default properties
        label.numberOfLines = 0  // Default to multi-line
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = .clear
        
        // Create Yoga node for this label
        let _ = DCMauiLayoutManager.shared.createYogaNode(for: label)
        
        // Set text content if available
        if let content = props["content"] as? String {
            label.text = content
        }
        
        // Apply all props
        updateView(label, props: props)
        
        return label
    }
    
    static func updateView(_ view: UIView, props: [String: Any]) {
        guard let label = view as? UILabel else { return }
        
        // Store original text before any attribute processing
        var originalText = label.text ?? ""
        
        // Basic text content
        if let content = props["content"] as? String {
            originalText = content
            label.text = content
            
            // Debug logging to track text content
            print("DCMauiTextComponent: Setting content to: '\(content)'")
        }
        
        // Font family and style properties
        var fontName: String?
        var fontSize: CGFloat = label.font?.pointSize ?? 17.0 // Default iOS font size
        var fontWeight: UIFont.Weight = .regular
        var fontStyle: UIFontDescriptor.SymbolicTraits = []
        
        // Get font family
        if let fontFamily = props["fontFamily"] as? String {
            fontName = fontFamily
        }
        
        // Get font size
        if let size = props["fontSize"] as? CGFloat {
            fontSize = size
        }
        
        // Get font weight
        if let weight = props["fontWeight"] as? String {
            switch weight {
            case "bold":
                fontWeight = .bold
            case "100":
                fontWeight = .ultraLight
            case "200":
                fontWeight = .thin
            case "300":
                fontWeight = .light
            case "400":
                fontWeight = .regular
            case "500":
                fontWeight = .medium
            case "600":
                fontWeight = .semibold
            case "700":
                fontWeight = .bold
            case "800":
                fontWeight = .heavy
            case "900":
                fontWeight = .black
            default:
                fontWeight = .regular
            }
        }
        
        // Get font style
        if let style = props["fontStyle"] as? String, style == "italic" {
            fontStyle.insert(.traitItalic)
        }
        
        // Create the font
        var font: UIFont?
        
        if let fontName = fontName {
            // Try to load custom font
            font = FontLoader.shared.loadFont(name: fontName, size: fontSize)
            
            // Apply weight if possible
            if let loadedFont = font {
                if let descriptor = loadedFont.fontDescriptor.withSymbolicTraits(fontStyle) {
                    font = UIFont(descriptor: descriptor, size: fontSize)
                }
            }
        }
        
        // Fallback to system font if custom font loading failed
        if font == nil {
            if fontStyle.contains(.traitItalic) {
                // For italic, we need to use the italicSystemFont or create a font descriptor with the italic trait
                if fontWeight == .bold {
                    let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                        .withSymbolicTraits([.traitBold, .traitItalic])!
                    font = UIFont(descriptor: descriptor, size: fontSize)
                } else {
                    font = UIFont.italicSystemFont(ofSize: fontSize)
                    
                    // Apply weight if not bold
                    if fontWeight != .regular {
                        let descriptor = font!.fontDescriptor.withSymbolicTraits(.traitItalic)!
                        let weightedDescriptor = UIFontDescriptor(fontAttributes: [
                            .family: font!.familyName,
                            .traits: [UIFontDescriptor.TraitKey.weight: fontWeight]
                        ])
                        font = UIFont(descriptor: descriptor.addingAttributes([
                            .traits: [UIFontDescriptor.TraitKey.weight: fontWeight]
                        ]), size: fontSize)
                    }
                }
            } else {
                // Regular case - use system font with weight
                font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
            }
        }
        
        // Apply the font
        if let font = font {
            label.font = font
        }
        
        // Create a base attributed string to work with - ONLY if needed
        // Using the most up-to-date text content
        let currentText = label.text ?? originalText
        let attributedText = NSMutableAttributedString(string: currentText)
        var hasAttributedChanges = false
        
        // Apply base font to the attributed string - only if we have text to work with
        if !currentText.isEmpty {
            attributedText.addAttribute(
                .font,
                value: label.font as Any,
                range: NSRange(location: 0, length: currentText.count)
            )
        }
        
        // Letter spacing - only apply if we have text
        if let letterSpacing = props["letterSpacing"] as? CGFloat, !currentText.isEmpty {
            attributedText.addAttribute(
                .kern,
                value: letterSpacing,
                range: NSRange(location: 0, length: currentText.count)
            )
            hasAttributedChanges = true
            print("DCMauiTextComponent: Applied letter spacing: \(letterSpacing)")
        }
        
        // Line height - only apply if we have text
        if let lineHeight = props["lineHeight"] as? CGFloat, !currentText.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            
            attributedText.addAttribute(
                .paragraphStyle,
                value: paragraphStyle,
                range: NSRange(location: 0, length: currentText.count)
            )
            hasAttributedChanges = true
            print("DCMauiTextComponent: Applied line height: \(lineHeight)")
        }
        
        // Text decoration - only apply if we have text
        if let decoration = props["textDecorationLine"] as? String, !currentText.isEmpty {
            switch decoration {
            case "underline":
                attributedText.addAttribute(
                    .underlineStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSRange(location: 0, length: currentText.count)
                )
                hasAttributedChanges = true
                print("DCMauiTextComponent: Applied underline decoration")
            case "line-through":
                attributedText.addAttribute(
                    .strikethroughStyle,
                    value: NSUnderlineStyle.single.rawValue,
                    range: NSRange(location: 0, length: currentText.count)
                )
                hasAttributedChanges = true
                print("DCMauiTextComponent: Applied line-through decoration")
            default:
                break
            }
        }
        
        // Apply the attributed text if we have any attribute changes AND text content
        if hasAttributedChanges && !currentText.isEmpty {
            label.attributedText = attributedText
            print("DCMauiTextComponent: Applied attributed text: '\(attributedText.string)'")
        }
        
        // Handle text transformation with additional safeguards
        if let transform = props["textTransform"] as? String {
            // Get the latest text content from either attributed or plain text
            let textToTransform: String
            if hasAttributedChanges, let attrText = label.attributedText?.string, !attrText.isEmpty {
                textToTransform = attrText
            } else if let plainText = label.text, !plainText.isEmpty {
                textToTransform = plainText
            } else {
                textToTransform = originalText
            }
            
            // Skip transformation if we don't have any text
            if textToTransform.isEmpty {
                print("DCMauiTextComponent: Warning - No text to transform")
            } else {
                var transformedText = textToTransform
                
                // Apply the transformation
                switch transform {
                case "uppercase":
                    transformedText = textToTransform.uppercased()
                    print("DCMauiTextComponent: Applied uppercase transform: '\(textToTransform)' → '\(transformedText)'")
                case "lowercase":
                    transformedText = textToTransform.lowercased()
                    print("DCMauiTextComponent: Applied lowercase transform: '\(textToTransform)' → '\(transformedText)'")
                case "capitalize":
                    transformedText = textToTransform.capitalized
                    print("DCMauiTextComponent: Applied capitalize transform: '\(textToTransform)' → '\(transformedText)'")
                default:
                    break
                }
                
                // Apply the transformed text
                if hasAttributedChanges {
                    // Update the attributed text to preserve all attributes
                    let newAttributedText = NSMutableAttributedString(attributedString: label.attributedText!)
                    
                    // Only update the string part while keeping attributes
                    if newAttributedText.length > 0 {
                        newAttributedText.mutableString.setString(transformedText)
                        label.attributedText = newAttributedText
                    } else {
                        // If for some reason we have empty attributed text, create a new one
                        let freshAttributedText = NSMutableAttributedString(string: transformedText)
                        // Copy attributes from original if possible
                        if let font = label.font {
                            freshAttributedText.addAttribute(.font, value: font, range: NSRange(location: 0, length: transformedText.count))
                        }
                        label.attributedText = freshAttributedText
                    }
                } else {
                    label.text = transformedText
                }
            }
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
        
        // Text color
        if let color = props["color"] as? String {
            label.textColor = UIColorFromHex(color)
        } else if let color = props["textColor"] as? String {
            // Support alternate property name for consistency
            label.textColor = UIColorFromHex(color)
        }
        
        // Number of lines
        if let numberOfLines = props["numberOfLines"] as? Int {
            label.numberOfLines = numberOfLines
        }
        
        // Enhanced verification with specific debugging 
        let finalText = label.attributedText?.string ?? label.text
        if finalText?.isEmpty ?? true {
            print("DCMauiTextComponent: WARNING - Text is empty after processing!")
            print("  - Original text: '\(originalText)'")
            print("  - Has attributed changes: \(hasAttributedChanges)")
            print("  - Props: \(props)")
            
            // Restore original text as a last resort
            label.text = originalText
            print("DCMauiTextComponent: Restored original text: '\(originalText)'")
        } else {
            print("DCMauiTextComponent: Final text content: '\(finalText ?? "")'")
        }
        
        // Auto-adjust font size
        if let adjustsFontSizeToFit = props["adjustsFontSizeToFit"] as? Bool, adjustsFontSizeToFit {
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = props["minimumFontSize"] as? CGFloat ?? 0.5
        }
        
        // Background color
        if let bgColorStr = props["backgroundColor"] as? String {
            label.backgroundColor = UIColorFromHex(bgColorStr)
        }
        
        // Opacity
        if let opacity = props["opacity"] as? CGFloat {
            label.alpha = opacity
        }
        
        // Border properties
        if let borderRadius = props["borderRadius"] as? CGFloat {
            label.layer.cornerRadius = borderRadius
            label.clipsToBounds = true
        }
        
        if let borderWidth = props["borderWidth"] as? CGFloat {
            label.layer.borderWidth = borderWidth
        }
        
        if let borderColor = props["borderColor"] as? String {
            label.layer.borderColor = UIColorFromHex(borderColor).cgColor
        }
        
        // Apply layout properties - this will handle all positioning and sizing
        applyLayoutProps(label, props: props)
    }
    
    static func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let label = view as? UILabel else { return }
        
        // Text components don't typically have many events, but we can add a tap recognizer
        if eventTypes.contains("press") || eventTypes.contains("tap") {
            // Make sure user interaction is enabled
            label.isUserInteractionEnabled = true
            
            // Add tap gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: nil, action: nil)
            tapGesture.addTarget { recognizer in
                let location = recognizer.location(in: view)
                eventCallback(viewId, "press", [
                    "x": location.x,
                    "y": location.y,
                    "text": label.text ?? ""
                ])
            }
            view.addGestureRecognizer(tapGesture)
        }
    }
    
    static func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        if eventTypes.contains("press") || eventTypes.contains("tap") {
            // Remove all gesture recognizers (this is a simple implementation)
            if let recognizers = view.gestureRecognizers {
                for recognizer in recognizers {
                    view.removeGestureRecognizer(recognizer)
                }
            }
        }
    }
}
