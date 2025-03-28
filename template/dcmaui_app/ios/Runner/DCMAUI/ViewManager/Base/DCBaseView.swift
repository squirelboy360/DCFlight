//
//  DCBaseView.swift
//  Runner
//
//  Created for DC MAUI Framework
//

// i guess this is the base view for all the views inb other words the shadow treeor howerver its called
import UIKit

/// Base view component for the DCMAUI framework
class DCBaseView: UIView, ViewUpdatable {
    let viewId: String
    var props: [String: Any]
    private var eventListeners: [String: Bool] = [:]
    
    // DCMAUI flexbox properties
    var flexDirection: String = "column"  // column, row, column-reverse, row-reverse
    var flexWrap: String = "nowrap" // nowrap, wrap, wrap-reverse
    var justifyContent: String = "flex-start" // flex-start, flex-end, center, space-between, space-around
    var alignItems: String = "stretch" // flex-start, flex-end, center, stretch
    var alignSelf: String = "auto" // auto, flex-start, flex-end, center, stretch
    
    // Sizing properties
    var flexGrow: CGFloat = 0
    var flexShrink: CGFloat = 1
    var flexBasis: CGFloat? = nil
    
    // Margin and padding properties
    var margin: UIEdgeInsets = .zero
    var padding: UIEdgeInsets = .zero
    
    // Position properties 
    var position: String = "relative" // relative, absolute
    var top: CGFloat? = nil
    var left: CGFloat? = nil
    var right: CGFloat? = nil
    var bottom: CGFloat? = nil
    
    var viewWidth: CGFloat? {
        if let width = props["style"] as? [String: Any], let widthValue = width["width"] as? CGFloat {
            return widthValue
        }
        return nil
    }

    var viewHeight: CGFloat? {
        if let style = props["style"] as? [String: Any], let heightValue = style["height"] as? CGFloat {
            return heightValue
        }
        return nil
    }
    
    init(viewId: String, props: [String: Any]) {
        self.viewId = viewId
        self.props = props
        super.init(frame: .zero)
        setupView()
        updateProps(props: props)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        // Base setup for view
    }
    
    func updateProps(props: [String: Any]) {
        self.props = props
        
        // Apply style properties 
        if let style = props["style"] as? [String: Any] {
            applyStyleProperties(style)
        }
        
        // Direct props with style fallthrough
        if let opacity = props["opacity"] as? CGFloat {
            alpha = opacity
        }
        
        // Accessibility props
        if let accessibilityLabel = props["accessibilityLabel"] as? String {
            self.accessibilityLabel = accessibilityLabel
        }
        
        if let testID = props["testID"] as? String {
            self.accessibilityIdentifier = testID
        }
        
        // Force layout update
        setNeedsLayout()
    }
    
