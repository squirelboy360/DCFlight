import UIKit
import yoga

/// Shadow tree for layout calculations using Yoga
class YogaShadowTree {
    // Singleton instance
    static let shared = YogaShadowTree()
    
    // Root node of the shadow tree
    private var rootNode: YGNodeRef?
    
    // Map of node IDs to yoga nodes
    private var nodes = [String: YGNodeRef]()
    
    // Map of child-parent relationships
    private var nodeParents = [String: String]()
    
    // Map for storing component types
    private var nodeTypes = [String: String]()
    
    // Private initializer for singleton
    private init() {
        // Create root node
        rootNode = YGNodeNew()
        
        // Configure default root properties
        if let root = rootNode {
            YGNodeStyleSetDirection(root, YGDirection.LTR)
            YGNodeStyleSetFlexDirection(root, YGFlexDirection.column)
            YGNodeStyleSetWidth(root, Float(UIScreen.main.bounds.width))
            YGNodeStyleSetHeight(root, Float(UIScreen.main.bounds.height))
            
            // Store root node
            nodes["root"] = root
            nodeTypes["root"] = "View"
        }
        
        print("YogaShadowTree initialized with root node")
    }
    
    // Create a new node in the shadow tree
    func createNode(id: String, componentType: String) {
        print("Creating shadow node: \(id) of type \(componentType)")
        
        // Create new node
        let node = YGNodeNew()
        
        // Configure default properties based on component type
        configureNodeDefaults(node, forComponentType: componentType)
        
        // Store node
        nodes[id] = node
        nodeTypes[id] = componentType
    }
    
    // Add a child node to a parent node
    func addChildNode(parentId: String, childId: String, index: Int? = nil) {
        guard let parentNode = nodes[parentId], let childNode = nodes[childId] else {
            print("Cannot add child: parent or child node not found")
            return
        }
        
        // First, remove child from any existing parent
        if let oldParentId = nodeParents[childId], let oldParentNode = nodes[oldParentId] {
            YGNodeRemoveChild(oldParentNode, childNode)
        }
        
        // Then add to new parent
        if let index = index {
            // Add at specific index
            if index < Int(YGNodeGetChildCount(parentNode)) {
                YGNodeInsertChild(parentNode, childNode, UInt32(index))
            } else {
                YGNodeInsertChild(parentNode, childNode, UInt32(YGNodeGetChildCount(parentNode)))
            }
        } else {
            // Add at the end
            YGNodeInsertChild(parentNode, childNode, UInt32(YGNodeGetChildCount(parentNode)))
        }
        
        // Update parent reference
        nodeParents[childId] = parentId
    }
    
    // Remove a node from the shadow tree
    func removeNode(nodeId: String) {
        guard let node = nodes[nodeId] else { return }
        
        // Remove from parent if any
        if let parentId = nodeParents[nodeId], let parentNode = nodes[parentId] {
            YGNodeRemoveChild(parentNode, node)
        }
        
        // Clean up children
        let childCount = YGNodeGetChildCount(node)
        for i in 0..<childCount {
            let childNode = YGNodeGetChild(node, 0) // Always remove the first one
            YGNodeRemoveChild(node, childNode)
        }
        
        // Free memory
        YGNodeFree(node)
        
        // Remove references
        nodes.removeValue(forKey: nodeId)
        nodeParents.removeValue(forKey: nodeId)
        nodeTypes.removeValue(forKey: nodeId)
    }
    
    // Update a node's layout properties
    func updateNodeLayoutProps(nodeId: String, props: [String: Any]) {
        guard let node = nodes[nodeId] else {
            print("Cannot update layout: node not found for ID \(nodeId)")
            return
        }
        
        print("Applying layout props to node \(nodeId): \(props)")
        
        // Process each property
        for (key, value) in props {
            applyLayoutProp(node: node, key: key, value: value)
        }
        
        // Do not mark nodes as dirty - Yoga will handle this automatically
        // during the next layout calculation
    }
    
    // Calculate layout for the shadow tree
    func calculateLayout(width: CGFloat, height: CGFloat, direction: YGDirection = YGDirection.LTR) {
        guard let root = rootNode else { return }
        
        print("Calculating layout for \(nodes.count) root nodes with dimensions: \(width)x\(height)")
        
        // Set root dimensions
        YGNodeStyleSetWidth(root, Float(width))
        YGNodeStyleSetHeight(root, Float(height))
        
        // Calculate layout
        YGNodeCalculateLayout(root, Float(width), Float(height), direction)
        
        print("Layout calculation completed for \(width)x\(height)")
    }
    
