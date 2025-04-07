import UIKit
import yoga

/// Manages the Yoga shadow tree for layout calculation
class YogaShadowTree {
    // Singleton instance
    static let shared = YogaShadowTree()
    
    // Map of node IDs to YGNodes
    private var nodes = [String: YGNodeRef]()
    
    // Map of node IDs to associated views
    private var views = [String: UIView]()
    
    // Map of node IDs to parent node IDs
    private var parentNodes = [String: String]()
    
    // Map of node IDs to component types
    private var componentTypes = [String: String]()
    
    // Root node IDs
    private var rootNodeIds = Set<String>()
    
    // Private initializer for singleton
    private init() {
        // Configure Yoga with defaults
        YGConfigSetPointScaleFactor(YGConfigGetDefault(), Float(UIScreen.main.scale))
    }
    
    // MARK: - Node Management
    
    /// Create a node in the shadow tree
    func createNode(id: String, componentType: String) -> YGNodeRef? {
        NSLog("Creating shadow node: \(id) of type \(componentType)")
        guard !nodes.keys.contains(id) else {
            NSLog("Node \(id) already exists")
            return nodes[id]
        }
        
        let node = YGNodeNew()
        nodes[id] = node
        componentTypes[id] = componentType
        rootNodeIds.insert(id) // Initially assume it's a root until added as child
        
        // Set some reasonable defaults
        YGNodeStyleSetFlexDirection(node, YGFlexDirection.column)
        YGNodeStyleSetAlignItems(node, YGAlign.stretch)
        
        return node
    }
    
    /// Remove a node from the shadow tree
    func removeNode(id: String) {
        NSLog("Removing shadow node: \(id)")
        guard let node = nodes[id] else { return }
        
        // Remove from roots if applicable
        rootNodeIds.remove(id)
        
        // Remove parent reference
        parentNodes.removeValue(forKey: id)
        
        // If this node is a parent, update its children
        let childNodeIds = parentNodes.filter { $0.value == id }.keys
        for childId in childNodeIds {
            parentNodes.removeValue(forKey: childId)
            rootNodeIds.insert(childId) // Make children roots
        }
        
        // Free the Yoga node
        YGNodeFree(node)
        nodes.removeValue(forKey: id)
        componentTypes.removeValue(forKey: id)
        views.removeValue(forKey: id)
    }
    
    /// Check if a node exists
    func hasNode(id: String) -> Bool {
        return nodes.keys.contains(id)
    }
    
    /// Get a node by ID
    func getNode(id: String) -> YGNodeRef? {
        return nodes[id]
    }
    
    // MARK: - Parent-Child Relationships
    
    /// Add a child node to a parent node
    func addChild(parentId: String, childId: String, index: Int) {
        guard let parentNode = nodes[parentId], let childNode = nodes[childId] else {
            NSLog("Cannot add child: parent or child node not found")
            return
        }
        
        // Update hierarchy info
        parentNodes[childId] = parentId
        rootNodeIds.remove(childId)
        
        // Add to Yoga tree
        YGNodeInsertChild(parentNode, childNode, index)
        
        NSLog("Added node \(childId) as child to \(parentId) at index \(index)")
    }
    
    /// Remove a child node from its parent
    func removeChild(childId: String) {
        guard let childNode = nodes[childId], let parentId = parentNodes[childId], let parentNode = nodes[parentId] else {
            return
        }
        
        // Find the child index
        let childCount = YGNodeGetChildCount(parentNode)
        for i in 0..<childCount {
            if YGNodeGetChild(parentNode, i) == childNode {
                YGNodeRemoveChild(parentNode, childNode)
                break
            }
        }
        
        // Update hierarchy info
        parentNodes.removeValue(forKey: childId)
        rootNodeIds.insert(childId)
        
        NSLog("Removed node \(childId) from parent \(parentId)")
    }
    
    // MARK: - View Association
    
    /// Associate a view with a node
    func associateView(_ view: UIView, withNodeId nodeId: String, componentType: String, componentInstance: DCMauiComponent) {
        views[nodeId] = view
        view.nodeId = nodeId
        
        // Notify the component instance
        componentInstance.viewRegisteredWithShadowTree(view, nodeId: nodeId)
        
        NSLog("Associated view with node \(nodeId) of type \(componentType)")
    }
    