    // Apply style properties
    func applyStyleProperties(_ style: [String: Any]) {
        // Background color
        if let backgroundColor = style["backgroundColor"] as? String, backgroundColor.hasPrefix("#") {
            self.backgroundColor = UIColor(hexString: backgroundColor)
        }
        
        // Layout properties
        if let position = style["position"] as? String {
            self.position = position
        }
        
        // Size properties - Add percentage support
        if let width = style["width"] {
            if let widthValue = width as? CGFloat {
                frame.size.width = widthValue
            } else if let widthStr = width as? String, widthStr.hasSuffix("%"), let parentWidth = superview?.bounds.width {
                if let percentValue = Double(widthStr.dropLast()) {
                    frame.size.width = CGFloat(percentValue / 100.0) * parentWidth
                }
            }
        }
        
        if let height = style["height"] {
            if let heightValue = height as? CGFloat {
                frame.size.height = heightValue
            } else if let heightStr = height as? String, heightStr.hasSuffix("%"), let parentHeight = superview?.bounds.height {
                if let percentValue = Double(heightStr.dropLast()) {
                    frame.size.height = CGFloat(percentValue / 100.0) * parentHeight
                }
            }
        }
        
        // AspectRatio support
        if let aspectRatio = style["aspectRatio"] as? CGFloat {
            // If width is set but height isn't
            if frame.size.width > 0 && frame.size.height <= 0 {
                frame.size.height = frame.size.width / aspectRatio
            }
            // If height is set but width isn't
            else if frame.size.height > 0 && frame.size.width <= 0 {
                frame.size.width = frame.size.height * aspectRatio
            }
        }
        
        // Flexbox properties
        if let flexDirection = style["flexDirection"] as? String {
            self.flexDirection = flexDirection
        }
        
        if let justifyContent = style["justifyContent"] as? String {
            self.justifyContent = justifyContent
        }
        
        if let alignItems = style["alignItems"] as? String {
            self.alignItems = alignItems
        }
        
        if let flexGrow = style["flexGrow"] as? CGFloat {
            self.flexGrow = flexGrow
        }
        
        if let flexShrink = style["flexShrink"] as? CGFloat {
            self.flexShrink = flexShrink
        }
        
        // FlexBasis support
        if let flexBasis = style["flexBasis"] {
            if let flexBasisValue = flexBasis as? CGFloat {
                self.flexBasis = flexBasisValue
            } else if let flexBasisStr = flexBasis as? String, flexBasisStr.hasSuffix("%"), let parentSize = superview?.bounds.size {
                if let percentValue = Double(flexBasisStr.dropLast()) {
                    // Base on parent's width for row, height for column
                    let parentDimension = (self.flexDirection == "row" || self.flexDirection == "row-reverse") 
                        ? parentSize.width : parentSize.height
                    self.flexBasis = CGFloat(percentValue / 100.0) * parentDimension
                }
            }
        }
        
        // Position properties - Enhanced absolute positioning
        if let top = style["top"] {
            if let topValue = top as? CGFloat {
                self.top = topValue
            } else if let topStr = top as? String, topStr.hasSuffix("%"), let parentHeight = superview?.bounds.height {
                if let percentValue = Double(topStr.dropLast()) {
                    self.top = CGFloat(percentValue / 100.0) * parentHeight
                }
            }
        }
        
        if let left = style["left"] {
            if let leftValue = left as? CGFloat {
                self.left = leftValue
            } else if let leftStr = left as? String, leftStr.hasSuffix("%"), let parentWidth = superview?.bounds.width {
                if let percentValue = Double(leftStr.dropLast()) {
                    self.left = CGFloat(percentValue / 100.0) * parentWidth
                }
            }
        }
        
        if let right = style["right"] {
            if let rightValue = right as? CGFloat {
                self.right = rightValue
            } else if let rightStr = right as? String, rightStr.hasSuffix("%"), let parentWidth = superview?.bounds.width {
                if let percentValue = Double(rightStr.dropLast()) {
                    self.right = CGFloat(percentValue / 100.0) * parentWidth
                }
            }
        }
        
        if let bottom = style["bottom"] {
            if let bottomValue = bottom as? CGFloat {
                self.bottom = bottomValue
            } else if let bottomStr = bottom as? String, bottomStr.hasSuffix("%"), let parentHeight = superview?.bounds.height {
                if let percentValue = Double(bottomStr.dropLast()) {
                    self.bottom = CGFloat(percentValue / 100.0) * parentHeight
                }
            }
        }
        
        // Apply transform if provided
        if let transform = style["transform"] as? [[String: Any]] {
            var transforms = [CATransform3D]()
            
            for transformItem in transform {
                if let translateX = transformItem["translateX"] as? CGFloat {
                    transforms.append(CATransform3DMakeTranslation(translateX, 0, 0))
                } else if let translateY = transformItem["translateY"] as? CGFloat {
                    transforms.append(CATransform3DMakeTranslation(0, translateY, 0))
                } else if let scale = transformItem["scale"] as? CGFloat {
                    transforms.append(CATransform3DMakeScale(scale, scale, 1))
                } else if let rotate = transformItem["rotate"] as? String, rotate.hasSuffix("deg") {
                    let degrees = Double(rotate.dropLast(3)) ?? 0
                    let radians = degrees * .pi / 180
                    transforms.append(CATransform3DMakeRotation(CGFloat(radians), 0, 0, 1))
                }
            }
            
            // Apply transforms
            if !transforms.isEmpty {
                var combinedTransform = CATransform3DIdentity
                for transform in transforms {
                    combinedTransform = CATransform3DConcat(combinedTransform, transform)
                }
                self.layer.transform = combinedTransform
            }
        }
        
        // Border properties
        if let borderRadius = style["borderRadius"] as? CGFloat {
            layer.cornerRadius = borderRadius
            layer.masksToBounds = true
        }
        
        if let borderWidth = style["borderWidth"] as? CGFloat {
            layer.borderWidth = borderWidth
        }
        
        if let borderColor = style["borderColor"] as? String, borderColor.hasPrefix("#") {
            layer.borderColor = UIColor(hexString: borderColor).cgColor
        }
        
        // Process padding
        processPaddingStyle(style)
        
        // Process margin
        processMarginStyle(style)
    }
    