    // Get layout for a node after calculation
    func getNodeLayout(nodeId: String) -> CGRect? {
        guard let node = nodes[nodeId] else { return nil }
        
        // Get layout values
        let left = CGFloat(YGNodeLayoutGetLeft(node))
        let top = CGFloat(YGNodeLayoutGetTop(node))
        let width = CGFloat(YGNodeLayoutGetWidth(node))
        let height = CGFloat(YGNodeLayoutGetHeight(node))
        
        return CGRect(x: left, y: top, width: width, height: height)
    }
    
    // Apply a layout property to a node
    private func applyLayoutProp(node: YGNodeRef, key: String, value: Any) {
        switch key {
        case "width":
            if let width = convertToFloat(value) {
                YGNodeStyleSetWidth(node, width)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetWidthPercent(node, percentValue)
            }
        case "height":
            if let height = convertToFloat(value) {
                YGNodeStyleSetHeight(node, height)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetHeightPercent(node, percentValue)
            }
        case "minWidth":
            if let minWidth = convertToFloat(value) {
                YGNodeStyleSetMinWidth(node, minWidth)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetMinWidthPercent(node, percentValue)
            }
        case "maxWidth":
            if let maxWidth = convertToFloat(value) {
                YGNodeStyleSetMaxWidth(node, maxWidth)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetMaxWidthPercent(node, percentValue)
            }
        case "minHeight":
            if let minHeight = convertToFloat(value) {
                YGNodeStyleSetMinHeight(node, minHeight)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetMinHeightPercent(node, percentValue)
            }
        case "maxHeight":
            if let maxHeight = convertToFloat(value) {
                YGNodeStyleSetMaxHeight(node, maxHeight)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetMaxHeightPercent(node, percentValue)
            }
        case "margin":
            if let margin = convertToFloat(value) {
                YGNodeStyleSetMargin(node, YGEdge.all, margin)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetMarginPercent(node, YGEdge.all, percentValue)
            }
        case "marginTop":
            if let marginTop = convertToFloat(value) {
                YGNodeStyleSetMargin(node, YGEdge.top, marginTop)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetMarginPercent(node, YGEdge.top, percentValue)
            }
        case "marginRight":
            if let marginRight = convertToFloat(value) {
                YGNodeStyleSetMargin(node, YGEdge.right, marginRight)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetMarginPercent(node, YGEdge.right, percentValue)
            }
        case "marginBottom":
            if let marginBottom = convertToFloat(value) {
                YGNodeStyleSetMargin(node, YGEdge.bottom, marginBottom)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetMarginPercent(node, YGEdge.bottom, percentValue)
            }
        case "marginLeft":
            if let marginLeft = convertToFloat(value) {
                YGNodeStyleSetMargin(node, YGEdge.left, marginLeft)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetMarginPercent(node, YGEdge.left, percentValue)
            }
        case "padding":
            if let padding = convertToFloat(value) {
                YGNodeStyleSetPadding(node, YGEdge.all, padding)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetPaddingPercent(node, YGEdge.all, percentValue)
            }
        case "paddingTop":
            if let paddingTop = convertToFloat(value) {
                YGNodeStyleSetPadding(node, YGEdge.top, paddingTop)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetPaddingPercent(node, YGEdge.top, percentValue)
            }
        case "paddingRight":
            if let paddingRight = convertToFloat(value) {
                YGNodeStyleSetPadding(node, YGEdge.right, paddingRight)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetPaddingPercent(node, YGEdge.right, percentValue)
            }
        case "paddingBottom":
            if let paddingBottom = convertToFloat(value) {
                YGNodeStyleSetPadding(node, YGEdge.bottom, paddingBottom)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetPaddingPercent(node, YGEdge.bottom, percentValue)
            }
        case "paddingLeft":
            if let paddingLeft = convertToFloat(value) {
                YGNodeStyleSetPadding(node, YGEdge.left, paddingLeft)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetPaddingPercent(node, YGEdge.left, percentValue)
            }
        case "position":
            if let position = value as? String {
                switch position {
                case "absolute":
                    YGNodeStyleSetPositionType(node, YGPositionType.absolute)
                case "relative":
                    YGNodeStyleSetPositionType(node, YGPositionType.relative)
                default:
                    break
                }
            }
        case "left":
            if let left = convertToFloat(value) {
                YGNodeStyleSetPosition(node, YGEdge.left, left)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetPositionPercent(node, YGEdge.left, percentValue)
            }
        case "top":
            if let top = convertToFloat(value) {
                YGNodeStyleSetPosition(node, YGEdge.top, top)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetPositionPercent(node, YGEdge.top, percentValue)
            }
        case "right":
            if let right = convertToFloat(value) {
                YGNodeStyleSetPosition(node, YGEdge.right, right)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetPositionPercent(node, YGEdge.right, percentValue)
            }
        case "bottom":
            if let bottom = convertToFloat(value) {
                YGNodeStyleSetPosition(node, YGEdge.bottom, bottom)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetPositionPercent(node, YGEdge.bottom, percentValue)
            }
        case "flexDirection":
            if let direction = value as? String {
                switch direction {
                case "row":
                    YGNodeStyleSetFlexDirection(node, YGFlexDirection.row)
                case "column":
                    YGNodeStyleSetFlexDirection(node, YGFlexDirection.column)
                case "rowReverse":
                    YGNodeStyleSetFlexDirection(node, YGFlexDirection.rowReverse)
                case "columnReverse":
                    YGNodeStyleSetFlexDirection(node, YGFlexDirection.columnReverse)
                default:
                    break
                }
            }
        case "justifyContent":
            if let justify = value as? String {
                switch justify {
                case "flexStart":
                    YGNodeStyleSetJustifyContent(node, YGJustify.flexStart)
                case "center":
                    YGNodeStyleSetJustifyContent(node, YGJustify.center)
                case "flexEnd":
                    YGNodeStyleSetJustifyContent(node, YGJustify.flexEnd)
                case "spaceBetween":
                    YGNodeStyleSetJustifyContent(node, YGJustify.spaceBetween)
                case "spaceAround":
                    YGNodeStyleSetJustifyContent(node, YGJustify.spaceAround)
                case "spaceEvenly":
                    YGNodeStyleSetJustifyContent(node, YGJustify.spaceEvenly)
                default:
                    break
                }
            }
        case "alignItems":
            if let align = value as? String {
                switch align {
                case "auto":
                    YGNodeStyleSetAlignItems(node, YGAlign.auto)
                case "flexStart":
                    YGNodeStyleSetAlignItems(node, YGAlign.flexStart)
                case "center":
                    YGNodeStyleSetAlignItems(node, YGAlign.center)
                case "flexEnd":
                    YGNodeStyleSetAlignItems(node, YGAlign.flexEnd)
                case "stretch":
                    YGNodeStyleSetAlignItems(node, YGAlign.stretch)
                case "baseline":
                    YGNodeStyleSetAlignItems(node, YGAlign.baseline)
                case "spaceBetween":
                    YGNodeStyleSetAlignItems(node, YGAlign.spaceBetween)
                case "spaceAround":
                    YGNodeStyleSetAlignItems(node, YGAlign.spaceAround)
                default:
                    break
                }
            }
        case "alignSelf":
            if let align = value as? String {
                switch align {
                case "auto":
                    YGNodeStyleSetAlignSelf(node, YGAlign.auto)
                case "flexStart":
                    YGNodeStyleSetAlignSelf(node, YGAlign.flexStart)
                case "center":
                    YGNodeStyleSetAlignSelf(node, YGAlign.center)
                case "flexEnd":
                    YGNodeStyleSetAlignSelf(node, YGAlign.flexEnd)
                case "stretch":
                    YGNodeStyleSetAlignSelf(node, YGAlign.stretch)
                case "baseline":
                    YGNodeStyleSetAlignSelf(node, YGAlign.baseline)
                case "spaceBetween":
                    YGNodeStyleSetAlignSelf(node, YGAlign.spaceBetween)
                case "spaceAround":
                    YGNodeStyleSetAlignSelf(node, YGAlign.spaceAround)
                default:
                    break
                }
            }
        case "flexWrap":
            if let wrap = value as? String {
                switch wrap {
                case "nowrap":
                    YGNodeStyleSetFlexWrap(node, YGWrap.noWrap)
                case "wrap":
                    YGNodeStyleSetFlexWrap(node, YGWrap.wrap)
                case "wrapReverse":
                    YGNodeStyleSetFlexWrap(node, YGWrap.wrapReverse)
                default:
                    break
                }
            }
        case "flex":
            if let flex = convertToFloat(value) {
                YGNodeStyleSetFlex(node, flex)
            }
        case "flexGrow":
            if let flexGrow = convertToFloat(value) {
                YGNodeStyleSetFlexGrow(node, flexGrow)
            }
        case "flexShrink":
            if let flexShrink = convertToFloat(value) {
                YGNodeStyleSetFlexShrink(node, flexShrink)
            }
        case "flexBasis":
            if let flexBasis = convertToFloat(value) {
                YGNodeStyleSetFlexBasis(node, flexBasis)
            } else if let strValue = value as? String, strValue.hasSuffix("%"), 
                     let percentValue = Float(strValue.dropLast()) {
                YGNodeStyleSetFlexBasisPercent(node, percentValue)
            }
        case "display":
            if let display = value as? String {
                switch display {
                case "flex":
                    YGNodeStyleSetDisplay(node, YGDisplay.flex)
                case "none":
                    YGNodeStyleSetDisplay(node, YGDisplay.none)
                default:
                    break
                }
            }
        case "overflow":
            if let overflow = value as? String {
                switch overflow {
                case "visible":
                    YGNodeStyleSetOverflow(node, YGOverflow.visible)
                case "hidden":
                    YGNodeStyleSetOverflow(node, YGOverflow.hidden)
                case "scroll":
                    YGNodeStyleSetOverflow(node, YGOverflow.scroll)
                default:
                    break
                }
            }
        case "direction":
            if let direction = value as? String {
                switch direction {
                case "inherit":
                    YGNodeStyleSetDirection(node, YGDirection.inherit)
                case "ltr":
                    YGNodeStyleSetDirection(node, YGDirection.LTR)
                case "rtl":
                    YGNodeStyleSetDirection(node, YGDirection.RTL)
                default:
                    break
                }
            }
        case "borderWidth":
            if let borderWidth = convertToFloat(value) {
                YGNodeStyleSetBorder(node, YGEdge.all, borderWidth)
            }
        default:
            break
        }
    }
    
