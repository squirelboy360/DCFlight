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
            loadSvgFromAsset(asset, into: imageView, isRel: (props["isRelativePath"] as? Bool ?? false))
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
    
    private func loadSvgFromAsset(_ asset: String, into imageView: UIImageView, isRel: Bool) {
        // Check cache first
        if let cachedImage = DCFSvgComponent.imageCache[asset] {
            imageView.image = cachedImage.uiImage
            
            // Trigger onLoad event since we're using the cached image
            triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
            return
        }
        
        // Load SVG using SVGKit
        if let svgImage = loadSVGFromAssetPath(asset,isRelativePath: isRel) {
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
    private func loadSVGFromAssetPath(_ asset: String, isRelativePath: Bool) -> SVGKImage? {
      
        // Method 1: Try loading from direct path if it looks like a file path
        if (asset.hasPrefix("/") || asset.contains(".")) && FileManager.default.fileExists(atPath: asset) && isRelativePath == false{
            print("📂 Loading SVG from direct file path: \(asset)")
            return SVGKImage(contentsOfFile: asset)
        } else if asset.hasPrefix("http://") || asset.hasPrefix("https://") {
            if let url = URL(string: asset) {
                print("🌐 Loading SVG from URL: \(url)")
                return SVGKImage(contentsOf: url)
            }
        }else if (isRelativePath == true){
            print("executing due to svg hardcoded")
      
            guard let key = sharedFlutterViewController?.lookupKey(forAsset: asset)else{
                print("some serious something is happening \(asset)")
                return SVGKImage(contentsOfFile: "assets/dcf/broken_img.svg")
            }
            
            let mainBundle = Bundle.main
            let path = mainBundle.path(forResource: key, ofType: nil)
              
    print("this is key \(key) and path is \(String(describing: path))")
          
                return SVGKImage(contentsOfFile: path)
        }
        print("❌ Could not load SVG from any location: \(asset)")
        return nil
    }
}
