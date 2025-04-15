//
//  dcmaui_native_bridge_impl.swift
//  Runner
//
//  Created by Tahiru Agbanwa on 4/15/25.
//

@_cdecl("dcmaui_initialize_impl")
public func dcmaui_initialize_impl() -> Int8 {
    return DCMauiFFIBridge.shared.initialize() ? 1 : 0
}

@_cdecl("dcmaui_create_view_impl")
public func dcmaui_create_view_impl(
    view_id: UnsafePointer<CChar>,
    view_type: UnsafePointer<CChar>,
    props_json: UnsafePointer<CChar>
) -> Int8 {
    let viewId = String(cString: view_id)
    let viewType = String(cString: view_type)
    let propsJson = String(cString: props_json)
    
    // Make sure UI operations are on the main thread
    if Thread.isMainThread {
        return DCMauiFFIBridge.shared.createView(viewId: viewId, viewType: viewType, propsJson: propsJson) ? 1 : 0
    } else {
        // Use a semaphore to wait for the main thread
        let semaphore = DispatchSemaphore(value: 0)
        var result = false
        
        DispatchQueue.main.async {
            result = DCMauiFFIBridge.shared.createView(viewId: viewId, viewType: viewType, propsJson: propsJson)
            semaphore.signal()
        }
        
        semaphore.wait()
        return result ? 1 : 0
    }
}

@_cdecl("dcmaui_update_view_impl")
public func dcmaui_update_view_impl(
    view_id: UnsafePointer<CChar>,
    props_json: UnsafePointer<CChar>
) -> Int8 {
    let viewId = String(cString: view_id)
    let propsJson = String(cString: props_json)
    
    if Thread.isMainThread {
        return DCMauiFFIBridge.shared.updateView(viewId: viewId, propsJson: propsJson) ? 1 : 0
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        var result = false
        
        DispatchQueue.main.async {
            result = DCMauiFFIBridge.shared.updateView(viewId: viewId, propsJson: propsJson)
            semaphore.signal()
        }
        
        semaphore.wait()
        return result ? 1 : 0
    }
}

@_cdecl("dcmaui_delete_view_impl")
public func dcmaui_delete_view_impl(view_id: UnsafePointer<CChar>) -> Int8 {
    let viewId = String(cString: view_id)
    
    if Thread.isMainThread {
        return DCMauiFFIBridge.shared.deleteView(viewId: viewId) ? 1 : 0
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        var result = false
        
        DispatchQueue.main.async {
            result = DCMauiFFIBridge.shared.deleteView(viewId: viewId)
            semaphore.signal()
        }
        
        semaphore.wait()
        return result ? 1 : 0
    }
}

@_cdecl("dcmaui_attach_view_impl")
public func dcmaui_attach_view_impl(
    child_id: UnsafePointer<CChar>,
    parent_id: UnsafePointer<CChar>,
    index: Int32
) -> Int8 {
    let childId = String(cString: child_id)
    let parentId = String(cString: parent_id)
    
    if Thread.isMainThread {
        return DCMauiFFIBridge.shared.attachView(childId: childId, parentId: parentId, index: Int(index)) ? 1 : 0
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        var result = false
        
        DispatchQueue.main.async {
            result = DCMauiFFIBridge.shared.attachView(childId: childId, parentId: parentId, index: Int(index))
            semaphore.signal()
        }
        
        semaphore.wait()
        return result ? 1 : 0
    }
}

@_cdecl("dcmaui_set_children_impl")
public func dcmaui_set_children_impl(
    view_id: UnsafePointer<CChar>,
    children_json: UnsafePointer<CChar>
) -> Int8 {
    let viewId = String(cString: view_id)
    let childrenJson = String(cString: children_json)
    
    if Thread.isMainThread {
        return DCMauiFFIBridge.shared.setChildren(viewId: viewId, childrenJson: childrenJson) ? 1 : 0
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        var result = false
        
        DispatchQueue.main.async {
            result = DCMauiFFIBridge.shared.setChildren(viewId: viewId, childrenJson: childrenJson)
            semaphore.signal()
        }
        
        semaphore.wait()
        return result ? 1 : 0
    }
}

@_cdecl("dcmaui_update_view_layout_impl")
public func dcmaui_update_view_layout_impl(
    view_id: UnsafePointer<CChar>,
    left: Float,
    top: Float,
    width: Float,
    height: Float
) -> Int8 {
    let viewId = String(cString: view_id)
    
    if Thread.isMainThread {
        return DCMauiFFIBridge.shared.updateViewLayout(viewId: viewId, left: left, top: top, width: width, height: height) ? 1 : 0
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        var result = false
        
        DispatchQueue.main.async {
            result = DCMauiFFIBridge.shared.updateViewLayout(viewId: viewId, left: left, top: top, width: width, height: height)
            semaphore.signal()
        }
        
        semaphore.wait()
        return result ? 1 : 0
    }
}

