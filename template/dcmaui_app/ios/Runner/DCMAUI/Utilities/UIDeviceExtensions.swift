import UIKit

extension UIDevice {
    var hasNotch: Bool {
        // Check for iPhone X and newer models
        if #available(iOS 11.0, *) {
            if UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0 > 20 {
                return true
            }
        }
        
        // Check based on model identifier for older iOS versions
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String(validatingUTF8: ptr)
            }
        }
        
        // iPhone X and newer have notches
        let notchModels = ["iPhone10,3", "iPhone10,6", "iPhone11,2", "iPhone11,4", 
                          "iPhone11,6", "iPhone11,8", "iPhone12,1", "iPhone12,3", 
                          "iPhone12,5", "iPhone13,1", "iPhone13,2", "iPhone13,3", 
                          "iPhone13,4", "iPhone14,2", "iPhone14,3", "iPhone14,4", 
                          "iPhone14,5"]
        
        return notchModels.contains(modelCode ?? "")
    }
    
    var hasHomeIndicator: Bool {
        // Home indicator exists on the same devices that have a notch
        return hasNotch
    }
}
