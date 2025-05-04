import UIKit
import dcflight // To access sharedFlutterViewController

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
        guard let iconName = props["name"] as? String else { return false }

        if let key = sharedFlutterViewController?.lookupKey(forAsset: "assets/icons/\(iconName)", fromPackage: "dcf_primitives"),

           let path = Bundle.main.path(forResource: key, ofType: nil) {
            
            var svgProps = props
            svgProps["asset"] = path
            
            return svgComponent.updateView(imageView, withProps: svgProps)
        }

        return false
    }
}
