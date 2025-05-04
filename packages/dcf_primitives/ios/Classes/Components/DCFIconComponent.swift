import Flutter
import UIKit
import dcflight

class DCFIconComponent: NSObject, DCFComponent {
    private let svgComponent = DCFSvgComponent()

    required override init() {
        super.init()
    }

    func createView(props: [String: Any]) -> UIView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        updateView(imageView, withProps: props)
        return imageView
    }

    func updateView(_ view: UIView, withProps props: [String: Any]) -> Bool {
        guard let imageView = view as? UIImageView else { return false }

        if let iconName = props["name"] as? String {
            // Look up the correct asset key from Flutter's asset system
            let key = sharedFlutterViewController?.lookupKey(forAsset: "assets/icons/\(iconName)")
            let path = Bundle.main.path(forResource: key, ofType: nil)

            // Use the path for the asset
            var svgProps = props
            svgProps["asset"] = path
            return svgComponent.updateView(imageView, withProps: svgProps)
        }
        return false
    }
}