@_cdecl("dcmaui_measure_text_impl")
public func dcmaui_measure_text_impl(
    view_id: UnsafePointer<CChar>,
    text: UnsafePointer<CChar>,
    attributes_json: UnsafePointer<CChar>
) -> UnsafePointer<CChar> {
    let viewId = String(cString: view_id)
    let textString = String(cString: text)
    let attributesJson = String(cString: attributes_json)
    
    let result: String
    
    if Thread.isMainThread {
        result = DCMauiFFIBridge.shared.measureText(viewId: viewId, text: textString, attributesJson: attributesJson)
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        var tempResult = ""
        
        DispatchQueue.main.async {
            tempResult = DCMauiFFIBridge.shared.measureText(viewId: viewId, text: textString, attributesJson: attributesJson)
            semaphore.signal()
        }
        
        semaphore.wait()
        result = tempResult
    }
    
    // Convert to C string
    let resultCStr = strdup(result)
    return UnsafePointer(resultCStr!)
}

@_cdecl("dcmaui_calculate_layout_impl")
public func dcmaui_calculate_layout_impl(
    screen_width: Float,
    screen_height: Float
) -> Int8 {
    print("🚀 DCMauiFFIBridge: calculateLayout called via FFI with dimensions: \(screen_width)x\(screen_height)")
    
    if Thread.isMainThread {
        // CRITICAL FIX: Added detailed logging and immediate layout application
        do {
            // CRITICAL FIX: Calculate layout and force apply immediately
            let success = YogaShadowTree.shared.calculateAndApplyLayout(
                width: CGFloat(screen_width),
                height: CGFloat(screen_height)
            )
            print("🔢 DCMauiFFIBridge: calculateLayout result: \(success)")
            
            // CRITICAL DEBUG: Force layout on view hierarchy
            if let rootView = DCMauiFFIBridge.shared.views["root"] {
                rootView.setNeedsLayout()
                rootView.layoutIfNeeded()
                
                // Force layout on immediate children
                for subview in rootView.subviews {
                    subview.setNeedsLayout()
                    subview.layoutIfNeeded()
                }
            }
            
            return success ? 1 : 0
        } catch {
            print("❌ DCMauiFFIBridge: calculateLayout error: \(error)")
            return 0
        }
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        var result = false
        
        // CRITICAL FIX: Use sync instead of async for immediate results
        DispatchQueue.main.sync {
            do {
                result = YogaShadowTree.shared.calculateAndApplyLayout(
                    width:  CGFloat(screen_width),
                    height: CGFloat(screen_height)
                )
                semaphore.signal()
            } catch {
                print("❌ DCMauiFFIBridge: calculateLayout error on main thread: \(error)")
                semaphore.signal()
            }
        }
        
        semaphore.wait()
        return result ? 1 : 0
    }
}

@_cdecl("dcmaui_sync_node_hierarchy_impl")
public func dcmaui_sync_node_hierarchy_impl(
    root_id: UnsafePointer<CChar>,
    node_tree_json: UnsafePointer<CChar>
) -> UnsafePointer<CChar> {
    let rootId = String(cString: root_id)
    let nodeTreeJson = String(cString: node_tree_json)
    
    let result: String
    
    if Thread.isMainThread {
        result = DCMauiFFIBridge.shared.syncNodeHierarchy(rootId: rootId, nodeTreeJson: nodeTreeJson)
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        var tempResult = ""
        
        DispatchQueue.main.async {
            tempResult = DCMauiFFIBridge.shared.syncNodeHierarchy(rootId: rootId, nodeTreeJson: nodeTreeJson)
            semaphore.signal()
        }
        
        semaphore.wait()
        result = tempResult
    }
    
    // Convert to C string
    let resultCStr = strdup(result)
    return UnsafePointer(resultCStr!)
}

@_cdecl("dcmaui_get_node_hierarchy_impl")
public func dcmaui_get_node_hierarchy_impl(
    node_id: UnsafePointer<CChar>
) -> UnsafePointer<CChar> {
    let nodeId = String(cString: node_id)
    
    let hierarchyJson: String
    
    if Thread.isMainThread {
        hierarchyJson = DCMauiFFIBridge.shared.getNodeHierarchy(nodeId: nodeId)
    } else {
        let semaphore = DispatchSemaphore(value: 0)
        var tempResult = ""
        
        DispatchQueue.main.async {
            tempResult = DCMauiFFIBridge.shared.getNodeHierarchy(nodeId: nodeId)
            semaphore.signal()
        }
        
        semaphore.wait()
        hierarchyJson = tempResult
    }
    
    // Convert to C string that can be returned to Dart
    let resultCStr = strdup(hierarchyJson)
    return UnsafePointer(resultCStr!)
}
