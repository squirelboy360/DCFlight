import UIKit
import dcflight
import CoreText

class DCFTextComponent: NSObject, DCFComponent, ComponentMethodHandler {
    // Dictionary to cache loaded fonts
    internal static var fontCache = [String: UIFont]()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create a label
        let label = UILabel()
        
        // Apply initial styling
        label.numberOfLines = 0
        label.textColor = UIColor.black
        
        // Apply props
        updateView(label, withProps: props)
        
        return label
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let label = view as? UILabel else { return false }
        
        // Set content if specified
        if let content = props["content"] as? String {
            label.text = content
        }
        
        // Get font size (default to system font size if not specified)
        let fontSize = props["fontSize"] as? CGFloat ?? UIFont.systemFontSize
        
        // Determine font weight
        var fontWeight = UIFont.Weight.regular
        if let fontWeightString = props["fontWeight"] as? String {
            fontWeight = fontWeightFromString(fontWeightString)
        }
        
        // Check if font is from an asset (with isFontAsset flag)
        let isFontAsset = props["isFontAsset"] as? Bool ?? false
        
        // Set font family if specified
        if let fontFamily = props["fontFamily"] as? String {
            if isFontAsset {
                // Use the same asset resolution approach as SVG
                let key = sharedFlutterViewController?.lookupKey(forAsset: fontFamily)
                let mainBundle = Bundle.main
                let path = mainBundle.path(forResource: key, ofType: nil)
                
                print("🔤 Font asset lookup - key: \(String(describing: key)), path: \(String(describing: path))")
                
                loadFontFromAsset(fontFamily, path: path, fontSize: fontSize, weight: fontWeight) { font in
                    if let font = font {
                        label.font = font
                    } else {
                        // Fallback to system font if custom font loading fails
                        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
                    }
                }
            } else {
                // Try to use a pre-installed font by name
                if let font = UIFont(name: fontFamily, size: fontSize) {
                    // Apply weight if needed
                    if fontWeight != .regular {
                        let descriptor = font.fontDescriptor.addingAttributes([
                            .traits: [UIFontDescriptor.TraitKey.weight: fontWeight]
                        ])
                        label.font = UIFont(descriptor: descriptor, size: fontSize)
                    } else {
                        label.font = font
                    }
                } else {
                    // Fallback to system font if font not found
                    label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
                }
            }
        } else {
            // Use system font with the specified size and weight
            label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
        
        // Set text color if specified
        if let color = props["color"] as? String {
            // Safely parse the color string - will use a default color if the string is invalid
            label.textColor = ColorUtilities.color(fromHexString:color)
        }
        
        // Set text alignment if specified
        if let textAlign = props["textAlign"] as? String {
            switch textAlign {
            case "center":
                label.textAlignment = .center
            case "right":
                label.textAlignment = .right
            case "justify":
                label.textAlignment = .justified
            default:
                label.textAlignment = .left
            }
        }
        
        // Set number of lines if specified
        if let numberOfLines = props["numberOfLines"] as? Int {
            label.numberOfLines = numberOfLines
        }
        
        return true
    }
    
    // Handle component methods
        func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
            guard let label = view as? UILabel else { return false }
            
            switch methodName {
            case "setText":
                if let text = args["text"] as? String {
                    label.text = text
                    return true
                }
            default:
                return false
            }
            
            return false
        }

}



