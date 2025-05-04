import UIKit
import dcflight

class DCFIconComponent: NSObject, DCFComponent, ComponentMethodHandler {
    // Store a cache of loaded SVGs
    private static var svgCache: [String: UIImage] = [:]
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create an image view to display the icon
        let imageView = UIImageView()
        
        // Apply initial styling
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        // Apply props
        updateView(imageView, withProps: props)
        
        return imageView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let imageView = view as? UIImageView else { return false }
        
        // Get the icon name
        if let name = props["name"] as? String {
            // Load the SVG icon
            loadIcon(name: name, into: imageView, props: props)
        }
        
        // Set tint color if specified
        if let color = props["color"] as? String {
            imageView.tintColor = ColorUtilities.color(fromHexString: color)
        }
        
        return true
    }
    
    // Handle component methods
    func handleMethod(methodName: String, args: [String: Any], view: UIView) -> Bool {
        guard let imageView = view as? UIImageView else { return false }
        
        switch methodName {
        case "setIcon":
            if let name = args["name"] as? String {
                loadIcon(name: name, into: imageView, props: [:])
                return true
            }
        default:
            return false
        }
        
        return false
    }
    
    // Load an icon from the bundle
    private func loadIcon(name: String, into imageView: UIImageView, props: [String: Any]) {
        // Try multiple bundle locations
        let iconName = name.replacingOccurrences(of: "DCFIcons/", with: "")
        
        // First, try to load from cache
        if let cachedImage = DCFIconComponent.svgCache[iconName] {
            imageView.image = cachedImage
            triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
            return
        }
        
        // Set fallback placeholder image
        let placeholderImage = generatePlaceholderImage(
            size: CGSize(width: 24, height: 24),
            iconName: iconName
        )
        imageView.image = placeholderImage
        
        // Try to load from application bundle or framework bundle
        let bundlePaths = [
            Bundle.main.bundlePath,
            Bundle(for: DCFIconComponent.self).bundlePath,
            // Add more potential paths here
        ]
        
        // Search in potential icon directories
        let iconDirs = ["Images", "Assets", "Resources", "Icons", "SVG"]
        
        // Extensions to try
        let extensions = ["svg", "png", "pdf"]
        
        var loaded = false
        
        // Try different combinations of paths, directories, filenames, and extensions
        for bundlePath in bundlePaths {
            for directory in iconDirs {
                for ext in extensions {
                    // Try with directory path
                    let fullPath = "\(bundlePath)/\(directory)/\(iconName).\(ext)"
                    if FileManager.default.fileExists(atPath: fullPath),
                       let image = loadImageFromPath(fullPath) {
                        imageView.image = image
                        DCFIconComponent.svgCache[iconName] = image
                        triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
                        loaded = true
                        break
                    }
                    
                    // Try without directory
                    let directPath = "\(bundlePath)/\(iconName).\(ext)"
                    if FileManager.default.fileExists(atPath: directPath),
                       let image = loadImageFromPath(directPath) {
                        imageView.image = image
                        DCFIconComponent.svgCache[iconName] = image
                        triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
                        loaded = true
                        break
                    }
                }
                if loaded { break }
            }
            if loaded { break }
        }
        
        // If we couldn't find the icon, trigger error event
        if !loaded {
            print("❌ Failed to load SVG: \(name)")
            triggerEvent(on: imageView, eventType: "onError", eventData: ["error": "Icon not found"])
        }
    }
    
    // Load an image from a file path
    private func loadImageFromPath(_ path: String) -> UIImage? {
        // For now just try to load directly - in a real implementation,
        // this would handle different formats like SVG
        if path.hasSuffix(".svg") {
            // SVG loading would require a library like SVGKit
            // For this implementation, just return nil
            return nil
        } else {
            return UIImage(contentsOfFile: path)
        }
    }
    
    // Generate a placeholder image
    private func generatePlaceholderImage(size: CGSize, iconName: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Draw background
            UIColor.lightGray.withAlphaComponent(0.2).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw border
            UIColor.lightGray.setStroke()
            context.stroke(CGRect(origin: .zero, size: size))
            
            // Draw "?" in the center
            let text = "?"
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.darkGray,
                .font: UIFont.systemFont(ofSize: min(size.width, size.height) * 0.6)
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}