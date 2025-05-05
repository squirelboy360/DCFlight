import UIKit
import dcflight

/// SVG component that renders SVG images from assets
class DCFSvgComponent: NSObject, DCFComponent {
    // Dictionary to cache loaded SVG images
    private static var imageCache = [String: UIImage]()
    
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
            print("final final asset \(asset)")
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
            imageView.image = cachedImage
            
            // Trigger onLoad event since we're using the cached image
            triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
            return
        }
        
        // First try to load from app bundle
        if let image = loadImageFromBundle(named: asset) {
            // Cache the image
            DCFSvgComponent.imageCache[asset] = image
            
            // Set the image
            imageView.image = image
            
            // Trigger onLoad event
            triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
            return
        }
        
        // Next, try to load from the DCFIcons directory in Classes folder
        if let image = loadImageFromDCFIcons(named: asset) {
            // Cache the image
            DCFSvgComponent.imageCache[asset] = image
            
            // Set the image
            imageView.image = image
            
            // Trigger onLoad event
            triggerEvent(on: imageView, eventType: "onLoad", eventData: [:])
            return
        }
        
        // If we reach here, the image couldn't be loaded
        print("❌ Failed to load SVG: \(asset)")
        triggerEvent(on: imageView, eventType: "onError", eventData: ["error": "SVG not found: \(asset)"])
    }
    
    // Load image from main bundle
    private func loadImageFromBundle(named name: String) -> UIImage? {
        // Try different file extensions
        let extensions = ["svg", "pdf", "png", "jpg"]
        
        for ext in extensions {
            if let path = Bundle.main.path(forResource: name, ofType: ext) {
                if ext == "svg" || ext == "pdf" {
                    // For SVG and PDF, render as vector
                    if #available(iOS 13.0, *) {
                        return UIImage(named: name)
                    }
                } else {
                    // For raster images
                    return UIImage(contentsOfFile: path)
                }
            }
        }
        
        // Try loading directly by name (in case the extension is included in the name)
        return UIImage(named: name)
    }
    
    // Load image from DCFIcons directory in the Classes folder
    private func loadImageFromDCFIcons(named name: String) -> UIImage? {
        // Get the framework bundle
        guard let frameworkBundle = Bundle(identifier: "org.cocoapods.dcf-primitives") else {
            return nil
        }
        
        // Try different file extensions
        let extensions = ["svg", "pdf", "png", "jpg"]
        
        for ext in extensions {
            // Updated path to look in Classes/DCFIcons directory
            if let path = frameworkBundle.path(forResource: "Classes/DCFIcons/\(name)", ofType: ext) {
                if ext == "svg" || ext == "pdf" {
                    // For SVG and PDF, render as vector
                    if #available(iOS 13.0, *) {
                        return UIImage(named: "Classes/DCFIcons/\(name)", in: frameworkBundle, compatibleWith: nil)
                    }
                } else {
                    // For raster images
                    return UIImage(contentsOfFile: path)
                }
            }
            
            // Also try with the extension already included
            if let path = frameworkBundle.path(forResource: "Classes/DCFIcons/\(name).\(ext)", ofType: nil) {
                return UIImage(contentsOfFile: path)
            }
        }
        
        return nil
    }
}
