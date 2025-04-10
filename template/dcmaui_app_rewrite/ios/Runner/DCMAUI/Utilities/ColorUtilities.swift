import UIKit

/// Utilities for color conversion
class ColorUtilities {
    
    /// Convert a hex string to a UIColor
    /// Format: "#RRGGBB" or "#RRGGBBAA" or "#AARRGGBB" (Android format)
    static func color(fromHexString hexString: String) -> UIColor? {
        print("color is being converted from hex string: \(hexString)")
        if(hexString == "0x00000000"){
            print("transparent color hit");
        }
        // Print debug info for troubleshooting color issues
        print("⚡️ ColorUtilities: Processing color string: \(hexString)")
        
        // CRITICAL FIX: Handle "transparent" as a special keyword
        if hexString.lowercased() == "transparent" {
            print("🔍 Detected transparent color")
            return UIColor.clear
        }
        
        var cleanHexString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // CRITICAL FIX: Handle RGBA format from Flutter (rgba(r,g,b,a))
        if cleanHexString.hasPrefix("rgba(") && cleanHexString.hasSuffix(")") {
            print("🔍 Detected RGBA format")
            let rgbaContent = cleanHexString.dropFirst(5).dropLast(1)
            let components = rgbaContent.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            if components.count == 4,
               let r = Float(components[0]),
               let g = Float(components[1]),
               let b = Float(components[2]),
               let a = Float(components[3]) {
                
                // RGBA values are typically 0-255 for RGB and 0-1 for alpha
                let red = CGFloat(r) / 255.0
                let green = CGFloat(g) / 255.0
                let blue = CGFloat(b) / 255.0
                let alpha = CGFloat(a)
                
                print("🎨 RGBA components: R=\(red), G=\(green), B=\(blue), A=\(alpha)")
                return UIColor(red: red, green: green, blue: blue, alpha: alpha)
            }
        }
        
        // Special handling for Material colors from Flutter
        // These come in as positive integer values
        if let intValue = Int(cleanHexString), intValue > 0 {
            print("🎨 Converting int color value: \(intValue)")
            // Convert the int to hex - Flutter uses ARGB format
            let hexValue = String(format: "#%08x", intValue)
            cleanHexString = hexValue
        }
        
        // CRITICAL FIX: Detect 0 value specifically for transparent
        if cleanHexString == "0" || cleanHexString == "0x0" || cleanHexString == "#0" {
            print("🔍 Detected transparent color (0 value)")
            return UIColor.clear
        }
        
        cleanHexString = cleanHexString.replacingOccurrences(of: "#", with: "")
        
        // CRITICAL FIX: Handle common color names
        if cleanHexString.lowercased() == "red" { return .red }
        if cleanHexString.lowercased() == "green" { return .green }
        if cleanHexString.lowercased() == "blue" { return .blue }
        if cleanHexString.lowercased() == "black" { return .black }
        if cleanHexString.lowercased() == "white" { return .white }
        if cleanHexString.lowercased() == "yellow" { return .yellow }
        if cleanHexString.lowercased() == "purple" { return .purple }
        if cleanHexString.lowercased() == "orange" { return .orange }
        if cleanHexString.lowercased() == "cyan" { return .cyan }
        if cleanHexString.lowercased() == "clear" || 
           cleanHexString.lowercased() == "transparent" { return .clear }
        
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
        
        // CRITICAL FIX: Better hex parsing with proper logging
        switch cleanHexString.count {
        case 8: // 8 characters: either AARRGGBB or RRGGBBAA
            // Check if it's AARRGGBB or RRGGBBAA format
            let isARGB = true // Default to ARGB format (Flutter standard)
            
            if isARGB {
                // AARRGGBB format (Android/Flutter)
                alpha = CGFloat((rgbValue >> 24) & 0xFF) / 255.0
                red = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
                green = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
                blue = CGFloat(rgbValue & 0xFF) / 255.0
                
                // CRITICAL FIX: Check for transparent color (alpha = 0)
                if alpha == 0 {
                    print("🔍 Detected transparent color (alpha=0)")
                    return UIColor.clear
                }
            } else {
                // RRGGBBAA format
                red = CGFloat((rgbValue >> 24) & 0xFF) / 255.0
                green = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
                blue = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
                alpha = CGFloat(rgbValue & 0xFF) / 255.0
                
                // CRITICAL FIX: Check for transparent color (alpha = 0)
                if alpha == 0 {
                    print("🔍 Detected transparent color (alpha=0)")
                    return UIColor.clear
                }
            }
        case 6: // 6 characters: RRGGBB
            red = CGFloat((rgbValue >> 16) & 0xFF) / 255.0
            green = CGFloat((rgbValue >> 8) & 0xFF) / 255.0
            blue = CGFloat(rgbValue & 0xFF) / 255.0
            alpha = 1.0
            
            // CRITICAL FIX: Check for special case of all zeros (represents transparent in some systems)
            if red == 0 && green == 0 && blue == 0 && hexString.lowercased().contains("transparent") {
                print("🔍 Detected transparent color (context clue)")
                return UIColor.clear
            }
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
        
        // CRITICAL FIX: Handle transparent color specially
        if alpha == 0 {
            return "transparent"
        }
        
        if alpha < 1.0 {
            // Include alpha in the hex string for non-opaque colors
            let argb = (Int)(alpha * 255) << 24 | (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
            return String(format: "#%08x", argb)
        } else {
            // Just RGB for fully opaque colors
            let rgb = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
            return String(format: "#%06x", rgb)
        }
    }
    
    /// CRITICAL FIX: Add helper to explicitly check if a color string represents transparent
    static func isTransparent(_ colorString: String) -> Bool {
        let lowerString = colorString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        return lowerString == "transparent" ||
               lowerString == "clear" ||
               lowerString == "0x00000000" ||
               lowerString == "rgba(0,0,0,0)" ||
               lowerString == "rgba(0, 0, 0, 0)" ||
               lowerString == "#00000000" ||
               lowerString == "0" ||
               lowerString == "0x0"
    }
}
