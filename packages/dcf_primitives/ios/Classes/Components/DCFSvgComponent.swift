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
        
        // Apply background color from StyleSheet
        if let backgroundColor = props["backgroundColor"] as? String {
            imageView.backgroundColor = ColorUtilities.color(fromHexString: backgroundColor)
        }
        
        // Get SVG asset path
        if let asset = props["asset"] as? String {
            let key = sharedFlutterViewController?.lookupKey(forAsset: asset)
            let mainBundle = Bundle.main
            let path = mainBundle.path(forResource: key, ofType: nil)
            
            loadSvgFromAsset(
                asset, 
                into: imageView, 
                isRel: (props["isRelativePath"] as? Bool ?? false),
                path: path ?? "no path"
            )
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
        
        // Apply border radius if specified - SVGs should support this too
        if let borderRadius = props["borderRadius"] as? CGFloat {
            imageView.layer.cornerRadius = borderRadius
            imageView.clipsToBounds = true
        }
        
        // Apply opacity if specified
        if let opacity = props["opacity"] as? CGFloat {
            imageView.alpha = opacity
        }
        
        return true
    }
    
    // MARK: - SVG Loading Methods
    
    private func loadSvgFromAsset(_ asset: String, into imageView: UIImageView, isRel: Bool, path:String) {
        // Check cache first
        if let cachedImage = DCFSvgComponent.imageCache[asset] {
            imageView.image = cachedImage.uiImage
            
            // Trigger onLoad event since we're using the cached image
            triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
            return
        }
        
        // Load SVG using SVGKit
        if let svgImage = loadSVGFromAssetPath(asset,isRelativePath: isRel,path: path) {
            // Cache the image
            DCFSvgComponent.imageCache[asset] = svgImage
            
            // Set the image
            imageView.image = svgImage.uiImage
            
            // Trigger onLoad event
            triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
        } else {
            // If we reach here, the image couldn't be loaded
            triggerEvent(on: imageView, eventType: "onError", eventData: ["error": "SVG not found: \(asset)"])
        }
    }
    
    // Load SVG from various possible sources using SVGKit
    private func loadSVGFromAssetPath(_ asset: String, isRelativePath: Bool, path:String) -> SVGKImage? {
        // Method 1: Try loading from direct path if it looks like a file path
        if (asset.hasPrefix("/") || asset.contains(".")) && FileManager.default.fileExists(atPath: asset) && isRelativePath == false {
            return SVGKImage(contentsOfFile: asset)
        } else if asset.hasPrefix("http://") || asset.hasPrefix("https://") {
            if let url = URL(string: asset) {
                return SVGKImage(contentsOf: url)
            }
        } else if (isRelativePath == true) {
            return SVGKImage(contentsOfFile: path)
        }
        return nil
    }
}
