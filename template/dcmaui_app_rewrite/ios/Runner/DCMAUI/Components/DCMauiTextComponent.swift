import UIKit
import yoga

class DCMauiTextComponent: NSObject, DCMauiComponent {
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create label
        let label = UILabel()
        
        // Apply all styling props first
        label.applyStyles(props: props)
        
        // Then apply text-specific props
        applyTextProps(label, props: props)
        
        return label
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let label = view as? UILabel else { return false }
        
        // Apply all styling props first
        label.applyStyles(props: props)
        
        // Then apply text-specific props
        applyTextProps(label, props: props)
        
        return true
    }
    
    private func applyTextProps(_ label: UILabel, props: [String: Any]) {
        // Text specific properties (not styling)
        if let content = props["content"] as? String {
            label.text = content
        }
        
        if let color = props["color"] as? String {
            label.textColor = ColorUtilities.color(fromHexString: color)
        }
        
        if let fontSize = props["fontSize"] as? CGFloat {
            // Create a font with the current weight (if any) but new size
            if let currentFont = label.font {
                label.font = UIFont(descriptor: currentFont.fontDescriptor, size: fontSize)
            } else {
                label.font = UIFont.systemFont(ofSize: fontSize)
            }
        }
        
        if let fontWeight = props["fontWeight"] as? String {
            var weight: UIFont.Weight = .regular
            
            switch fontWeight {
            case "bold", "700":
                weight = .bold
            case "600":
                weight = .semibold
            case "500":
                weight = .medium
            case "400", "normal", "regular":
                weight = .regular
            case "300":
                weight = .light
            case "200":
                weight = .thin
            case "100":
                weight = .ultraLight
            default:
                weight = .regular
            }
            
            let size = label.font?.pointSize ?? 17
            label.font = UIFont.systemFont(ofSize: size, weight: weight)
        }
        
        if let fontFamily = props["fontFamily"] as? String {
            if let font = UIFont(name: fontFamily, size: label.font?.pointSize ?? 17) {
                label.font = font
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
            case "justified":
                label.textAlignment = .justified
            default:
                label.textAlignment = .natural
            }
        }
        
        if let lineHeight = props["lineHeight"] as? CGFloat {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
            
            let attributedString = NSMutableAttributedString(string: label.text ?? "")
            attributedString.addAttribute(
                .paragraphStyle,
                value: paragraphStyle,
                range: NSRange(location: 0, length: attributedString.length)
            )
            
            // Add the line height offset to center the text within line height
            if let font = label.font {
                let offset = (lineHeight - font.lineHeight) / 4
                attributedString.addAttribute(
                    .baselineOffset,
                    value: offset,
                    range: NSRange(location: 0, length: attributedString.length)
                )
            }
            
            label.attributedText = attributedString
        }
        
        if let letterSpacing = props["letterSpacing"] as? CGFloat {
            let attributedString: NSMutableAttributedString
            if let current = label.attributedText {
                attributedString = NSMutableAttributedString(attributedString: current)
            } else {
                attributedString = NSMutableAttributedString(string: label.text ?? "")
            }
            
            attributedString.addAttribute(
                .kern,
                value: letterSpacing,
                range: NSRange(location: 0, length: attributedString.length)
            )
            
            label.attributedText = attributedString
        }
        
        if let numberOfLines = props["numberOfLines"] as? Int {
            label.numberOfLines = numberOfLines
        }
        
        // Set appropriate line break mode
        if let numberOfLines = props["numberOfLines"] as? Int, numberOfLines > 0 {
            label.lineBreakMode = .byTruncatingTail
        } else {
            label.lineBreakMode = .byWordWrapping
        }
        
        // Ensure minimum hit size for accessibility
        if label.bounds.width < 44 || label.bounds.height < 44 {
            label.isUserInteractionEnabled = true
        }
    }
    
    func addEventListeners(to view: UIView, viewId: String, eventTypes: [String], 
                          eventCallback: @escaping (String, String, [String: Any]) -> Void) {
        guard let label = view as? UILabel else { return }
        
        // Add press gesture recognizer if needed
        if eventTypes.contains("press") {
            label.isUserInteractionEnabled = true
            
            // Remove existing gesture recognizers first
            if let existingGestureRecognizers = label.gestureRecognizers {
                for recognizer in existingGestureRecognizers {
                    if recognizer is UITapGestureRecognizer {
                        label.removeGestureRecognizer(recognizer)
                    }
                }
            }
            
            // Create and add tap gesture recognizer
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLabelTap(_:)))
            label.addGestureRecognizer(tapGesture)
            
            // Store callback and viewId for the event handler
            objc_setAssociatedObject(
                label,
                UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!,
                eventCallback,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            objc_setAssociatedObject(
                label,
                UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
                viewId,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    func removeEventListeners(from view: UIView, viewId: String, eventTypes: [String]) {
        guard let label = view as? UILabel else { return }
        
        if eventTypes.contains("press") {
            // Remove existing gesture recognizers
            if let existingGestureRecognizers = label.gestureRecognizers {
                for recognizer in existingGestureRecognizers {
                    if recognizer is UITapGestureRecognizer {
                        label.removeGestureRecognizer(recognizer)
                    }
                }
            }
            
            // Clean up stored properties
            objc_setAssociatedObject(
                label,
                UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            objc_setAssociatedObject(
                label,
                UnsafeRawPointer(bitPattern: "viewId".hashValue)!,
                nil,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
            
            // Reset user interaction if not needed
            label.isUserInteractionEnabled = false
        }
    }
    
    @objc private func handleLabelTap(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel,
              let callback = objc_getAssociatedObject(
                label,
                UnsafeRawPointer(bitPattern: "eventCallback".hashValue)!
              ) as? (String, String, [String: Any]) -> Void,
              let viewId = objc_getAssociatedObject(
                label,
                UnsafeRawPointer(bitPattern: "viewId".hashValue)!
              ) as? String else {
            return
        }
        
        callback(viewId, "press", [:])
    }
}
