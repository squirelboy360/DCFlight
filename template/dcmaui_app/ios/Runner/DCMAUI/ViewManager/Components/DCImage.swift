//
//  DCImage.swift
//  Runner
//
//  Created for DC MAUI Framework
//

import UIKit

/// Image component that matches React Native's Image
class DCImage: DCBaseView {
    // The image view
    let imageView = UIImageView()
    
    // Loading indicator
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // Image properties
    private var source: [String: Any]?
    private var defaultSource: [String: Any]?
    private var resizeMode: String = "cover"
    private var loadingIndicatorEnabled: Bool = true
    private var isLoading: Bool = false
    
    // Image cache
    private static let imageCache = NSCache<NSString, UIImage>()
    
    override func setupView() {
        super.setupView()
        
        // Configure imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // Configure loading indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        
        // Add subviews
        addSubview(imageView)
        addSubview(activityIndicator)
        
        // Set constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    override func updateProps(props: [String: Any]) {
        super.updateProps(props: props)
        
        // Handle image source
        if let source = props["source"] as? [String: Any] {
            self.source = source
            loadImage()
        }
        
        // Handle default source for placeholder
        if let defaultSource = props["defaultSource"] as? [String: Any] {
            self.defaultSource = defaultSource
            loadDefaultImage()
        }
        
        // Handle resize mode
        if let resizeMode = props["resizeMode"] as? String {
            self.resizeMode = resizeMode
            updateResizeMode()
        }
        
        // Handle loading indicator
        if let loadingIndicatorEnabled = props["loadingIndicatorEnabled"] as? Bool {
            self.loadingIndicatorEnabled = loadingIndicatorEnabled
            if isLoading && loadingIndicatorEnabled {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
        }
    }
    
    // Update the content mode based on resize mode
    private func updateResizeMode() {
        switch resizeMode {
        case "cover":
            imageView.contentMode = .scaleAspectFill
        case "contain":
            imageView.contentMode = .scaleAspectFit
        case "stretch":
            imageView.contentMode = .scaleToFill
        case "center":
            imageView.contentMode = .center
        case "repeat":
            imageView.contentMode = .scaleAspectFill
            // True repeat requires additional handling not supported by UIImageView
        default:
            imageView.contentMode = .scaleAspectFill
        }
    }
    
    // Load the main image
    private func loadImage() {
        guard let source = self.source,
              let uri = source["uri"] as? String else {
            return
        }
        
        // Show loading indicator
        if loadingIndicatorEnabled {
            activityIndicator.startAnimating()
        }
        isLoading = true
        
        // Send loading started event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onLoadStart",
            params: ["target": viewId]
        )
        
        // Check cache first
        let cacheKey = NSString(string: uri)
        if let cachedImage = DCImage.imageCache.object(forKey: cacheKey) {
            self.imageView.image = cachedImage
            self.handleImageLoadSuccess(image: cachedImage)
            return
        }
        
        // Handle resource:// protocol for bundled assets
        if uri.starts(with: "resource:") {
            let resourceName = uri.replacingOccurrences(of: "resource:", with: "")
            if let image = UIImage(named: resourceName) {
                self.imageView.image = image
                self.handleImageLoadSuccess(image: image)
                DCImage.imageCache.setObject(image, forKey: cacheKey)
            } else {
                self.handleImageLoadError(error: "Resource not found: \(resourceName)")
            }
            return
        }
        
        // Handle data: URI for base64 encoded images
        if uri.starts(with: "data:") {
            if let dataURI = extractDataFromDataURI(uri) {
                if let image = UIImage(data: dataURI) {
                    self.imageView.image = image
                    self.handleImageLoadSuccess(image: image)
                    DCImage.imageCache.setObject(image, forKey: cacheKey)
                } else {
                    self.handleImageLoadError(error: "Invalid data URI")
                }
            } else {
                self.handleImageLoadError(error: "Invalid data URI format")
            }
            return
        }
        
        // Handle network image
        if let url = URL(string: uri) {
            let headers = source["headers"] as? [String: String]
            loadNetworkImage(url: url, headers: headers, cacheKey: cacheKey)
        } else {
            self.handleImageLoadError(error: "Invalid URL: \(uri)")
        }
    }
    
    // Load network image with optional headers
    private func loadNetworkImage(url: URL, headers: [String: String]?, cacheKey: NSString) {
        var request = URLRequest(url: url)
        
        // Add headers if provided
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.handleImageLoadError(error: error.localizedDescription)
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    self.handleImageLoadError(error: "Invalid image data")
                    return
                }
                
                // Cache the image
                DCImage.imageCache.setObject(image, forKey: cacheKey)
                
                // Update UI
                self.imageView.image = image
                self.handleImageLoadSuccess(image: image)
            }
        }
        
        task.resume()
    }
    
    // Load default image as placeholder
    private func loadDefaultImage() {
        guard let defaultSource = self.defaultSource,
              let uri = defaultSource["uri"] as? String else {
            return
        }
        
        // Handle resource:// protocol for bundled assets
        if uri.starts(with: "resource:") {
            let resourceName = uri.replacingOccurrences(of: "resource:", with: "")
            if let image = UIImage(named: resourceName) {
                // Only set if main image isn't loaded yet
                if self.imageView.image == nil {
                    self.imageView.image = image
                }
            }
            return
        }
        
        // For other types, we'd implement similar logic as loadImage() but simplified
        // and without events or loading indicators
    }
    
    // Handle successful image load
    private func handleImageLoadSuccess(image: UIImage) {
        // Stop loading indicator
        activityIndicator.stopAnimating()
        isLoading = false
        
        // Send success event
        let imageSize = image.size
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onLoad",
            params: [
                "target": viewId,
                "source": [
                    "width": imageSize.width,
                    "height": imageSize.height,
                    "orientation": (imageSize.width > imageSize.height) ? "landscape" : "portrait"
                ]
            ]
        )
        
        // Send load end event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onLoadEnd",
            params: ["target": viewId]
        )
    }
    
    // Handle image load error
    private func handleImageLoadError(error: String) {
        // Stop loading indicator
        activityIndicator.stopAnimating()
        isLoading = false
        
        // Send error event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onError",
            params: [
                "target": viewId,
                "error": error
            ]
        )
        
        // Send load end event
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: "onLoadEnd",
            params: ["target": viewId]
        )
    }
    
    // Extract data from a data URI
    private func extractDataFromDataURI(_ dataURI: String) -> Data? {
        let components = dataURI.components(separatedBy: ",")
        guard components.count > 1 else { return nil }
        
        let data = components[1]
        
        // Check if it's base64 encoded
        if components[0].contains("base64") {
            return Data(base64Encoded: data)
        } else {
            // Handle URL encoded data (less common)
            return data.data(using: .utf8)
        }
    }
}
