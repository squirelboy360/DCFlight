import UIKit

extension UIColor {
    /// Create a UIColor from a hex string like "#FF0000" or "FF0000"
    /// Returns a default color (black) if the hex string is invalid
    static func colorFromHexString(_ hexString: String) -> UIColor {
        // Safety check for nil or empty strings
        guard !hexString.isEmpty else {
            NSLog("⚠️ Warning: Empty color string provided, using default black")
            return UIColor.black
        }
        
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        // Safety check for string length
        guard hexSanitized.count >= 6 else {
            NSLog("⚠️ Warning: Invalid hex color format: \(hexString), using default black")
            return UIColor.black
        }
        
        // If string is too long, truncate it to a valid length
        if hexSanitized.count > 6 {
            let startIndex = hexSanitized.startIndex
            let endIndex = hexSanitized.index(startIndex, offsetBy: 6)
            hexSanitized = String(hexSanitized[startIndex..<endIndex])
            NSLog("⚠️ Warning: Truncated hex color to valid format: #\(hexSanitized)")
        }
        
        var rgb: UInt64 = 0
        
        // Try to parse the hex value
        let success = Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        // If parsing failed, return a default color
        if !success {
            NSLog("⚠️ Warning: Failed to parse hex color: \(hexString), using default black")
            return UIColor.black
        }
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}