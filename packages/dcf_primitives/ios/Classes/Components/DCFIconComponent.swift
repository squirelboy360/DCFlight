import UIKit
import dcflight

/// DCFIcon component that renders built-in icons by name
class DCFIconComponent: NSObject, DCFComponent {
    // Reuse the SVG component for rendering
    private let svgComponent = DCFSvgComponent()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create image view
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        // Apply props
        updateView(imageView, withProps: props)
        
        return imageView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let imageView = view as? UIImageView else { return false }
        
        // Get icon name
        if let iconName = props["name"] as? String {
            // Get asset path directly from icon name
            let assetPath = getAssetPath(for: iconName)
            
            // Create SVG props
            var svgProps = props
            svgProps["asset"] = assetPath
            
            // Use SVG component to load the icon
            return svgComponent.updateView(imageView, withProps: svgProps)
        }
        
        return false
    }
    
    // Get the asset path for an icon name
    private func getAssetPath(for iconName: String) -> String {
        // No need for a mapping dictionary - directly use the icon name
        // The source of truth is maintained on the Dart side
        return "DCFIcons/\(iconName)"
    }
}