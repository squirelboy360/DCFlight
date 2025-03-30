import UIKit
import yoga

/// Manages Yoga layout for DCMAUI components
class DCMauiLayoutManager {
    // Singleton instance
    static let shared = DCMauiLayoutManager()
    
    // Direct dictionary mapping to avoid NSMapTable issues
    private var viewToNode = [ObjectIdentifier: YGNodeRef]()
    
    private init() {}
    
    // Helper to check if a view is a UIKit internal view that shouldn't be managed by Yoga
    private func isInternalUIKitView(_ view: UIView) -> Bool {
        // Check for internal UIKit classes we shouldn't touch
        let className = NSStringFromClass(type(of: view))
        return className.contains("UIButtonLabel") || 
               className.contains("_UIButtonBarStackView") || 
               className.contains("_UIButtonBarButton") ||
               className.hasPrefix("_UI") ||
               view is UIImageView && view.superview is UIButton
    }
    
    // Get the Yoga node for a view, creating it if it doesn't exist and if it's a view we should manage
    func yogaNode(for view: UIView) -> YGNodeRef? {
        // Skip internal UIKit views
        if isInternalUIKitView(view) {
            print("Skipping yoga node for internal UIKit view: \(view)")
            return nil
        }
        
        let viewId = ObjectIdentifier(view)
        
        // Check if we already have a node for this view
        if let node = viewToNode[viewId] {
            print("Found existing yoga node for view: \(view)")
            return node
        }
        
        // Node doesn't exist, create one
        print("No yoga node found for view: \(view), creating new one")
        return createYogaNode(for: view)
    }
    
    // Create a new Yoga node for a view
    func createYogaNode(for view: UIView) -> YGNodeRef {
        // Create new Yoga node
        guard let node = YGNodeNew() else {
            fatalError("Failed to create Yoga node")
        }
        
        print("Created new Yoga node for view: \(view)")
        
        // Store in dictionary using object identifier
        viewToNode[ObjectIdentifier(view)] = node
        
        // Set default properties
        YGNodeStyleSetFlexDirection(node, .column)
        YGNodeStyleSetJustifyContent(node, .flexStart)
        YGNodeStyleSetAlignItems(node, .stretch)
        
        return node
    }
    
    // Connect a child yoga node to its parent
    func connectNodes(parent: UIView, child: UIView, atIndex index: Int) {
        guard let parentNode = yogaNode(for: parent) else {
            print("ERROR: No parent yoga node found for \(parent)")
            return
        }
        
        guard let childNode = yogaNode(for: child) else {
            print("ERROR: No child yoga node found for \(child)")
            return
        }
        
        print("Connecting Yoga nodes: parent: \(parent) to child: \(child) at index \(index)")
        
        // Insert child node at the specified index
        YGNodeInsertChild(parentNode, childNode, index)
        
        // Calculate layout after connecting nodes if dimensions are valid
        if parent.bounds.width > 0 && parent.bounds.height > 0 {
            calculateAndApplyLayout(for: parent, width: parent.bounds.width, height: parent.bounds.height)
        }
    }
    