    // Process padding in DCMAUI style
    private func processPaddingStyle(_ style: [String: Any]) {
        var newPadding = UIEdgeInsets.zero
        
        // Handle all-sides padding
        if let paddingAll = style["padding"] as? CGFloat {
            newPadding = UIEdgeInsets(top: paddingAll, left: paddingAll, bottom: paddingAll, right: paddingAll)
        }
        
        // Handle vertical and horizontal padding
        if let paddingVertical = style["paddingVertical"] as? CGFloat {
            newPadding.top = paddingVertical
            newPadding.bottom = paddingVertical
        }
        
        if let paddingHorizontal = style["paddingHorizontal"] as? CGFloat {
            newPadding.left = paddingHorizontal
            newPadding.right = paddingHorizontal
        }
        
        // Handle individual sides (these take precedence)
        if let paddingTop = style["paddingTop"] as? CGFloat {
            newPadding.top = paddingTop
        }
        
        if let paddingLeft = style["paddingLeft"] as? CGFloat {
            newPadding.left = paddingLeft
        }
        
        if let paddingBottom = style["paddingBottom"] as? CGFloat {
            newPadding.bottom = paddingBottom
        }
        
        if let paddingRight = style["paddingRight"] as? CGFloat {
            newPadding.right = paddingRight
        }
        
        self.padding = newPadding
    }
    
    // Process margin in DCMAUI style
    private func processMarginStyle(_ style: [String: Any]) {
        var newMargin = UIEdgeInsets.zero
        
        // Handle all-sides margin
        if let marginAll = style["margin"] as? CGFloat {
            newMargin = UIEdgeInsets(top: marginAll, left: marginAll, bottom: marginAll, right: marginAll)
        }
        
        // Handle vertical and horizontal margin
        if let marginVertical = style["marginVertical"] as? CGFloat {
            newMargin.top = marginVertical
            newMargin.bottom = marginVertical
        }
        
        if let marginHorizontal = style["marginHorizontal"] as? CGFloat {
            newMargin.left = marginHorizontal
            newMargin.right = marginHorizontal
        }
        
        // Handle individual sides (these take precedence)
        if let marginTop = style["marginTop"] as? CGFloat {
            newMargin.top = marginTop
        }
        
        if let marginLeft = style["marginLeft"] as? CGFloat {
            newMargin.left = marginLeft
        }
        
        if let marginBottom = style["marginBottom"] as? CGFloat {
            newMargin.bottom = marginBottom
        }
        
        if let marginRight = style["marginRight"] as? CGFloat {
            newMargin.right = marginRight
        }
        
        self.margin = newMargin
    }
    
    // Event registration for DCMAUI event system
    func addEventListener(_ eventType: String) {
        let standardizedEventName = ensureStandardEventName(eventType)
        eventListeners[standardizedEventName] = true
    }
    // TODO: Remove this method once old unstandardized events are migrated
    // Standard event name converter
    private func ensureStandardEventName(_ name: String) -> String {
        if name.hasPrefix("on") {
            return name
        }
        let firstChar = name.prefix(1).uppercased()
        let rest = name.dropFirst()
        return "on\(firstChar)\(rest)"
    }
    
