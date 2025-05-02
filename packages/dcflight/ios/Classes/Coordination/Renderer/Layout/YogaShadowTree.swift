import UIKit
import yoga

/// Shadow tree for layout calculations using Yoga
class YogaShadowTree {
    // Singleton instance
    static let shared = YogaShadowTree()
    
    // Root node of the shadow tree
    private var rootNode: YGNodeRef?
    
    // Map of node IDs to yoga nodes
    internal var nodes = [String: YGNodeRef]()
    
    // Map of child-parent relationships
    internal var nodeParents = [String: String]()
    
    // Map for storing component types
    private var nodeTypes = [String: String]()
    
    // NEW: Track node creation timestamps for synchronization
    private var nodeCreationTimes = [String: TimeInterval]()
    
    // NEW: Track node modification timestamps
    private var nodeModificationTimes = [String: TimeInterval]()
    
    // NEW: Track synchronization state between native and Dart
    private var nodeSyncState = [String: Bool]()
    
    // NEW: Performance tracking
    private var layoutCalculationTimes = [TimeInterval]()
    private var lastLayoutTime: TimeInterval = 0
    private var layoutCount = 0
    
    // NEW: Layout debugging enabled flag
    private var debugLayoutEnabled = false
    
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
        
        // Check if debug layout is enabled via environment variable or user defaults
        if ProcessInfo.processInfo.environment["DCMAUI_DEBUG_LAYOUT"] == "1" ||
           UserDefaults.standard.bool(forKey: "DCMauiDebugLayout") {
            debugLayoutEnabled = true
        }
        