    /// Get a view by node ID
    func getView(forNodeId nodeId: String) -> UIView? {
        return views[nodeId]
    }
    
    // MARK: - Layout Properties
    
    /// Apply layout properties to a node
    func applyLayoutProps(nodeId: String, props: [String: Any]) {
        guard let node = nodes[nodeId] else {
            NSLog("Cannot apply layout props: node \(nodeId) not found")
            return
        }
        
        NSLog("Applying layout props to node \(nodeId): \(props)")
        
        // Basic dimensions
        applyDimension(node: node, prop: props["width"], dimension: .width)
        applyDimension(node: node, prop: props["height"], dimension: .height)
        applyDimension(node: node, prop: props["minWidth"], dimension: .minWidth)
        applyDimension(node: node, prop: props["minHeight"], dimension: .minHeight)
        applyDimension(node: node, prop: props["maxWidth"], dimension: .maxWidth)
        applyDimension(node: node, prop: props["maxHeight"], dimension: .maxHeight)
        
        // Margins
        applyEdgeValue(node: node, prop: props["margin"], edge: YGEdge.all, property: .margin)
        applyEdgeValue(node: node, prop: props["marginTop"], edge: YGEdge.top, property: .margin)
        applyEdgeValue(node: node, prop: props["marginRight"], edge: YGEdge.right, property: .margin)
        applyEdgeValue(node: node, prop: props["marginBottom"], edge: YGEdge.bottom, property: .margin)
        applyEdgeValue(node: node, prop: props["marginLeft"], edge: YGEdge.left, property: .margin)
        if let marginHorizontal = props["marginHorizontal"] {
            applyEdgeValue(node: node, prop: marginHorizontal, edge: YGEdge.horizontal, property: .margin)
        }
        if let marginVertical = props["marginVertical"] {
            applyEdgeValue(node: node, prop: marginVertical, edge: YGEdge.vertical, property: .margin)
        }
        
        // Padding
        applyEdgeValue(node: node, prop: props["padding"], edge: YGEdge.all, property: .padding)
        applyEdgeValue(node: node, prop: props["paddingTop"], edge: YGEdge.top, property: .padding)
        applyEdgeValue(node: node, prop: props["paddingRight"], edge: YGEdge.right, property: .padding)
        applyEdgeValue(node: node, prop: props["paddingBottom"], edge: YGEdge.bottom, property: .padding)
        applyEdgeValue(node: node, prop: props["paddingLeft"], edge: YGEdge.left, property: .padding)
        if let paddingHorizontal = props["paddingHorizontal"] {
            applyEdgeValue(node: node, prop: paddingHorizontal, edge: YGEdge.horizontal, property: .padding)
        }
        if let paddingVertical = props["paddingVertical"] {
            applyEdgeValue(node: node, prop: paddingVertical, edge: YGEdge.vertical, property: .padding)
        }
        
        // Position
        applyEdgeValue(node: node, prop: props["left"], edge: YGEdge.left, property: .position)
        applyEdgeValue(node: node, prop: props["top"], edge: YGEdge.top, property: .position)
        applyEdgeValue(node: node, prop: props["right"], edge: YGEdge.right, property: .position)
        applyEdgeValue(node: node, prop: props["bottom"], edge: YGEdge.bottom, property: .position)
        
        // Position type
        if let position = props["position"] as? String {
            switch position {
            case "absolute":
                YGNodeStyleSetPositionType(node, YGPositionType.absolute)
            default: // relative is default
                YGNodeStyleSetPositionType(node, YGPositionType.relative)
            }
        }
        
        // Flex properties
        if let flex = props["flex"] as? NSNumber {
            YGNodeStyleSetFlex(node, flex.floatValue)
        }
        
        if let flexGrow = props["flexGrow"] as? NSNumber {
            YGNodeStyleSetFlexGrow(node, flexGrow.floatValue)
        }
        
        if let flexShrink = props["flexShrink"] as? NSNumber {
            YGNodeStyleSetFlexShrink(node, flexShrink.floatValue)
        }
        
        applyDimension(node: node, prop: props["flexBasis"], dimension: .flexBasis)
        
        // Flex direction
        if let flexDirection = props["flexDirection"] as? String {
            switch flexDirection {
            case "row":
                YGNodeStyleSetFlexDirection(node, YGFlexDirection.row)
            case "rowReverse":
                YGNodeStyleSetFlexDirection(node, YGFlexDirection.rowReverse)
            case "column":
                YGNodeStyleSetFlexDirection(node, YGFlexDirection.column)
            case "columnReverse":
                YGNodeStyleSetFlexDirection(node, YGFlexDirection.columnReverse)
            default:
                break
            }
        }
        
        // Justify content
        if let justifyContent = props["justifyContent"] as? String {
            switch justifyContent {
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
        
        // Align items
        if let alignItems = props["alignItems"] as? String {
            switch alignItems {
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
            default:
                break
            }
        }
        
        // Align self
        if let alignSelf = props["alignSelf"] as? String {
            switch alignSelf {
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
            default:
                break
            }
        }
        
        // Align content
        if let alignContent = props["alignContent"] as? String {
            switch alignContent {
            case "flexStart":
                YGNodeStyleSetAlignContent(node, YGAlign.flexStart)
            case "center":
                YGNodeStyleSetAlignContent(node, YGAlign.center)
            case "flexEnd":
                YGNodeStyleSetAlignContent(node, YGAlign.flexEnd)
            case "stretch":
                YGNodeStyleSetAlignContent(node, YGAlign.stretch)
            case "spaceBetween":
                YGNodeStyleSetAlignContent(node, YGAlign.spaceBetween)
            case "spaceAround":
                YGNodeStyleSetAlignContent(node, YGAlign.spaceAround)
            default:
                break
            }
        }
        
        // Flex wrap
        if let flexWrap = props["flexWrap"] as? String {
            switch flexWrap {
            case "wrap":
                YGNodeStyleSetFlexWrap(node, YGWrap.wrap)
            case "nowrap":
                YGNodeStyleSetFlexWrap(node, YGWrap.noWrap)
            case "wrapReverse":
                YGNodeStyleSetFlexWrap(node, YGWrap.wrapReverse)
            default:
                break
            }
        }
        
        // Display
        if let display = props["display"] as? String {
            switch display {
            case "none":
                YGNodeStyleSetDisplay(node, YGDisplay.none)
            default: // flex is default
                YGNodeStyleSetDisplay(node, YGDisplay.flex)
            }
        }
        
        // Overflow
        if let overflow = props["overflow"] as? String {
            switch overflow {
            case "hidden":
                YGNodeStyleSetOverflow(node, YGOverflow.hidden)
            case "scroll":
                YGNodeStyleSetOverflow(node, YGOverflow.scroll)
            default: // visible is default
                YGNodeStyleSetOverflow(node, YGOverflow.visible)
            }
        }
        
        // Mark node as dirty
        YGNodeMarkDirty(node)
        
        // Notify that layout needs to be recalculated
        DCMauiLayoutManager.shared.setNeedsLayout()
    }
    
    // MARK: - Layout Calculation
    
    /// Calculate layout for all root nodes
    func calculateLayout(width: Float, height: Float) {
        NSLog("Calculating layout for \(rootNodeIds.count) root nodes with dimensions: \(width)x\(height)")
        
        for rootNodeId in rootNodeIds {
            guard let rootNode = nodes[rootNodeId] else { continue }
            
            // Calculate layout with LTR direction
            YGNodeCalculateLayout(rootNode, width, height, YGDirection.LTR)
            
            // Apply layout to views
            applyLayoutToView(nodeId: rootNodeId)
        }
    }
    
    /// Apply calculated layout to view and its children
    private func applyLayoutToView(nodeId: String) {
        guard let node = nodes[nodeId], let view = views[nodeId],
              let componentType = componentTypes[nodeId] else { return }
        
        // Get component instance from registry
        guard let componentInstance = DCMauiComponentRegistry.shared.getComponentType(for: componentType) else {
            NSLog("Component not found for type: \(componentType)")
            return
        }
        
        // Create component instance
        let instance = componentInstance.init()
        
        // Get layout values
        let layout = YGNodeLayout(
            left: CGFloat(YGNodeLayoutGetLeft(node)),
            top: CGFloat(YGNodeLayoutGetTop(node)),
            width: CGFloat(YGNodeLayoutGetWidth(node)),
            height: CGFloat(YGNodeLayoutGetHeight(node))
        )
        
        // Apply layout to view using component's implementation
        instance.applyLayout(view, layout: layout)
        
        NSLog("Applied layout to \(nodeId): \(layout)")
        
        // Apply layout to children
        let childCount = YGNodeGetChildCount(node)
        
        for i in 0..<childCount {
            let childNode = YGNodeGetChild(node, i)
            
            // Find child ID from node
            if let childId = nodes.first(where: { $0.value == childNode })?.key {
                applyLayoutToView(nodeId: childId)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Helper enum for dimension types
    private enum DimensionType {
        case width
        case height
        case minWidth
        case minHeight
        case maxWidth
        case maxHeight
        case flexBasis
    }
    
    /// Helper enum for edge property types
    private enum EdgePropertyType {
        case margin
        case padding
        case position
        case border
    }
    
    /// Helper to apply dimension values (handles points, percents, and auto)
    private func applyDimension(node: YGNodeRef, prop: Any?, dimension: DimensionType) {
        guard let prop = prop else { return }
        
        if let number = prop as? NSNumber {
            // Apply as points
            let value = number.floatValue
            
            switch dimension {
            case .width:
                YGNodeStyleSetWidth(node, value)
            case .height:
                YGNodeStyleSetHeight(node, value)
            case .minWidth:
                YGNodeStyleSetMinWidth(node, value)
            case .minHeight:
                YGNodeStyleSetMinHeight(node, value)
            case .maxWidth:
                YGNodeStyleSetMaxWidth(node, value)
            case .maxHeight:
                YGNodeStyleSetMaxHeight(node, value)
            case .flexBasis:
                YGNodeStyleSetFlexBasis(node, value)
            }
        } else if let string = prop as? String {
            if string == "auto" {
                // Apply as auto
                switch dimension {
                case .width:
                    YGNodeStyleSetWidthAuto(node)
                case .height:
                    YGNodeStyleSetHeightAuto(node)
                case .flexBasis:
                    YGNodeStyleSetFlexBasisAuto(node)
                default:
                    // No auto option for min/max dimensions
                    break
                }
            } else if string.hasSuffix("%") {
                // Apply as percentage
                if let percentString = string.dropLast().description as NSString? {
                    let percent = percentString.floatValue
                    
                    switch dimension {
                    case .width:
                        YGNodeStyleSetWidthPercent(node, percent)
                    case .height:
                        YGNodeStyleSetHeightPercent(node, percent)
                    case .minWidth:
                        YGNodeStyleSetMinWidthPercent(node, percent)
                    case .minHeight:
                        YGNodeStyleSetMinHeightPercent(node, percent)
                    case .maxWidth:
                        YGNodeStyleSetMaxWidthPercent(node, percent)
                    case .maxHeight:
                        YGNodeStyleSetMaxHeightPercent(node, percent)
                    case .flexBasis:
                        YGNodeStyleSetFlexBasisPercent(node, percent)
                    }
                }
            }
        }
    }
    
    /// Helper to apply edge values (margin, padding, position)
    private func applyEdgeValue(node: YGNodeRef, prop: Any?, edge: YGEdge, property: EdgePropertyType) {
        guard let prop = prop else { return }
        
        if let number = prop as? NSNumber {
            // Apply as points
            let value = number.floatValue
            
            switch property {
            case .margin:
                YGNodeStyleSetMargin(node, edge, value)
            case .padding:
                YGNodeStyleSetPadding(node, edge, value)
            case .position:
                YGNodeStyleSetPosition(node, edge, value)
            case .border:
                YGNodeStyleSetBorder(node, edge, value)
            }
        } else if let string = prop as? String {
            if string == "auto" && property == .margin {
                // Auto only available for margin
                YGNodeStyleSetMarginAuto(node, edge)
            } else if string.hasSuffix("%") {
                // Apply as percentage
                if let percentString = string.dropLast().description as NSString? {
                    let percent = percentString.floatValue
                    
                    switch property {
                    case .margin:
                        YGNodeStyleSetMarginPercent(node, edge, percent)
                    case .padding:
                        YGNodeStyleSetPaddingPercent(node, edge, percent)
                    case .position:
                        YGNodeStyleSetPositionPercent(node, edge, percent)
                    case .border:
                        // No percentage option for border
                        break
                    }
                }
            }
        }
    }
}
