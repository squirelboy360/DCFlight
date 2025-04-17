import UIKit

// Extension to help with font weight preservation
extension UIFont {
    func getFontWeight() -> UIFont.Weight {
        // Get the font descriptor attributes
        let attributes = self.fontDescriptor.fontAttributes
        
        // Check for the weight in the traits
        if let traits = attributes[.traits] as? [UIFontDescriptor.TraitKey: Any],
           let weightNumber = traits[.weight] as? NSNumber {
            let weightValue = CGFloat(weightNumber.doubleValue)
            
            // Map the weight value to a UIFont.Weight
            // The mapping is approximate as UIFont.Weight doesn't have public numeric values
            switch weightValue {
            case ...UIFont.Weight.ultraLight.rawValue:
                return .ultraLight
            case ...UIFont.Weight.thin.rawValue:
                return .thin
            case ...UIFont.Weight.light.rawValue:
                return .light
            case ...UIFont.Weight.regular.rawValue:
                return .regular
            case ...UIFont.Weight.medium.rawValue:
                return .medium
            case ...UIFont.Weight.semibold.rawValue:
                return .semibold
            case ...UIFont.Weight.bold.rawValue:
                return .bold
            case ...UIFont.Weight.heavy.rawValue:
                return .heavy
            default:
                return .black
            }
        }
        
        // Fall back to checking the font name
        let fontName = self.fontName.lowercased()
        if fontName.contains("bold") {
            return .bold
        } else if fontName.contains("light") {
            return .light
        } else if fontName.contains("medium") {
            return .medium
        } else if fontName.contains("heavy") || fontName.contains("black") {
            return .heavy
        } else if fontName.contains("semibold") {
            return .semibold
        } else if fontName.contains("thin") {
            return .thin
        } else if fontName.contains("ultralight") {
            return .ultraLight
        }
        
        // Default to regular weight
        return .regular
    }
}