    // Helper to convert input values to Float
    private func convertToFloat(_ value: Any) -> Float? {
        if let num = value as? Float {
            return num
        } else if let num = value as? Double {
            return Float(num)
        } else if let num = value as? Int {
            return Float(num)
        } else if let num = value as? CGFloat {
            return Float(num)
        } else if let str = value as? String, let num = Float(str) {
            return num
        }
        return nil
    }
    
    // Set default properties based on component type
    private func configureNodeDefaults(_ node: YGNodeRef, forComponentType componentType: String) {
        // Set common defaults
        YGNodeStyleSetFlexDirection(node, YGFlexDirection.column)
        
        // Set component-specific defaults
        switch componentType {
        case "Text":
            // Texts are leaf nodes by default
            YGNodeStyleSetFlexShrink(node, 1.0)
            
        case "Image":
            // Images are also leaf nodes
            YGNodeStyleSetAlignSelf(node, YGAlign.flexStart)
            
        case "ScrollView":
            // ScrollViews have special layout behavior
            YGNodeStyleSetOverflow(node, YGOverflow.scroll)
            YGNodeStyleSetFlexGrow(node, 1.0)
            
        default:
            // Default container behavior
            break
        }
    }
    
    // Set a custom measure function for nodes that need to self-measure
    func setCustomMeasureFunction(nodeId: String, measureFunc: @escaping YGMeasureFunc) {
        guard let node = nodes[nodeId] else { return }
        
        // Make sure node has no children before setting measure function
        if YGNodeGetChildCount(node) == 0 {
            YGNodeSetMeasureFunc(node, measureFunc)
        }
    }
    
