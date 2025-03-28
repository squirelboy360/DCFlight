//
//  DCText.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Text component that matches React Native's Text
class DCText: DCBaseView {
    // MARK: - Properties
    private let label = UILabel()
    
    // Text properties
    private var fontFamily: String?
    private var fontSize: CGFloat = 14.0
    private var fontWeight: String?
    private var fontStyle: String?
    private var color: UIColor = .black
    private var lineSpacing: CGFloat = 0
    private var letterSpacing: CGFloat = 0
    private var textAlign: NSTextAlignment = .left
    private var textDecorationLine: String?
    private var textDecorationColor: UIColor?
    private var textDecorationStyle: String?
    private var includeFontPadding: Bool = true
    private var numberOfLines: Int = 0
    
    // MARK: - Initialization
    override func setupView() {
        super.setupView()
        
        // Configure label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0  // Default to multiline
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        
        // Set default font
        label.font = UIFont.systemFont(ofSize: fontSize)
        
        // Add label to view
        addSubview(label)
        
        // Set constraints
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Props Handling
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Set text content
        if let text = props["text"] as? String {
            updateTextContent(text)
        }
        
        // Apply style properties if present
        if let style = props["style"] as? [String: Any] {
            applyTextStyles(style)
        }
        
        // Handle specific props for text
        if let adjustsFontSizeToFit = props["adjustsFontSizeToFit"] as? Bool {
            label.adjustsFontSizeToFitWidth = adjustsFontSizeToFit
        }
        
        if let minimumFontScale = props["minimumFontScale"] as? CGFloat {
            label.minimumScaleFactor = minimumFontScale
        }
        
        if let numberOfLines = props["numberOfLines"] as? Int {
            self.numberOfLines = numberOfLines
            label.numberOfLines = numberOfLines
        }
        
        if let selectable = props["selectable"] as? Bool, selectable {
            makeTextSelectable()
        }
    }
    
    private func updateTextContent(_ text: String) {
        // Apply text with current attributes
        if textDecorationLine != nil || letterSpacing != 0 || lineSpacing != 0 {
            let attributedString = createAttributedString(from: text)
            label.attributedText = attributedString
        } else {
            label.text = text
        }
    }
    