    // Layout event
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Fire onLayout when layout is done
        if eventListeners["onLayout"] == true {
            let layout: [String: Any] = [
                "x": frame.origin.x,
                "y": frame.origin.y,
                "width": frame.width,
                "height": frame.height
            ]
            
            let event: [String: Any] = [
                "target": viewId,
                "layout": layout
            ]
            
            DCViewCoordinator.shared?.sendEvent(viewId: viewId, eventName: "onLayout", params: event)
        }
        
        // Implement auto layout algorithm using native UIKit constraints
        applyNativeLayoutAlgorithm()
    }

    // Native layout algorithm implementation
    private func applyNativeLayoutAlgorithm() {
        // Remove existing constraints from subviews
        for subview in subviews {
            subview.translatesAutoresizingMaskIntoConstraints = true
        }
        
        // Calculate content area accounting for padding
        let contentRect = bounds.inset(by: padding)
        
        // Layout based on flexDirection
        if flexDirection == "row" || flexDirection == "row-reverse" {
            applyHorizontalLayout(in: contentRect)
        } else {
            // Default to column layout
            applyVerticalLayout(in: contentRect)
        }
        
        // Apply position absolute for children that need it
        applyAbsolutePositioning()
    }

    // Apply horizontal layout (row)
    private func applyHorizontalLayout(in rect: CGRect) {
        let isReverse = flexDirection == "row-reverse"
        let subviews = isReverse ? self.subviews.reversed() : self.subviews
        
        // Calculate total fixed width and count of flex items
        var totalFixedWidth: CGFloat = 0
        var totalFlexGrow: CGFloat = 0
        var flexItems: [UIView] = []
        
        for view in subviews {
            if let dcView = view as? DCBaseView {
                if dcView.position == "absolute" {
                    continue // Absolute positioned views are handled separately
                }
                
                if let width = dcView.viewWidth {
                    totalFixedWidth += width
                } else if dcView.flexGrow > 0 {
                    totalFlexGrow += dcView.flexGrow
                    flexItems.append(view)
                } else {
                    // Get intrinsic width or use auto sizing
                    let intrinsicWidth = view.intrinsicContentSize.width
                    if intrinsicWidth != UIView.noIntrinsicMetric {
                        totalFixedWidth += intrinsicWidth
                    } else {
                        totalFixedWidth += 100 // Default width if nothing specified
                    }
                }
            } else {
                // Non-DCBaseView, use intrinsic size
                let intrinsicWidth = view.intrinsicContentSize.width
                if intrinsicWidth != UIView.noIntrinsicMetric {
                    totalFixedWidth += intrinsicWidth
                } else {
                    totalFixedWidth += 100 // Default width
                }
            }
        }
        
        // Calculate spacing based on justifyContent
        let availableWidth = rect.width
        let remainingWidth = max(0, availableWidth - totalFixedWidth)
        let flexBasis = totalFlexGrow > 0 ? remainingWidth / totalFlexGrow : 0
        
        var spacing: CGFloat = 0
        var initialOffset: CGFloat = 0
        
        if totalFixedWidth < availableWidth {
            switch justifyContent {
            case "flex-start":
                spacing = 0
                initialOffset = 0
            case "flex-end":
                spacing = 0
                initialOffset = availableWidth - totalFixedWidth
            case "center":
                spacing = 0
                initialOffset = (availableWidth - totalFixedWidth) / 2
            case "space-between":
                spacing = subviews.count > 1 ? (availableWidth - totalFixedWidth) / CGFloat(subviews.count - 1) : 0
                initialOffset = 0
            case "space-around":
                spacing = subviews.count > 0 ? (availableWidth - totalFixedWidth) / CGFloat(subviews.count) : 0
                initialOffset = spacing / 2
            case "space-evenly":
                let totalItems = CGFloat(subviews.count) + 1
                spacing = (availableWidth - totalFixedWidth) / totalItems
                initialOffset = spacing
            default:
                spacing = 0
                initialOffset = 0
            }
        }
        
        // Apply layout to each subview
        var xPosition = isReverse ? rect.maxX - initialOffset : rect.minX + initialOffset
        
        for view in subviews {
            if let dcView = view as? DCBaseView, dcView.position == "absolute" {
                continue // Skip absolute positioned views
            }
            
            // Get view dimensions
            var viewWidth: CGFloat
            var viewHeight: CGFloat
            
            if let dcView = view as? DCBaseView, let width = dcView.viewWidth {
                viewWidth = width
            } else if let dcView = view as? DCBaseView, dcView.flexGrow > 0 {
                viewWidth = flexBasis * dcView.flexGrow
            } else if view.intrinsicContentSize.width != UIView.noIntrinsicMetric {
                viewWidth = view.intrinsicContentSize.width
            } else {
                viewWidth = 100 // Default width
            }
            
            // Determine height based on alignItems
            if let dcView = view as? DCBaseView, let height = dcView.viewHeight {
                viewHeight = height
            } else {
                switch alignItems {
                case "stretch":
                    viewHeight = rect.height
                case "flex-start":
                    viewHeight = view.intrinsicContentSize.height != UIView.noIntrinsicMetric ?
                        view.intrinsicContentSize.height : rect.height
                case "flex-end":
                    viewHeight = view.intrinsicContentSize.height != UIView.noIntrinsicMetric ?
                        view.intrinsicContentSize.height : rect.height
                case "center":
                    viewHeight = view.intrinsicContentSize.height != UIView.noIntrinsicMetric ?
                        view.intrinsicContentSize.height : rect.height
                default:
                    viewHeight = rect.height
                }
            }
            
            // Calculate Y position based on alignItems
            var yPosition: CGFloat
            
            switch alignItems {
            case "flex-start":
                yPosition = rect.minY
            case "flex-end":
                yPosition = rect.maxY - viewHeight
            case "center":
                yPosition = rect.minY + (rect.height - viewHeight) / 2
            default: // stretch
                yPosition = rect.minY
            }
            
            // Set frame based on layout direction
            if isReverse {
                view.frame = CGRect(x: xPosition - viewWidth, y: yPosition, width: viewWidth, height: viewHeight)
                xPosition -= (viewWidth + spacing)
            } else {
                view.frame = CGRect(x: xPosition, y: yPosition, width: viewWidth, height: viewHeight)
                xPosition += (viewWidth + spacing)
            }
        }
    }

    // Apply vertical layout (column)
    private func applyVerticalLayout(in rect: CGRect) {
        let isReverse = flexDirection == "column-reverse"
        let subviews = isReverse ? self.subviews.reversed() : self.subviews
        
        // Calculate total fixed height and count of flex items
        var totalFixedHeight: CGFloat = 0
        var totalFlexGrow: CGFloat = 0
        var flexItems: [UIView] = []
        
        for view in subviews {
            if let dcView = view as? DCBaseView {
                if dcView.position == "absolute" {
                    continue // Absolute positioned views are handled separately
                }
                
                if let height = dcView.viewHeight {
                    totalFixedHeight += height
                } else if dcView.flexGrow > 0 {
                    totalFlexGrow += dcView.flexGrow
                    flexItems.append(view)
                } else {
                    // Get intrinsic height or use auto sizing
                    let intrinsicHeight = view.intrinsicContentSize.height
                    if intrinsicHeight != UIView.noIntrinsicMetric {
                        totalFixedHeight += intrinsicHeight
                    } else {
                        totalFixedHeight += 44 // Default height if nothing specified
                    }
                }
            } else {
                // Non-DCBaseView, use intrinsic size
                let intrinsicHeight = view.intrinsicContentSize.height
                if intrinsicHeight != UIView.noIntrinsicMetric {
                    totalFixedHeight += intrinsicHeight
                } else {
                    totalFixedHeight += 44 // Default height
                }
            }
        }
        
        // Calculate spacing based on justifyContent
        let availableHeight = rect.height
        let remainingHeight = max(0, availableHeight - totalFixedHeight)
        let flexBasis = totalFlexGrow > 0 ? remainingHeight / totalFlexGrow : 0
        
        var spacing: CGFloat = 0
        var initialOffset: CGFloat = 0
        
        if totalFixedHeight < availableHeight {
            switch justifyContent {
            case "flex-start":
                spacing = 0
                initialOffset = 0
            case "flex-end":
                spacing = 0
                initialOffset = availableHeight - totalFixedHeight
            case "center":
                spacing = 0
                initialOffset = (availableHeight - totalFixedHeight) / 2
            case "space-between":
                spacing = subviews.count > 1 ? (availableHeight - totalFixedHeight) / CGFloat(subviews.count - 1) : 0
                initialOffset = 0
            case "space-around":
                spacing = subviews.count > 0 ? (availableHeight - totalFixedHeight) / CGFloat(subviews.count) : 0
                initialOffset = spacing / 2
            case "space-evenly":
                let totalItems = CGFloat(subviews.count) + 1
                spacing = (availableHeight - totalFixedHeight) / totalItems
                initialOffset = spacing
            default:
                spacing = 0
                initialOffset = 0
            }
        }
        
        // Apply layout to each subview
        var yPosition = isReverse ? rect.maxY - initialOffset : rect.minY + initialOffset
        
        for view in subviews {
            if let dcView = view as? DCBaseView, dcView.position == "absolute" {
                continue // Skip absolute positioned views
            }
            
            // Get view dimensions
            var viewWidth: CGFloat
            var viewHeight: CGFloat
            
            // Determine height
            if let dcView = view as? DCBaseView, let height = dcView.viewHeight {
                viewHeight = height
            } else if let dcView = view as? DCBaseView, dcView.flexGrow > 0 {
                viewHeight = flexBasis * dcView.flexGrow
            } else if view.intrinsicContentSize.height != UIView.noIntrinsicMetric {
                viewHeight = view.intrinsicContentSize.height
            } else {
                viewHeight = 44 // Default height
            }
            
            // Determine width based on alignItems
            if let dcView = view as? DCBaseView, let width = dcView.viewWidth {
                viewWidth = width
            } else {
                switch alignItems {
                case "stretch":
                    viewWidth = rect.width
                case "flex-start", "flex-end", "center":
                    viewWidth = view.intrinsicContentSize.width != UIView.noIntrinsicMetric ?
                        view.intrinsicContentSize.width : rect.width
                default:
                    viewWidth = rect.width
                }
            }
            
            // Calculate X position based on alignItems
            var xPosition: CGFloat
            
            switch alignItems {
            case "flex-start":
                xPosition = rect.minX
            case "flex-end":
                xPosition = rect.maxX - viewWidth
            case "center":
                xPosition = rect.minX + (rect.width - viewWidth) / 2
            default: // stretch
                xPosition = rect.minX
            }
            
            // Set frame based on layout direction
            if isReverse {
                view.frame = CGRect(x: xPosition, y: yPosition - viewHeight, width: viewWidth, height: viewHeight)
                yPosition -= (viewHeight + spacing)
            } else {
                view.frame = CGRect(x: xPosition, y: yPosition, width: viewWidth, height: viewHeight)
                yPosition += (viewHeight + spacing)
            }
        }
    }

    // Apply absolute positioning for children with position: absolute
    private func applyAbsolutePositioning() {
        for view in subviews {
            guard let dcView = view as? DCBaseView, dcView.position == "absolute" else {
                continue
            }
            
            var frame = view.frame
            let parentBounds = bounds
            
            // Store original size
            let originalSize = frame.size
            
            // Apply top, right, bottom, left properties - enhanced to handle special cases
            if let top = dcView.top {
                frame.origin.y = top
            }
            
            if let left = dcView.left {
                frame.origin.x = left
            }
            
            if let right = dcView.right {
                if dcView.left == nil { // Only apply if left isn't set
                    frame.origin.x = parentBounds.width - right - frame.width
                } else {
                    // If both left and right are set, adjust width (like React Native)
                    if let left = dcView.left {
                        frame.size.width = parentBounds.width - left - right
                    }
                }
            }
            
            if let bottom = dcView.bottom {
                if dcView.top == nil { // Only apply if top isn't set
                    frame.origin.y = parentBounds.height - bottom - frame.height
                } else {
                    // If both top and bottom are set, adjust height (like React Native)
                    if let top = dcView.top {
                        frame.size.height = parentBounds.height - top - bottom
                    }
                }
            }
            
            // If we have an aspectRatio, apply it with precedence over previously set dimensions
            if let dcView = view as? DCBaseView, let aspectRatio = dcView.props["style"] as? [String: Any],
               let ratio = aspectRatio["aspectRatio"] as? CGFloat, ratio > 0 {
                
                // If width changed but height didn't
                if frame.size.width != originalSize.width && frame.size.height == originalSize.height {
                    frame.size.height = frame.size.width / ratio
                }
                // If height changed but width didn't
                else if frame.size.height != originalSize.height && frame.size.width == originalSize.width {
                    frame.size.width = frame.size.height * ratio
                }
            }
            
            // Set frame with absolute positioning
            view.frame = frame
        }
    }

    // Add this utility method to DCBaseView, making it available to all components
    func getPadding() -> UIEdgeInsets {
        let padding = UIEdgeInsets(
            top: padding.top,
            left: padding.left,
            bottom: padding.bottom,
            right: padding.right
        )
        
        return padding
    }
    
    // Helper to convert hex color strings to UIColor
    func colorFromHexString(_ hexString: String?) -> UIColor? {
        guard let hexString = hexString, hexString.hasPrefix("#") else {
            return nil
        }
        
        return UIColor(hexString: hexString)
    }
    
    // Helper method to send standard events
    func sendEvent(_ eventName: String, params: [String: Any] = [:]) {
        var eventParams = params
        if !eventParams.keys.contains("target") {
            eventParams["target"] = viewId
        }
        
        if !eventParams.keys.contains("timestamp") {
            eventParams["timestamp"] = Date().timeIntervalSince1970 * 1000
        }
        
        DCViewCoordinator.shared?.sendEvent(
            viewId: viewId,
            eventName: eventName,
            params: eventParams
        )
    }

    // Add this method to DCBaseView class
    func setViewIdIfNeeded(_ viewId: String) {
        // This is a no-op because viewId is already set in the initializer
        // and cannot be changed, but we keep this method for compatibility
        print("DC MAUI: Note - setViewIdIfNeeded called on view that already has ID: \(self.viewId)")
    }
}

// Extension for UIColor to support hex string conversion
extension UIColor {
    convenience init(hexString: String) {
        // CRITICAL FIX: More robust hex parsing
        print("DC MAUI: Converting hex color: \(hexString)")
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        // Extract components based on hex length
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1.0
        
        switch hexSanitized.count {
        case 3: // RGB shorthand (e.g. "#F90")
            r = CGFloat((rgb & 0xF00) >> 8) / 15.0
            g = CGFloat((rgb & 0x0F0) >> 4) / 15.0
            b = CGFloat(rgb & 0x00F) / 15.0
        case 6: // RGB (e.g. "#FF9900")
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
        case 8: // ARGB (e.g. "#FFFF9900")
            a = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            r = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x000000FF) / 255.0
        default:
            print("DC MAUI: CRITICAL - Invalid hex color format: \(hexSanitized)")
            // Default to a visible color on error so it's obvious something's wrong
            r = 1.0
            g = 0.0
            b = 1.0 // Magenta for error
        }
        
        print("DC MAUI: RGBA: (\(r), \(g), \(b), \(a))")
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