    // Cleanup
    deinit {
        // Free all nodes
        for (_, node) in nodes {
            YGNodeFree(node)
        }
    }
}

// Layout Manager extension for DCMauiLayoutManager
extension DCMauiLayoutManager {
    // Register view with layout system
    func registerView(_ view: UIView, withNodeId nodeId: String, componentType: String, componentInstance: DCMauiComponent) {
        // First, register the view for direct access
        registerView(view, withId: nodeId)
        
        // Associate the view with its Yoga node
        print("Associated view with node \(nodeId) of type \(componentType)")
        
        // Set up special handling for nodes that need to self-measure
        if componentType == "Text" {
            // Don't actually set a measure function, but mark it specially
            view.accessibilityIdentifier = "text_\(nodeId)"
        }
        
        // Let the component know it's registered
        componentInstance.viewRegisteredWithShadowTree(view, nodeId: nodeId)
    }
    
    // Add a child node to a parent in the layout tree
    func addChildNode(parentId: String, childId: String, index: Int) {
        YogaShadowTree.shared.addChildNode(parentId: parentId, childId: childId, index: index)
    }
    
    // Remove a node from the layout tree
    func removeNode(nodeId: String) {
        YogaShadowTree.shared.removeNode(nodeId: nodeId)
    }
    
    // Update a node's layout properties
    func updateNodeWithLayoutProps(nodeId: String, componentType: String, props: [String: Any]) {
        YogaShadowTree.shared.updateNodeLayoutProps(nodeId: nodeId, props: props)
    }
}
