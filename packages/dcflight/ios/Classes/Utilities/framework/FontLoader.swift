import UIKit
import CoreText

class FontLoader {
    static let shared = FontLoader()
    
    // Cache of loaded font names to avoid repeated lookups
    private var loadedFonts = Set<String>()
    
    private init() {
        // Pre-register all fonts in the bundle on initialization
        registerAllFonts()
    }
    
    /// Register all custom fonts found in the bundle
    func registerAllFonts() {
        // Log all available fonts for debugging
        printAvailableFonts()
        
        // Check standard Flutter font locations
        let fontDirectories = [
            "fonts",
            "assets/fonts",
            "flutter_assets/fonts",
            "flutter_assets/assets/fonts"
        ]
        
        for directory in fontDirectories {
            registerFontsInDirectory(directory)
        }
    }
    
    /// Register all fonts in a specific directory
    private func registerFontsInDirectory(_ directory: String) {
        guard let directoryURL = Bundle.main.url(forResource: directory, withExtension: nil) else {
            // Directory doesn't exist, that's fine
            return
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: directoryURL,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles
            )
            
            // Filter for font files
            let fontURLs = fileURLs.filter { url in
                let ext = url.pathExtension.lowercased()
                return ext == "ttf" || ext == "otf"
            }
            
            // Register each font
            for fontURL in fontURLs {
                CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
                print("Registered font: \(fontURL.lastPathComponent)")
            }
        } catch {
            print("Error accessing directory \(directory): \(error.localizedDescription)")
        }
    }
    
    /// Load a specific font by name
    func loadFont(name: String, size: CGFloat) -> UIFont? {
        // Try to get the font directly if already registered
        if let font = UIFont(name: name, size: size) {
            return font
        }
        
        // If not yet loaded, try different extensions
        let extensions = ["ttf", "otf"]
        
        for ext in extensions {
            // Try the font name directly
            if let fontURL = Bundle.main.url(forResource: name, withExtension: ext) {
                if registerFont(at: fontURL) {
                    loadedFonts.insert(name)
                    
                    // Try to get the font after registration
                    if let font = UIFont(name: name, size: size) {
                        return font
                    }
                }
            }
            
            // Try common font file naming conventions
            let possibleFilenames = [
                name,
                name.replacingOccurrences(of: " ", with: ""),
                name.replacingOccurrences(of: " ", with: "-"),
                name.replacingOccurrences(of: " ", with: "_"),
                name.lowercased(),
                name.lowercased().replacingOccurrences(of: " ", with: ""),
                name.lowercased().replacingOccurrences(of: " ", with: "-"),
                name.lowercased().replacingOccurrences(of: " ", with: "_")
            ]
            
            for filename in possibleFilenames {
                // Search in standard Flutter font directories
                let fontDirectories = ["", "fonts/", "assets/fonts/", "flutter_assets/fonts/"]
                
                for directory in fontDirectories {
                    let path = directory + filename
                    if let fontURL = Bundle.main.url(forResource: path, withExtension: ext) {
                        if registerFont(at: fontURL) {
                            // Try to get the postscript name or full name
                            if let fontName = getFontName(from: fontURL) {
                                loadedFonts.insert(fontName)
                                if let font = UIFont(name: fontName, size: size) {
                                    return font
                                }
                            }
                            
                            // Try specific variants
                            let commonVariants = [
                                name, 
                                name + "-Regular",
                                name + "Regular",
                                name + "-Medium",
                                name + "Medium",
                                name + "-Bold",
                                name + "Bold"
                            ]
                            
                            for variant in commonVariants {
                                if let font = UIFont(name: variant, size: size) {
                                    return font
                                }
                            }
                        }
                    }
                }
            }
        }
        
        print("Failed to load font: \(name)")
        return nil
    }
    
    /// Register a font file with Core Text
    private func registerFont(at url: URL) -> Bool {
        var error: Unmanaged<CFError>?
        let success = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
        
        if !success {
            if let unwrappedError = error?.takeRetainedValue() {
                let errorDescription = CFErrorCopyDescription(unwrappedError)
                print("Failed to register font at \(url): \(errorDescription ?? "unknown error" as CFString)")
            }
        }
        
        return success
    }
    
    /// Get the actual font name from a font file
    private func getFontName(from url: URL) -> String? {
        guard let dataProvider = CGDataProvider(url: url as CFURL),
              let cgFont = CGFont(dataProvider),
              let postScriptName = cgFont.postScriptName else {
            return nil
        }
        
        return postScriptName as String
    }
    
    /// Print all available fonts for debugging
    private func printAvailableFonts() {
        let fontFamilies = UIFont.familyNames.sorted()
        
        print("=== Available Font Families ===")
        for family in fontFamilies {
            print("Family: \(family)")
            let names = UIFont.fontNames(forFamilyName: family).sorted()
            for name in names {
                print("    Font: \(name)")
            }
        }
        print("==============================")
    }
}