    private func createAttributedString(from text: String) -> NSAttributedString {
        let attributes = createTextAttributes()
        let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        
        if lineSpacing != 0 {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.alignment = textAlign
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: text.count))
        }
        
        return attributedString
    }
    
    private func createTextAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        
        // Font
        attributes[.font] = label.font
        
        // Text color
        attributes[.foregroundColor] = color
        
        // Letter spacing (kerning)
        if letterSpacing != 0 {
            attributes[.kern] = letterSpacing
        }
        
        // Handle text decoration
        if let textDecorationLine = textDecorationLine {
            var underlineStyle: NSUnderlineStyle = []
            
            switch textDecorationLine {
            case "underline":
                underlineStyle = .single
            case "line-through":
                attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            case "underline line-through":
                underlineStyle = .single
                attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            default:
                break
            }
            
            if !underlineStyle.isEmpty {
                attributes[.underlineStyle] = underlineStyle.rawValue
            }
            
            if let textDecorationColor = textDecorationColor {
                if !underlineStyle.isEmpty {
                    attributes[.underlineColor] = textDecorationColor
                }
                if attributes[.strikethroughStyle] != nil {
                    attributes[.strikethroughColor] = textDecorationColor
                }
            }
        }
        
        return attributes
    }
    
    private func applyTextStyles(_ style: [String: Any]) {
        // Font family
        if let fontFamily = style["fontFamily"] as? String {
            self.fontFamily = fontFamily
            updateFont()
        }
        
        // Font size
        if let fontSize = style["fontSize"] as? CGFloat {
            self.fontSize = fontSize
            updateFont()
        }
        
        // Font weight
        if let fontWeight = style["fontWeight"] as? String {
            self.fontWeight = fontWeight
            updateFont()
        }
        
        // Font style
        if let fontStyle = style["fontStyle"] as? String {
            self.fontStyle = fontStyle
            updateFont()
        }
        
        // Text color
        if let colorString = style["color"] as? String, colorString.hasPrefix("#") {
            color = UIColor(hexString: colorString)
            label.textColor = color
        }
        
        // Line height & spacing
        if let lineHeight = style["lineHeight"] as? CGFloat {
            // Convert line height to line spacing
            let calculatedLineSpacing = lineHeight - label.font.lineHeight
            lineSpacing = max(0, calculatedLineSpacing)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            paragraphStyle.alignment = textAlign
            
            if let attributedText = label.attributedText {
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                mutableAttributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: mutableAttributedText.length))
                label.attributedText = mutableAttributedText
            } else if let text = label.text {
                label.attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])
            }
        }
        
        // Letter spacing
        if let letterSpacing = style["letterSpacing"] as? CGFloat {
            self.letterSpacing = letterSpacing
            
            if let text = label.text {
                let attributedString = NSMutableAttributedString(string: text)
                attributedString.addAttribute(.kern, value: letterSpacing, range: NSRange(location: 0, length: text.count))
                label.attributedText = attributedString
            }
        }
        
        // Text alignment
        if let textAlign = style["textAlign"] as? String {
            switch textAlign {
            case "auto":
                self.textAlign = .natural
            case "left":
                self.textAlign = .left
            case "right":
                self.textAlign = .right
            case "center":
                self.textAlign = .center
            case "justify":
                self.textAlign = .justified
            default:
                self.textAlign = .natural
            }
            label.textAlignment = self.textAlign
        }
        
        // Text decoration
        if let textDecorationLine = style["textDecorationLine"] as? String {
            self.textDecorationLine = textDecorationLine
            
            // Need to reapply text to update the decorations
            if let text = label.text {
                updateTextContent(text)
            }
        }
        
        if let textDecorationColor = style["textDecorationColor"] as? String, textDecorationColor.hasPrefix("#") {
            self.textDecorationColor = UIColor(hexString: textDecorationColor)
            
            // Need to reapply text to update the decoration color
            if let text = label.text {
                updateTextContent(text)
            }
        }
        
        // Text vertical alignments
        if let textAlignVertical = style["textAlignVertical"] as? String {
            switch textAlignVertical {
            case "center":
                label.baselineAdjustment = .alignCenters
            case "top":
                label.baselineAdjustment = .alignBaselines
            case "bottom":
                label.baselineAdjustment = .alignBaselines
                // No direct equivalent in UILabel for bottom alignment
            default:
                label.baselineAdjustment = .alignBaselines
            }
        }
    }
    
    private func updateFont() {
        var font: UIFont
        
        if let fontFamily = self.fontFamily {
            // Try to get the specified font family
            if let customFont = UIFont(name: fontFamily, size: fontSize) {
                font = customFont
            } else {
                // Fallback to system font
                font = UIFont.systemFont(ofSize: fontSize)
            }
        } else {
            // Use system font
            font = UIFont.systemFont(ofSize: fontSize)
        }
        
        // Apply font weight if specified
        if let fontWeight = self.fontWeight {
            var traits = font.fontDescriptor.symbolicTraits
            
            switch fontWeight {
            case "bold", "700", "800", "900":
                traits.insert(.traitBold)
            default:
                // For other weights, we can try to use the system font weight
                let weight = getFontWeight(from: fontWeight)
                font = UIFont.systemFont(ofSize: fontSize, weight: weight)
            }
            
            if traits.contains(.traitBold) {
                if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                    font = UIFont(descriptor: descriptor, size: fontSize)
                }
            }
        }
        
        // Apply italic style if specified
        if let fontStyle = self.fontStyle, fontStyle == "italic" {
            var traits = font.fontDescriptor.symbolicTraits
            traits.insert(.traitItalic)
            
            if let descriptor = font.fontDescriptor.withSymbolicTraits(traits) {
                font = UIFont(descriptor: descriptor, size: fontSize)
            }
        }
        
        label.font = font
    }
    
    private func getFontWeight(from string: String) -> UIFont.Weight {
        switch string {
        case "normal", "400", "regular":
            return .regular
        case "bold", "700":
            return .bold
        case "100", "thin":
            return .thin
        case "200", "ultraLight":
            return .ultraLight
        case "300", "light":
            return .light
        case "500", "medium":
            return .medium
        case "600", "semibold":
            return .semibold
        case "800", "heavy":
            return .heavy
        case "900", "black":
            return .black
        default:
            return .regular
        }
    }
    
    private func makeTextSelectable() {
        // Make the text selectable in iOS
        // This requires a complex implementation with UITextView
        // For simplicity, we just enable user interaction here
        isUserInteractionEnabled = true
    }
    
    override var intrinsicContentSize: CGSize {
        return label.intrinsicContentSize
    }
}
