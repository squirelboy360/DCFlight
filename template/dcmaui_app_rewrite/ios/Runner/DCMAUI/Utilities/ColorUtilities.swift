import UIKit

/// Utilities for color conversion
class ColorUtilities {
    
    /// Convert a hex string to a UIColor
    /// Format: "#RRGGBB" or "#RRGGBBAA" or "#AARRGGBB" (Android format)
    static func color(fromHexString hexString: String) -> UIColor? {
        // Check for Flutter's Colors.transparent (which comes as 0x00000000 or 0)
        if hexString == "0x00000000" || hexString == "0" || hexString.lowercased() == "transparent" {
            print("🔍 Detected transparent color from Flutter: \(hexString)")
            return UIColor.clear
        }
        
        // Print debug info for troubleshooting color issues
        print("⚡️ ColorUtilities: Processing color string: \(hexString)")
        
        var cleanHexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Special handling for Material colors from Flutter
        // These come in as positive integer values
        if let intValue = Int(cleanHexString), intValue >= 0 {
            print("🎨 Converting Flutter color integer value: \(intValue)")
            
            // Check for transparent (0)
            if intValue == 0 {
                return UIColor.clear
            }
            
            // Convert the int to hex - Flutter uses ARGB format
            let hexValue = String(format: "#%08x", intValue)
            cleanHexString = hexValue
        }
        
        cleanHexString = cleanHexString.replacingOccurrences(of: "#", with: "")
        
        // Handle common color names
        if cleanHexString.lowercased() == "red" { return .red }
        if cleanHexString.lowercased() == "green" { return .green }
        if cleanHexString.lowercased() == "blue" { return .blue }
        if cleanHexString.lowercased() == "black" { return .black }
        if cleanHexString.lowercased() == "white" { return .white }
        if cleanHexString.lowercased() == "yellow" { return .yellow }
        if cleanHexString.lowercased() == "purple" { return .purple }
        if cleanHexString.lowercased() == "orange" { return .orange }
        if cleanHexString.lowercased() == "cyan" { return .cyan }
        if cleanHexString.lowercased() == "clear" { return .clear }
        
        // For 3-character hex codes like #RGB
        if cleanHexString.count == 3 {
            let r = String(cleanHexString[cleanHexString.startIndex])
            let g = String(cleanHexString[cleanHexString.index(cleanHexString.startIndex, offsetBy: 1)])
            let b = String(cleanHexString[cleanHexString.index(cleanHexString.startIndex, offsetBy: 2)])
            cleanHexString = r + r + g + g + b + b
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHexString).scanHexInt64(&rgbValue)
        
        var alpha: CGFloat = 1.0
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        
        switch cleanHexString.count {
        case 8: // 8 characters: AARRGGBB format used by Flutter
            alpha = CGFloat((rgbValue >> 24) & 0xFF) / 255.0
            red = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
            green = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgbValue & 0xFF) / 255.0
            
            // Check for transparent color (alpha = 0)
            if alpha == 0 {
                print("🔍 Detected transparent color (alpha=0)")
                return UIColor.clear
            }
            
        case 6: // 6 characters: RRGGBB
            red = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
            green = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgbValue & 0xFF) / 255.0
            alpha = 1.0
            
        default:
            print("⚠️ Invalid color format: \(cleanHexString) (length: \(cleanHexString.count))")
            return .magenta // Return a bright color to make issues obvious
        }
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        print("🎨 Color components: R=\(red), G=\(green), B=\(blue), A=\(alpha) -> UIColor: \(color)")
        return color
    }
    
    /// Convert UIColor to hex string
    static func hexString(from color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Return "transparent" for completely transparent colors
        if alpha == 0 {
            return "transparent"
        }
        
        let rgb = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
    
    /// Check if a color string represents transparent
    static func isTransparent(_ colorString: String) -> Bool {
        let lowerString = colorString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return lowerString == "transparent" ||
               lowerString == "clear" ||
               lowerString == "0x00000000" ||
               lowerString == "rgba(0,0,0,0)" ||
               lowerString == "#00000000" ||
               lowerString == "0"
    }
}
