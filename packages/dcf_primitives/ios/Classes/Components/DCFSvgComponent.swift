import UIKit
import dcflight
import SVGKit

/// SVG component that renders SVG images from assets
class DCFSvgComponent: NSObject, DCFComponent {
    // Dictionary to cache loaded SVG images
    private static var imageCache = [String: SVGKImage]()
    
    required override init() {
        super.init()
    }
    
    func createView(props: [String: Any]) -> UIView {
        // Create an image view to display the SVG
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        // Apply props
        updateView(imageView, withProps: props)
        
        return imageView
    }
    
    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let imageView = view as? UIImageView else { return false }
        
        // Get SVG asset path
        if let asset = props["asset"] as? String {
            print("Loading SVG asset: \(asset)")
            loadSvgFromAsset(asset, into: imageView)
        }
        
        // Apply tint color if specified
        if let tintColorString = props["tintColor"] as? String,
           let tintColor = ColorUtilities.color(fromHexString: tintColorString) {
            imageView.tintColor = tintColor
            imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        } else {
            // Reset to original rendering mode if no tint specified
            imageView.image = imageView.image?.withRenderingMode(.automatic)
        }
        
        return true
    }
    
    // MARK: - SVG Loading Methods
    
    private func loadSvgFromAsset(_ asset: String, into imageView: UIImageView) {
        // Check cache first
        if let cachedImage = DCFSvgComponent.imageCache[asset] {
            imageView.image = cachedImage.uiImage
            
            // Trigger onLoad event since we're using the cached image
            triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
            return
        }
        
        // Load SVG using SVGKit
        if let svgImage = loadSVGFromAssetPath(asset) {
            // Cache the image
            DCFSvgComponent.imageCache[asset] = svgImage
            
            // Set the image
            imageView.image = svgImage.uiImage
            
            // Trigger onLoad event
            triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
        } else {
            // If we reach here, the image couldn't be loaded
            print("❌ Failed to load SVG: \(asset)")
            triggerEvent(on: imageView, eventType: "onError", eventData: ["error": "SVG not found: \(asset)"])
        }
    }
    
    // Load SVG from various possible sources using SVGKit
    private func loadSVGFromAssetPath(_ asset: String) -> SVGKImage? {
        // Method 1: Try loading from direct path if it looks like a file path
        if (asset.hasPrefix("/") || asset.contains(".")) && FileManager.default.fileExists(atPath: asset) {
            print("📂 Loading SVG from direct file path: \(asset)")
            return SVGKImage(contentsOfFile: asset)
        }
        
        // Method 2: Try to find in main bundle with extensions
        let extensions = ["svg"]
        for ext in extensions {
            if let path = Bundle.main.path(forResource: asset, ofType: ext) {
                print("📦 Loading SVG from bundle path: \(path)")
                return SVGKImage(contentsOfFile: path)
            }
            
            // Also try with the extension already included
            if let path = Bundle.main.path(forResource: asset, ofType: nil) {
                print("📦 Loading SVG from bundle path (with extension): \(path)")
                return SVGKImage(contentsOfFile: path)
            }
        }
        
        // Method 3: Try loading as a URL if it's a web URL
        if asset.hasPrefix("http://") || asset.hasPrefix("https://") {
            if let url = URL(string: asset) {
                print("🌐 Loading SVG from URL: \(url)")
                return SVGKImage(contentsOf: url)
            }
        }
        
        // Method 4: If it's an SVG string (starting with <?xml or <svg)
        if asset.hasPrefix("<?xml") || asset.hasPrefix("<svg") {
            print("🔤 Loading SVG from XML string")
            return SVGKImage(data: asset.data(using: .utf8)!)
        }
        
        // Method 5: Try DCFIcons directory in the framework bundle
        if let frameworkBundle = Bundle(identifier: "org.cocoapods.dcf-primitives") {
            if let path = frameworkBundle.path(forResource: "Classes/DCFIcons/\(asset)", ofType: "svg") {
                print("🔣 Loading SVG from framework icons: \(path)")
                return SVGKImage(contentsOfFile: path)
            }
            // Also try with the extension already included
            if let path = frameworkBundle.path(forResource: "Classes/DCFIcons/\(asset)", ofType: nil) {
                print("🔣 Loading SVG from framework icons (with extension): \(path)")
                return SVGKImage(contentsOfFile: path)
            }
        }
        
        print("❌ Could not load SVG from any location: \(asset)")
        return nil
    }
}