        print("YogaShadowTree initialized with root node")
    }
    
    // Create a new node in the shadow tree
    func createNode(id: String, componentType: String) {
        print("Creating shadow node: \(id) of type \(componentType)")
        
        // Create new node
        let node = YGNodeNew()
        
        
        if let node = node {
            
            // Store node
            nodes[id] = node
            nodeTypes[id] = componentType
            
            // NEW: Track creation time
            nodeCreationTimes[id] = Date().timeIntervalSince1970
            nodeSyncState[id] = true
        }
    }
    
    // Add a child node to a parent node
    func addChildNode(parentId: String, childId: String, index: Int? = nil) {
        guard let parentNode = nodes[parentId], let childNode = nodes[childId] else {
            print("Cannot add child: parent or child node not found")
            
            // NEW: Track sync issue
            nodeSyncState[parentId] = nodes[parentId] != nil
            nodeSyncState[childId] = nodes[childId] != nil
            
            // NEW: Log detailed error for debugging
            print("🚫 Failed parent-child relationship: parent=\(parentId) (\(nodes[parentId] != nil ? "exists" : "missing")), child=\(childId) (\(nodes[childId] != nil ? "exists" : "missing"))")
            return
        }
        
        // First, remove child from any existing parent
        if let oldParentId = nodeParents[childId], let oldParentNode = nodes[oldParentId] {
            YGNodeRemoveChild(oldParentNode, childNode)
        }
        
        // Then add to new parent
        if let index = index {
            // Add at specific index
            let childCount = Int(YGNodeGetChildCount(parentNode))
            if index < childCount {
                YGNodeInsertChild(parentNode, childNode, Int(Int32(index)))
            } else {
                YGNodeInsertChild(parentNode, childNode, Int(Int32(childCount)))
            }
        } else {
            // Add at the end
            let childCount = Int(YGNodeGetChildCount(parentNode))
            YGNodeInsertChild(parentNode, childNode, Int(Int32(childCount)))
        }
        
        // Update parent reference
        nodeParents[childId] = parentId
        
        // NEW: Update modification time
        nodeModificationTimes[childId] = Date().timeIntervalSince1970
        nodeModificationTimes[parentId] = Date().timeIntervalSince1970
        nodeSyncState[childId] = true
        nodeSyncState[parentId] = true
        
        // NEW: Log successful relationship
        print("✅ Added child \(childId) to parent \(parentId)")
    }
    
    // Remove a node from the shadow tree
    func removeNode(nodeId: String) {
        guard let node = nodes[nodeId] else {
            // NEW: Track removal of non-existent node
            print("⚠️ Attempted to remove non-existent node: \(nodeId)")
            return
        }
        
        // Before removing from parent, store parent ID for later reference
        let parentId = nodeParents[nodeId]
        
        // Remove from parent if any
        if let parentId = parentId, let parentNode = nodes[parentId] {
            YGNodeRemoveChild(parentNode, node)
            print("✅ Removed child \(nodeId) from parent \(parentId)")
        }
        
        // NEW: Remove all children first to prevent orphaned references
        let childNodeIds = nodeParents.filter { $0.value == nodeId }.map { $0.key }
        for childId in childNodeIds {
            // Remove the child node connection to parent first
            if let childNode = nodes[childId] {
                YGNodeRemoveChild(node, childNode)
            }
            // Update parent references
            nodeParents.removeValue(forKey: childId)
        }
        
        // Free memory
        YGNodeFree(node)
        
        // Remove references
        nodes.removeValue(forKey: nodeId)
        nodeParents.removeValue(forKey: nodeId)
        nodeTypes.removeValue(forKey: nodeId)
        
        // NEW: Clean up tracking
        nodeCreationTimes.removeValue(forKey: nodeId)
        nodeModificationTimes.removeValue(forKey: nodeId)
        nodeSyncState.removeValue(forKey: nodeId)
    }
    
    // Update a node's layout properties
    func updateNodeLayoutProps(nodeId: String, props: [String: Any]) {
        guard let node = nodes[nodeId] else {
            print("Cannot update layout: node not found for ID \(nodeId)")
            
            // NEW: Track sync issue
            nodeSyncState[nodeId] = false
            return
        }
        
        print("Applying layout props to node \(nodeId): \(props)")
        
        // Process each property
        for (key, value) in props {
            applyLayoutProp(node: node, key: key, value: value)
        }
        

        nodeModificationTimes[nodeId] = Date().timeIntervalSince1970
        nodeSyncState[nodeId] = true
        
      
        print("layout props cleaned and recalculated for node \(nodeId) and with props \(props)")
    }
    
    

    
    // ENHANCED: Calculate and apply layout in one call with better performance monitoring
    func calculateAndApplyLayout(width: CGFloat, height: CGFloat) -> Bool {
        print("🚀 Complete layout calculation and application started for dimensions: \(width)×\(height)")
        
        let startTime = Date().timeIntervalSince1970
        
        // CRITICAL FIX: Make sure root node exists before proceeding
        guard let root = nodes["root"] else {
            print("⚠️ ERROR: Root node not found. Cannot calculate layout")
            return false
        }
        
//        // CRITICAL DEBUGGING: Print node hierarchy before calculation
//        print("📊 Node hierarchy before calculation:")
//        printNodeHierarchy()
        
        // CRITICAL FIX: Reset any cached layout data to ensure fresh calculation
        YGNodeCalculateLayout(root, Float.nan, Float.nan, YGDirection.LTR)
        
        // CRITICAL FIX: Set proper width and height on root
        YGNodeStyleSetWidth(root, Float(width))
        YGNodeStyleSetHeight(root, Float(height))
        
        print("📏 ROOT NODE DIMENSIONS SET: \(width)×\(height)")
        
        // Calculate layout with proper dimensions
        YGNodeCalculateLayout(root, Float(width), Float(height), YGDirection.LTR)
        
        // DEBUG: Check what the calculated root layout is
        let rootWidth = YGNodeLayoutGetWidth(root)
        let rootHeight = YGNodeLayoutGetHeight(root)
        print("📐 ROOT LAYOUT CALCULATED: \(rootWidth)×\(rootHeight)")
        
        // CRITICAL FIX: Force immediate application of layout to all views in a specific order
        // Starting from root which must exist
        let allNodeIds = nodes.keys.sorted()
        
        print("🔄 Applying layout to \(allNodeIds.count) nodes...")
        
        // CRITICAL FIX: Process nodes in parent-first order to ensure proper positioning
        var processedNodes = Set<String>()
        
        // First apply to root node
        if let rootLayout = getNodeLayout(nodeId: "root") {
            applyLayoutToView(viewId: "root", frame: rootLayout)
            processedNodes.insert("root")
            print("✅ Applied layout to root: \(rootLayout)")
        }
        
        // Process remaining nodes in parent-child order
        // This ensures parents are positioned before children
        var nodesToProcess = ["root"]
        while !nodesToProcess.isEmpty {
            let parentId = nodesToProcess.removeFirst()
            processedNodes.insert(parentId)
            
            // Find all direct children of this parent
            for (childId, currentParentId) in nodeParents where currentParentId == parentId {
                if !processedNodes.contains(childId) {
                    if let layout = getNodeLayout(nodeId: childId) {
                        applyLayoutToView(viewId: childId, frame: layout)
                        processedNodes.insert(childId)
                        print("✅ Applied layout to child \(childId) of \(parentId): \(layout)")
                    }
                    nodesToProcess.append(childId)
                }
            }
        }
    
       
        let endTime = Date().timeIntervalSince1970
        let duration = endTime - startTime
        
        print("✅ Complete layout calculation and application finished in \(String(format: "%.2f", duration * 1000))ms")
        
        return true
    }
    

    func getNodeLayout(nodeId: String) -> CGRect? {
        guard let node = nodes[nodeId] else { return nil }
        
        // Get layout values
        let left = CGFloat(YGNodeLayoutGetLeft(node))
        let top = CGFloat(YGNodeLayoutGetTop(node))
        let width = CGFloat(YGNodeLayoutGetWidth(node))
        let height = CGFloat(YGNodeLayoutGetHeight(node))
        
        return CGRect(x: left, y: top, width: width, height: height)
    }
    
    // Apply a layout property to a node - ENHANCED percentage handling
    private func applyLayoutProp(node: YGNodeRef, key: String, value: Any) {
        switch key {
        case "width":
            if let width = convertToFloat(value) {
                YGNodeStyleSetWidth(node, width)
            } else if let strValue = value as? String, strValue.hasSuffix("%"),
                     let percentValue = Float(strValue.dropLast()) {
                // Directly use Yoga's percentage API
                YGNodeStyleSetWidthPercent(node, percentValue)
                
                // We can still track this for debugging if needed
                if let viewId = getViewIdForNode(node),
                   let view = DCFLayoutManager.shared.getView(withId: viewId) {
                    view.accessibilityLabel = "width:\(percentValue)%"
                }
            }
        case "height":
            if let height = convertToFloat(value) {
                YGNodeStyleSetHeight(node, height)
            } else if let strValue = value as? String, strValue.hasSuffix("%"),
                     let percentValue = Float(strValue.dropLast()) {
                // Directly use Yoga's percentage API
                YGNodeStyleSetHeightPercent(node, percentValue)
                
                // We can still track this for debugging if needed
                if let viewId = getViewIdForNode(node),
                   let view = DCFLayoutManager.shared.getView(withId: viewId) {
                    view.accessibilityLabel = "height:\(percentValue)%"
                }
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
            // Unknown property - log for debugging
            print("⚠️ Unknown layout property: \(key) with value: \(value)")
        }
    }
    
    // NEW: Add helper to find view ID for a node
    private func getViewIdForNode(_ node: YGNodeRef) -> String? {
        return nodes.first(where: { $0.value == node })?.key
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

    // Set a custom measure function for nodes that need to self-measure
    func setCustomMeasureFunction(nodeId: String, measureFunc: @escaping YGMeasureFunc) {
        guard let node = nodes[nodeId] else { return }
        
        // Make sure node has no children before setting measure function
        if YGNodeGetChildCount(node) == 0 {
            YGNodeSetMeasureFunc(node, measureFunc)
        }
    }
    
    // Add debugging method to print the node hierarchy
    func printNodeHierarchy(startingAt nodeId: String = "root", depth: Int = 0) {
        guard let node = nodes[nodeId] else {
            print("Node not found: \(nodeId)")
            return
        }
        
        let indent = String(repeating: "  ", count: depth)
        print("\(indent)Node: \(nodeId) - Type: \(nodeTypes[nodeId] ?? "unknown") - Children: \(YGNodeGetChildCount(node))")
        
        // Find children of this node
        let childNodeIds = nodeParents.filter { $0.value == nodeId }.map { $0.key }
        for childId in childNodeIds {
            printNodeHierarchy(startingAt: childId, depth: depth + 1)
        }
    }
    
    // NEW: Validate and repair node hierarchy
    func validateAndRepairHierarchy(nodeTree: [String: Any], rootId: String) -> (
        success: Bool,
        errorMessage: String?,
        nodesChecked: Int,
        nodesMismatched: Int,
        nodesRepaired: Int
    ) {
        print("🔍 Validating node hierarchy from root: \(rootId)")
        
        var nodesChecked = 0
        var nodesMismatched = 0
        var nodesRepaired = 0
        
        // First check if root exists
        guard nodes[rootId] != nil else {
            return (false, "Root node \(rootId) doesn't exist", 0, 0, 0)
        }
        
        guard let expectedChildren = nodeTree["children"] as? [[String: Any]] else {
            return (false, "Invalid node tree format", 0, 0, 0)
        }
        
        // Process the hierarchy
        do {
            let result = try processNodeTreeLevel(
                parentId: rootId,
                expectedChildren: expectedChildren,
                nodesChecked: &nodesChecked,
                nodesMismatched: &nodesMismatched,
                nodesRepaired: &nodesRepaired
            )
            
            if (!result) {
                return (false, "Failed to repair node hierarchy", nodesChecked, nodesMismatched, nodesRepaired)
            }
            
            print("✅ Node hierarchy validated: checked=\(nodesChecked), mismatched=\(nodesMismatched), repaired=\(nodesRepaired)")
            return (true, nil, nodesChecked, nodesMismatched, nodesRepaired)
            
        } catch let error {
            return (false, "Error processing hierarchy: \(error.localizedDescription)", nodesChecked, nodesMismatched, nodesRepaired)
        }
    }
    
    // NEW: Process a level of the node tree
    private func processNodeTreeLevel(
        parentId: String,
        expectedChildren: [[String: Any]],
        nodesChecked: inout Int,
        nodesMismatched: inout Int,
        nodesRepaired: inout Int
    ) throws -> Bool {
        guard let parentNode = nodes[parentId] else {
            print("⚠️ Parent node not found: \(parentId)")
            return false
        }
        
        // Get actual children in the native hierarchy
        let actualChildCount = YGNodeGetChildCount(parentNode)
        var actualChildNodes = [YGNodeRef]()
        
        for i in 0..<actualChildCount {
            actualChildNodes.append(YGNodeGetChild(parentNode, i))
        }
        
        // Get actual child IDs
        var actualChildIds = [String]()
        for (nodeId, node) in nodes where nodeParents[nodeId] == parentId {
            actualChildIds.append(nodeId)
        }
        
        // Expected child IDs from the tree
        let expectedChildIds = expectedChildren.compactMap { $0["id"] as? String }
        
        nodesChecked += 1 + expectedChildIds.count
        
        // Check if children match
        let childrenMatch = (actualChildIds.count == expectedChildIds.count) &&
            actualChildIds.sorted() == expectedChildIds.sorted()
        
        if (!childrenMatch) {
            print("⚠️ Children mismatch for parent \(parentId):")
            print("   Expected: \(expectedChildIds)")
            print("   Actual: \(actualChildIds)")
            
            nodesMismatched += 1
            
            // Try to repair by removing all children and re-adding them
            try repairChildren(
                parentId: parentId,
                expectedChildren: expectedChildren,
                nodesChecked: &nodesChecked,
                nodesMismatched: &nodesMismatched,
                nodesRepaired: &nodesRepaired
            )
        } else {
            // Children match, but check proper order
            for (index, childInfo) in expectedChildren.enumerated() {
                guard let childId = childInfo["id"] as? String,
                      let actualIndex = actualChildIds.firstIndex(of: childId) else {
                    continue
                }
                
                if index != actualIndex {
                    // Child is in wrong position, move it
                    print("🔄 Reordering child \(childId) from position \(actualIndex) to \(index)")
                    nodesMismatched += 1
                    
                    // Handle reordering by removing and re-adding at correct index
                    if let childNode = nodes[childId] {
                        YGNodeRemoveChild(parentNode, childNode)
                        YGNodeInsertChild(parentNode, childNode, index)
                        nodesRepaired += 1
                    }
                }
                
                // Recursively process this child's children
                if let grandchildren = childInfo["children"] as? [[String: Any]] {
                    let success = try processNodeTreeLevel(
                        parentId: childId,
                        expectedChildren: grandchildren,
                        nodesChecked: &nodesChecked,
                        nodesMismatched: &nodesMismatched,
                        nodesRepaired: &nodesRepaired
                    )
                    
                    if !success {
                        print("⚠️ Failed to process grandchildren for \(childId)")
                    }
                }
            }
        }
        
        return true
    }
    
    // NEW: Helper to repair children
    private func repairChildren(
        parentId: String,
        expectedChildren: [[String: Any]],
        nodesChecked: inout Int,
        nodesMismatched: inout Int,
        nodesRepaired: inout Int
    ) throws {
        guard let parentNode = nodes[parentId] else { return }
        
        // Create temporary storage for children to detach and reattach
        var childrenToReattach = [(String, YGNodeRef)]()
        
        // Remove all child references first
        for (childId, parentIdValue) in nodeParents where parentIdValue == parentId {
            if let childNode = nodes[childId] {
                childrenToReattach.append((childId, childNode))
            }
        }
        
        // Detach all children from parent
        for _ in 0..<YGNodeGetChildCount(parentNode) {
            let child = YGNodeGetChild(parentNode, 0)
            YGNodeRemoveChild(parentNode, child)
        }
        
        // Clean parent references
        for (childId, _) in childrenToReattach {
            nodeParents.removeValue(forKey: childId)
        }
        
        // Re-add children in correct order
        for (index, childInfo) in expectedChildren.enumerated() {
            guard let childId = childInfo["id"] as? String else { continue }
            
            // Find the child in our detached list
            if let childIndex = childrenToReattach.firstIndex(where: { $0.0 == childId }) {
                let (_, childNode) = childrenToReattach[childIndex]
                
                // Add back to parent at correct index
                YGNodeInsertChild(parentNode, childNode, index)
                
                // Update parent reference
                nodeParents[childId] = parentId
                
                nodesRepaired += 1
                
                print("🔄 Reattached child \(childId) to parent \(parentId) at index \(index)")
            } else {
                print("⚠️ Expected child \(childId) not found in actual hierarchy")
            }
        }
    }
    
    // NEW: Add debug method to get complete hierarchy as JSON
    func getHierarchyAsJson(startingAt nodeId: String = "root") -> String {
        print("📊 Generating hierarchy JSON from node \(nodeId)")
        
        guard let node = nodes[nodeId] else {
            return "{\"error\": \"Node not found: \(nodeId)\"}"
        }
        
        let hierarchy = buildHierarchyDict(nodeId: nodeId)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: hierarchy, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? "{\"error\": \"JSON encoding failed\"}"
        } catch {
            return "{\"error\": \"JSON serialization failed: \(error.localizedDescription)\"}"
        }
    }
    
    // NEW: Helper to build hierarchy dictionary
    private func buildHierarchyDict(nodeId: String) -> [String: Any] {
        guard let node = nodes[nodeId] else {
            return ["id": nodeId, "error": "Node not found"]
        }
        
        let componentType = nodeTypes[nodeId] ?? "unknown"
        
        // Get parent
        let parentId = nodeParents.first(where: { $0.value == nodeId })?.key
        
        // Get children
        let childNodeIds = nodeParents.filter { $0.value == nodeId }.map { $0.key }
        var children: [[String: Any]] = []
        
        for childId in childNodeIds {
            let childDict = buildHierarchyDict(nodeId: childId)
            children.append(childDict)
        }
        
        // Get layout info
        let layout: [String: Any] = [
            "left": YGNodeLayoutGetLeft(node),
            "top": YGNodeLayoutGetTop(node),
            "width": YGNodeLayoutGetWidth(node),
            "height": YGNodeLayoutGetHeight(node)
        ]
        
        // Build complete node info
        var nodeInfo: [String: Any] = [
            "id": nodeId,
            "type": componentType,
            "layout": layout,
            "children": children
        ]
        
        // Add tracking info
        if let creationTime = nodeCreationTimes[nodeId] {
            nodeInfo["createdAt"] = creationTime
        }
        
        if let modificationTime = nodeModificationTimes[nodeId] {
            nodeInfo["modifiedAt"] = modificationTime
        }
        
        if let syncState = nodeSyncState[nodeId] {
            nodeInfo["inSync"] = syncState
        }
        
        if let parentId = parentId {
            nodeInfo["parent"] = parentId
        }
        
        return nodeInfo
    }
    /// Handle incremental layout updates for specific nodes
    func performIncrementalLayoutUpdate(nodeId: String, props: [String: Any]) -> Bool {
        print("📐 Performing incremental layout update for node: \(nodeId)")
        
        guard let node = nodes[nodeId] else {
            print("⚠️ Cannot perform incremental layout: node not found for ID \(nodeId)")
            return false
        }
        
        // CRITICAL FIX: Don't mark as dirty directly
        // YGNodeMarkDirty(node) - REMOVE THIS LINE
        
        // Apply the updated properties to the node
        for (key, value) in props {
            applyLayoutProp(node: node, key: key, value: value)
        }
        
        // Find the root node for this subtree
        var currentNode = node
        var parentId = nodeParents[nodeId]
        var affectedNodeIds = Set<String>()
        affectedNodeIds.insert(nodeId) // Always include the updated node
        
        // Find all parent nodes up to the root
        while let pId = parentId, let parentNode = nodes[pId] {
            // Mark parent nodes as affected
            affectedNodeIds.insert(pId)
            // Continue upward
            currentNode = parentNode
            parentId = nodeParents[pId]
        }
        
        // Calculate layout for the entire tree (optimization opportunity)
        let screenWidth = YGNodeStyleGetWidth(rootNode!).value
        let screenHeight = YGNodeStyleGetHeight(rootNode!).value
        
        YGNodeCalculateLayout(rootNode!, Float(screenWidth), Float(screenHeight), YGDirection.LTR)
        
        print("🔄 Incremental layout calculated from node \(nodeId) affecting \(affectedNodeIds.count) nodes")
        
        // Apply layout only to affected nodes for performance
        for affectedId in affectedNodeIds {
            if let layout = getNodeLayout(nodeId: affectedId) {
                // Apply layout to the affected view
                DCFLayoutManager.shared.applyLayout(
                    to: affectedId,
                    left: layout.origin.x,
                    top: layout.origin.y,
                    width: layout.width,
                    height: layout.height
                )
                print("🔄 Applied incremental layout to \(affectedId): \(layout)")
            }
        }
        
        // Update modification time
        nodeModificationTimes[nodeId] = Date().timeIntervalSince1970
        
        return true
    }
    
    private func applyLayoutToView(viewId: String, frame: CGRect) {
        // Get the view from the layout manager
        guard let view = DCFLayoutManager.shared.getView(withId: viewId) else {
            print("⚠️ View not found for ID \(viewId) when applying layout")
            return
        }
        
        print("🎯 Applying layout to view \(viewId): \(frame)")
        
        // Apply layout directly using layout manager
        DispatchQueue.main.async {
            DCFLayoutManager.shared.applyLayout(
                to: viewId,
                left: frame.origin.x,
                top: frame.origin.y,
                width: frame.width,
                height: frame.height
            )
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

