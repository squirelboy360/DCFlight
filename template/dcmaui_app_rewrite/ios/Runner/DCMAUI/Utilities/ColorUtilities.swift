import UIKit

/// Convert hex color string to UIColor
func UIColorFromHex(_ hexString: String) -> UIColor {
    var colorString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if colorString.hasPrefix("#") {
        colorString = String(colorString.dropFirst())
    }
    
    // Check for rgba format
    if colorString.hasPrefix("RGBA") {
        // Parse rgba format
        colorString = colorString.replacingOccurrences(of: "RGBA(", with: "")
            .replacingOccurrences(of: ")", with: "")
        let components = colorString.components(separatedBy: ",")
        if components.count >= 4,
           let r = Float(components[0]),
           let g = Float(components[1]),
           let b = Float(components[2]),
           let a = Float(components[3]) {
            return UIColor(
                red: CGFloat(r/255.0),
                green: CGFloat(g/255.0),
                blue: CGFloat(b/255.0),
                alpha: CGFloat(a)
            )
        }
    }
    
    // Check for rgba hex format (8 characters)
    if colorString.count == 8 {
        // Format: RRGGBBAA
        let scanner = Scanner(string: colorString)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
            let g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
            let b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
            let a = CGFloat(hexNumber & 0x000000FF) / 255.0
            
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
    }
    
    // Handle different length hex codes
    let scanner = Scanner(string: colorString)
    var hexNumber: UInt64 = 0
    
    if scanner.scanHexInt64(&hexNumber) {
        switch colorString.count {
        case 3: // Short hex format like #RGB
            let r = CGFloat((hexNumber & 0xF00) >> 8) / 15.0
            let g = CGFloat((hexNumber & 0x0F0) >> 4) / 15.0
            let b = CGFloat(hexNumber & 0x00F) / 15.0
            return UIColor(red: r, green: g, blue: b, alpha: 1.0)
            
        case 6: // Regular hex format like #RRGGBB
            let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(hexNumber & 0x0000FF) / 255.0
            return UIColor(red: r, green: g, blue: b, alpha: 1.0)
            
        default:
            break
        }
    }
    
    // Check for named color constants
    switch colorString {
    case "RED": return .red
    case "GREEN": return .green
    case "BLUE": return .blue
    case "BLACK": return .black
    case "WHITE": return .white
    case "GRAY", "GREY": return .gray
    case "YELLOW": return .yellow
    case "ORANGE": return .orange
    case "PURPLE": return .purple
    case "BROWN": return .brown
    case "CYAN": return .cyan
    case "MAGENTA": return .magenta
    case "CLEAR": return .clear
    default:
        break
    }
    
    // Fallback to a default color
    print("Failed to parse color: \(hexString), using default")
    return UIColor.darkGray
}