    // Apply layout properties to a view
    func applyLayout(to view: UIView, withProps props: [String: Any]) {
        // Get or create yoga node
        let node = yogaNode(for: view) ?? createYogaNode(for: view)
        
        // Special additional handling for text views to guarantee visibility
        if let label = view as? UILabel {
            // For text views, ensure they have a valid min size regardless of content
            YGNodeStyleSetMinWidth(node, 10)  // At least 10pt wide
            YGNodeStyleSetMinHeight(node, 10) // At least 10pt tall
            
            // If we have text content, ensure layout accommodates it
            if let text = label.text, !text.isEmpty {
                // Calculate text size
                let textSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, 
                                                        height: CGFloat.greatestFiniteMagnitude))
                
                print("📏 Layout manager: text size for \(text): \(textSize.width) x \(textSize.height)")
                
                // Set minimum dimensions based on text content
                if textSize.width > 0 {
                    YGNodeStyleSetMinWidth(node, Float(textSize.width))
                }
                
                if textSize.height > 0 {
                    YGNodeStyleSetMinHeight(node, Float(textSize.height))
                }
            }
        }
        
        // Apply flex properties from props
        applyFlexboxProps(props, to: node)
    }
    
    // Calculate and apply layout for a subtree
    func calculateAndApplyLayout(for rootView: UIView, width: CGFloat, height: CGFloat) {
        guard let rootNode = yogaNode(for: rootView) else {
            print("ERROR: No yoga node found for root view: \(rootView) during layout calculation")
            return
        }
        
        // Only calculate if we have valid dimensions
        if width > 0 && height > 0 {
            print("Calculating layout for \(rootView) with width: \(width), height: \(height)")
            
            // Calculate layout with LTR direction
            YGNodeCalculateLayout(rootNode, Float(width), Float(height), YGDirection.LTR)
            
            // Apply layout recursively
            applyLayoutRecursive(rootView, rootNode)
        } else {
            print("Skipping layout for \(rootView) - invalid dimensions: \(width) x \(height)")
        }
    }
    
    // Apply calculated layout to views recursively
    private func applyLayoutRecursive(_ view: UIView, _ node: YGNodeRef) {
        // Calculate the new frame
        let left = CGFloat(YGNodeLayoutGetLeft(node))
        let top = CGFloat(YGNodeLayoutGetTop(node))
        let width = CGFloat(YGNodeLayoutGetWidth(node))
        let height = CGFloat(YGNodeLayoutGetHeight(node))
        
        // Validate values before applying - prevent NaN errors
        guard !left.isNaN && !top.isNaN && !width.isNaN && !height.isNaN else {
            print("WARNING: Invalid layout values detected: \(left), \(top), \(width), \(height)")
            return
        }
        
        // Apply frame
        view.frame = CGRect(x: left, y: top, width: width, height: height)
        
        // Apply to children, but skip UIKit internal views
        for i in 0..<view.subviews.count {
            let childView = view.subviews[i]
            
            // Skip internal UIKit views that shouldn't have Yoga nodes
            if isInternalUIKitView(childView) {
                continue
            }
            
            if let childNode = yogaNode(for: childView) {
                applyLayoutRecursive(childView, childNode)
            }
        }
    }
    
    // Recursively setup yoga nodes for a view and its children
    func setupYogaTree(for view: UIView, withProps props: [String: Any]) {
        // Create or get node for this view
        let node = yogaNode(for: view) ?? createYogaNode(for: view)
        
        // Apply props to this node
        applyFlexboxProps(props, to: node)
        
        // Remove all existing child nodes
        for i in 0..<YGNodeGetChildCount(node) {
            YGNodeRemoveAllChildren(node)
        }
        
        // Add children
        for (i, subview) in view.subviews.enumerated() {
            // Create child node if needed
            let childNode = yogaNode(for: subview) ?? createYogaNode(for: subview)
            
            // Add child to parent
            YGNodeInsertChild(node, childNode, i)
        }
    }
    
    // Clean up Yoga node when a view is deallocated
    func cleanUpYogaNode(for view: UIView) {
        let viewId = ObjectIdentifier(view)
        if let node = viewToNode[viewId] {
            // Free the Yoga node
            YGNodeFree(node)
            
            // Remove from dictionary
            viewToNode.removeValue(forKey: viewId)
        }
    }
    
    // Apply the layout properties from a dictionary to a Yoga node
    func applyFlexboxProps(_ props: [String: Any], to node: YGNodeRef) {
        // Flex direction
        if let flexDirection = props["flexDirection"] as? String {
            switch flexDirection {
            case "row":
                YGNodeStyleSetFlexDirection(node, .row)
            case "rowReverse":
                YGNodeStyleSetFlexDirection(node, .rowReverse)
            case "column":
                YGNodeStyleSetFlexDirection(node, .column)
            case "columnReverse":
                YGNodeStyleSetFlexDirection(node, .columnReverse)
            default:
                break
            }
        }
        
        // Justify content
        if let justifyContent = props["justifyContent"] as? String {
            switch justifyContent {
            case "flexStart":
                YGNodeStyleSetJustifyContent(node, .flexStart)
            case "center":
                YGNodeStyleSetJustifyContent(node, .center)
            case "flexEnd":
                YGNodeStyleSetJustifyContent(node, .flexEnd)
            case "spaceBetween":
                YGNodeStyleSetJustifyContent(node, .spaceBetween)
            case "spaceAround":
                YGNodeStyleSetJustifyContent(node, .spaceAround)
            case "spaceEvenly":
                YGNodeStyleSetJustifyContent(node, .spaceEvenly)
            default:
                break
            }
        }
        
        // Align items
        if let alignItems = props["alignItems"] as? String {
            switch alignItems {
            case "flexStart":
                YGNodeStyleSetAlignItems(node, .flexStart)
            case "center":
                YGNodeStyleSetAlignItems(node, .center)
            case "flexEnd":
                YGNodeStyleSetAlignItems(node, .flexEnd)
            case "stretch":
                YGNodeStyleSetAlignItems(node, .stretch)
            case "baseline":
                YGNodeStyleSetAlignItems(node, .baseline)
            default:
                break
            }
        }
        
        // Align self
        if let alignSelf = props["alignSelf"] as? String {
            switch alignSelf {
            case "auto":
                YGNodeStyleSetAlignSelf(node, .auto)
            case "flexStart":
                YGNodeStyleSetAlignSelf(node, .flexStart)
            case "center":
                YGNodeStyleSetAlignSelf(node, .center)
            case "flexEnd":
                YGNodeStyleSetAlignSelf(node, .flexEnd)
            case "stretch":
                YGNodeStyleSetAlignSelf(node, .stretch)
            case "baseline":
                YGNodeStyleSetAlignSelf(node, .baseline)
            default:
                break
            }
        }
        
        // Flex properties
        if let flex = props["flex"] as? Float {
            YGNodeStyleSetFlex(node, flex)
        }
        
        if let flexGrow = props["flexGrow"] as? Float {
            YGNodeStyleSetFlexGrow(node, flexGrow)
        }
        
        if let flexShrink = props["flexShrink"] as? Float {
            YGNodeStyleSetFlexShrink(node, flexShrink)
        }
        
        if let flexBasis = props["flexBasis"] as? Float {
            YGNodeStyleSetFlexBasis(node, flexBasis)
        } else if let flexBasis = props["flexBasis"] as? String, flexBasis == "auto" {
            YGNodeStyleSetFlexBasisAuto(node)
        }
        
        // Width and height
        if let width = props["width"] as? Float {
            YGNodeStyleSetWidth(node, width)
        } else if let width = props["width"] as? Double {
            YGNodeStyleSetWidth(node, Float(width))
        } else if let width = props["width"] as? CGFloat {
            YGNodeStyleSetWidth(node, Float(width))
        } else if let width = props["width"] as? String {
            if width == "auto" {
                YGNodeStyleSetWidthAuto(node)
            } else if width.hasSuffix("%"), let percentValue = Float(width.dropLast()) {
                YGNodeStyleSetWidthPercent(node, percentValue)
            }
        }
        
        if let height = props["height"] as? Float {
            YGNodeStyleSetHeight(node, height)
        } else if let height = props["height"] as? Double {
            YGNodeStyleSetHeight(node, Float(height))
        } else if let height = props["height"] as? CGFloat {
            YGNodeStyleSetHeight(node, Float(height))
        } else if let height = props["height"] as? String {
            if height == "auto" {
                YGNodeStyleSetHeightAuto(node)
            } else if height.hasSuffix("%"), let percentValue = Float(height.dropLast()) {
                YGNodeStyleSetHeightPercent(node, percentValue)
            }
        }
        
        // Margins
        if let margin = props["margin"] as? Float {
            YGNodeStyleSetMargin(node, .all, margin)
        } else if let margin = props["margin"] as? CGFloat {
            YGNodeStyleSetMargin(node, .all, Float(margin))
        }
        
        // Paddings
        if let padding = props["padding"] as? Float {
            YGNodeStyleSetPadding(node, .all, padding)
        } else if let padding = props["padding"] as? CGFloat {
            YGNodeStyleSetPadding(node, .all, Float(padding))
        }
        
        // Handle individual directions for margin and padding
        let directions: [(String, YGEdge)] = [
            ("marginTop", .top),
            ("marginBottom", .bottom),
            ("marginLeft", .left),
            ("marginRight", .right),
            ("paddingTop", .top),
            ("paddingBottom", .bottom),
            ("paddingLeft", .left),
            ("paddingRight", .right)
        ]
        
        for (propName, edge) in directions {
            if propName.starts(with: "margin") {
                if let value = props[propName] as? Float {
                    YGNodeStyleSetMargin(node, edge, value)
                } else if let value = props[propName] as? CGFloat {
                    YGNodeStyleSetMargin(node, edge, Float(value))
                }
            } else if propName.starts(with: "padding") {
                if let value = props[propName] as? Float {
                    YGNodeStyleSetPadding(node, edge, value)
                } else if let value = props[propName] as? CGFloat {
                    YGNodeStyleSetPadding(node, edge, Float(value))
                }
            }
        }
        
        // Special handling for text elements
        if let view = viewForNode(node), view is UILabel {
            let label = view as! UILabel
            
            // Labels need to have size set or be able to calculate their size
            if label.text != nil && !label.text!.isEmpty {
                // If width is not explicitly set, calculate preferred width
                if props["width"] == nil {
                    // Get preferred size
                    let idealSize = label.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
                    
                    // Set explicit width on yoga node - ensures text is visible
                    if idealSize.width > 0 {
                        YGNodeStyleSetWidth(node, Float(idealSize.width))
                        print("DEBUG: Auto-setting text width to \(idealSize.width)")
                    }
                    
                    // Set explicit height on yoga node - ensures text is visible
                    if idealSize.height > 0 {
                        YGNodeStyleSetHeight(node, Float(idealSize.height))
                        print("DEBUG: Auto-setting text height to \(idealSize.height)")
                    }
                }
            }
        }
    }
    
    // Helper to lookup view for node (reverse lookup)
    private func viewForNode(_ node: YGNodeRef) -> UIView? {
        for (id, storedNode) in viewToNode {
            if storedNode == node {
                // ObjectIdentifier is typically used with an object
                return unsafeBitCast(id, to: UIView.self)
            }
        }
        return nil
    }
    
    // Apply calculated Yoga layout to a UIView
    func applyCalculatedLayout(_ node: YGNodeRef, to view: UIView) {
        let left = CGFloat(YGNodeLayoutGetLeft(node))
        let top = CGFloat(YGNodeLayoutGetTop(node))
        let width = CGFloat(YGNodeLayoutGetWidth(node))
        let height = CGFloat(YGNodeLayoutGetHeight(node))
        
        // Apply layout to view
        view.frame = CGRect(x: left, y: top, width: width, height: height)
        
        print("Applied layout to \(view): \(view.frame)")
    }
}
