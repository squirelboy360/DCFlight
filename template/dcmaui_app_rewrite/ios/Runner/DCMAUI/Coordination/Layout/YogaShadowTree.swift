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
    
    // ADDED: Optimized initialization method
    func optimizedInitialization() {
        print("YogaShadowTree optimized initialization")
        
        // Configure root node with device bounds only, skip other initialization
        if let root = rootNode {
            YGNodeStyleSetDirection(root, YGDirection.LTR)
            YGNodeStyleSetFlexDirection(root, YGFlexDirection.column)
            YGNodeStyleSetWidth(root, Float(UIScreen.main.bounds.width))
            YGNodeStyleSetHeight(root, Float(UIScreen.main.bounds.height))
        }
    }
    
    // Create a new node in the shadow tree
    func createNode(id: String, componentType: String) {
        print("Creating shadow node: \(id) of type \(componentType)")
        
        // Create new node
        let node = YGNodeNew()
        
        // Configure default properties based on component type
        if let node = node {  // Safely unwrap the optional
            configureNodeDefaults(node, forComponentType: componentType)
            
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
        
        // NEW: Update modification time
        nodeModificationTimes[nodeId] = Date().timeIntervalSince1970
        nodeSyncState[nodeId] = true
        
      
        print("layout props cleaned and recalculated for node \(nodeId) and with props \(props)")
    }
    
    

    
    // OPTIMIZED: More efficient layout calculation with less logging
    func calculateAndApplyLayout(width: CGFloat, height: CGFloat) -> Bool {
        print("🚀 Layout calculation with dimensions: \(width)×\(height)")
        
        // CRITICAL FIX: Make sure root node exists before proceeding
        guard let root = nodes["root"] else {
            print("⚠️ ERROR: Root node not found. Cannot calculate layout")
            return false
        }
        
        // Debug the nodes
        print("📊 Total nodes before layout: \(nodes.count)")
        
        // Set proper width and height on root
        YGNodeStyleSetWidth(root, Float(width))
        YGNodeStyleSetHeight(root, Float(height))
        
        // CRITICAL FIX: Use dedicated background queue for layout calculation
        let layoutQueue = DispatchQueue(label: "com.dcmaui.layoutCalculation", qos: .userInitiated)
        let layoutSemaphore = DispatchSemaphore(value: 0)
        
        // Store success state
        var calculationSucceeded = false
        
        // Run layout calculation on background queue
        layoutQueue.async {
            // Calculate layout in background
            YGNodeCalculateLayout(root, Float(width), Float(height), YGDirection.LTR)
            calculationSucceeded = true
            
            print("✅ Layout calculation completed on background thread")
            
            // Signal completion
            layoutSemaphore.signal()
        }
        
        // Wait with timeout for layout calculation to finish
        let waitResult = layoutSemaphore.wait(timeout: .now() + 1.0)
        if waitResult == .timedOut {
            print("⚠️ Layout calculation timed out")
            return false
        }
        
        if !calculationSucceeded {
            print("❌ Layout calculation failed")
            return false
        }
        
        // Apply layout separately on the main thread
        DispatchQueue.main.async {
            // Apply layouts to all views
            for (nodeId, node) in self.nodes {
                // Get layout values from the node
                let left = CGFloat(YGNodeLayoutGetLeft(node))
                let top = CGFloat(YGNodeLayoutGetTop(node))
                let width = CGFloat(YGNodeLayoutGetWidth(node))
                let height = CGFloat(YGNodeLayoutGetHeight(node))
                
                if let view = DCMauiLayoutManager.shared.getView(withId: nodeId) {
                    view.frame = CGRect(x: left, y: top, width: max(1, width), height: max(1, height))
                    view.setNeedsLayout()
                    print("📏 Applied layout to \(nodeId): (\(left), \(top), \(width), \(height))")
                }
            }
        }
        
        return true
    }
    
    // ADD THIS DEBUG METHOD: print full node hierarchy with layout info
    func printNodeHierarchy() {
        print("📋 FULL NODE HIERARCHY:")
        printNodeHierarchyRecursive(nodeId: "root", depth: 0)
    }
    
    private func printNodeHierarchyRecursive(nodeId: String, depth: Int) {
        guard let node = nodes[nodeId] else {
            print("\(String(repeating: "  ", count: depth))❓ Node not found: \(nodeId)")
            return
        }
        
        let indent = String(repeating: "  ", count: depth)
        let layout = getNodeLayout(nodeId: nodeId) ?? CGRect.zero
        let view = DCMauiLayoutManager.shared.getView(withId: nodeId)
        let viewFrame = view?.frame ?? CGRect.zero
        
        print("\(indent)📍 \(nodeId) (\(nodeTypes[nodeId] ?? "unknown"))")
        print("\(indent)   Yoga: \(layout)")
        print("\(indent)   View: \(viewFrame)")
        
        // Print all children
        let childNodeIds = nodeParents.filter { $0.value == nodeId }.map { $0.key }
        for childId in childNodeIds {
            printNodeHierarchyRecursive(nodeId: childId, depth: depth + 1)
        }
    }
    
    // NEW: Enable or disable layout debugging
    func setDebugLayoutEnabled(_ enabled: Bool) {
        debugLayoutEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "DCMauiDebugLayout")
        
        // Apply debug visualization immediately if enabled
        if enabled {
            applyDebugVisualization()
        } else {
            // Remove debug vsualizations
            removeDebugVisualization()
        }
    }
    
    // NEW: Apply debug visualization to all views
    private func applyDebugVisualization() {
        print("🔍 Applying layout debug visualization")
        
        for (nodeId, _) in nodes {
            guard let view = DCMauiLayoutManager.shared.getView(withId: nodeId) else { continue }
            
            // Apply debug border
            DispatchQueue.main.async {
                // Add colorful border to help visualize layout
                view.layer.borderColor = UIColor(
                    hue: CGFloat(nodeId.hashValue % 100) / 100.0,
                    saturation: 0.8,
                    brightness: 0.8,
                    alpha: 1.0
                ).cgColor
                view.layer.borderWidth = 1.0
                
                // Add a debug label with node info
                let label = UILabel()
                label.tag = 99999 // Special tag to identify debug labels
                label.font = UIFont.systemFont(ofSize: 10)
                label.textColor = .white
                label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                label.text = "ID: \(nodeId)\n\(Int(view.frame.width))×\(Int(view.frame.height))"
                label.numberOfLines = 2
                label.textAlignment = .right
                label.layer.cornerRadius = 4
                label.clipsToBounds = true
                
                // Remove existing debug label if any
                view.subviews.forEach { subview in
                    if subview.tag == 99999 { subview.removeFromSuperview() }
                }
                
                // Add label to view
                view.addSubview(label)
                
                // Position label
                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2),
                    label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2),
                    label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
                ])
            }
        }
    }
    
    // NEW: Remove debug visualization from all views
    private func removeDebugVisualization() {
        print("🧹 Removing layout debug visualization")
        
        for (nodeId, _) in nodes {
            guard let view = DCMauiLayoutManager.shared.getView(withId: nodeId) else { continue }
            
            // Remove debug elements
            DispatchQueue.main.async {
                // Remove border
                view.layer.borderWidth = 0
                
                // Remove debug labels
                view.subviews.forEach { subview in
                    if subview.tag == 99999 { subview.removeFromSuperview() }
                }
            }
        }
    }
    
    // NEW: Log performance metrics
    private func logPerformanceMetrics() {
        guard !layoutCalculationTimes.isEmpty else { return }
        
        let avgTime = layoutCalculationTimes.reduce(0, +) / Double(layoutCalculationTimes.count)
        let maxTime = layoutCalculationTimes.max() ?? 0
        
        print("📊 Layout Performance:")
        print("  - Total layouts: \(layoutCount)")
        print("  - Last layout: \(String(format: "%.2f", lastLayoutTime * 1000))ms")
        print("  - Average time: \(String(format: "%.2f", avgTime * 1000))ms")
        print("  - Maximum time: \(String(format: "%.2f", maxTime * 1000))ms")
        print("  - Nodes in tree: \(nodes.count)")
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
                   let view = DCMauiLayoutManager.shared.getView(withId: viewId) {
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
                   let view = DCMauiLayoutManager.shared.getView(withId: viewId) {
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
                DCMauiLayoutManager.shared.applyLayout(
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
    
    // OPTIMIZED: More efficient layout application
    private func applyLayoutToView(viewId: String, node: YGNodeRef) {
        // Get the view from the layout manager
        guard let view = DCMauiLayoutManager.shared.getView(withId: viewId) else {
            return
        }
        
        // Get layout values from the node
        let left = CGFloat(YGNodeLayoutGetLeft(node))
        let top = CGFloat(YGNodeLayoutGetTop(node))
        let width = CGFloat(YGNodeLayoutGetWidth(node))
        let height = CGFloat(YGNodeLayoutGetHeight(node))
        
        // Apply layout directly using layout manager - no animation for better performance
        DispatchQueue.main.async {
            DCMauiLayoutManager.shared.applyLayout(
                to: viewId, 
                left: left, 
                top: top, 
                width: width, 
                height: height,
                animationDuration: 0
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
