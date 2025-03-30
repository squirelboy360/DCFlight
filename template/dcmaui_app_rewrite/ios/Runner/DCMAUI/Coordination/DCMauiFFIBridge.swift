import UIKit
import Flutter

// Function declarations for C bridge - renamed to avoid conflicts
@_cdecl("dcmaui_initialize_swift_impl")
public func dcmaui_initialize_swift_impl() -> Int8 {
    return DCMauiNativeBridgeCoordinator.shared.dcmaui_initialize()
}

@_cdecl("dcmaui_create_view_swift_impl")
public func dcmaui_create_view_swift_impl(_ viewId: UnsafePointer<CChar>, 
                                 _ type: UnsafePointer<CChar>,
                                 _ propsJson: UnsafePointer<CChar>) -> Int8 {
    return DCMauiNativeBridgeCoordinator.shared.dcmaui_create_view(viewId, type, propsJson)
}

@_cdecl("dcmaui_update_view_swift_impl")
public func dcmaui_update_view_swift_impl(_ viewId: UnsafePointer<CChar>,
                                 _ propsJson: UnsafePointer<CChar>) -> Int8 {
    return DCMauiNativeBridgeCoordinator.shared.dcmaui_update_view(viewId, propsJson)
}

@_cdecl("dcmaui_delete_view_swift_impl")
public func dcmaui_delete_view_swift_impl(_ viewId: UnsafePointer<CChar>) -> Int8 {
    return DCMauiNativeBridgeCoordinator.shared.dcmaui_delete_view(viewId)
}

@_cdecl("dcmaui_attach_view_swift_impl")
public func dcmaui_attach_view_swift_impl(_ childId: UnsafePointer<CChar>,
                                 _ parentId: UnsafePointer<CChar>,
                                 _ index: Int32) -> Int8 {
    return DCMauiNativeBridgeCoordinator.shared.dcmaui_attach_view(childId, parentId, index)
}

@_cdecl("dcmaui_set_children_swift_impl")
public func dcmaui_set_children_swift_impl(_ viewId: UnsafePointer<CChar>,
                                  _ childrenJson: UnsafePointer<CChar>) -> Int8 {
    return DCMauiNativeBridgeCoordinator.shared.dcmaui_set_children(viewId, childrenJson)
}

@_cdecl("dcmaui_update_view_layout_swift_impl")
public func dcmaui_update_view_layout_swift_impl(_ viewId: UnsafePointer<CChar>, 
                                        _ left: Float, 
                                        _ top: Float, 
                                        _ width: Float, 
                                        _ height: Float) -> Int8 {
    let viewIdString = String(cString: viewId)
    return DCMauiNativeBridgeCoordinator.shared.updateViewLayout(
        viewId: viewIdString,
        left: CGFloat(left),
        top: CGFloat(top),
        width: CGFloat(width),
        height: CGFloat(height)
    ) ? 1 : 0
}

@_cdecl("dcmaui_measure_text_swift_impl")
public func dcmaui_measure_text_swift_impl(_ viewId: UnsafePointer<CChar>, 
                                  _ text: UnsafePointer<CChar>, 
                                  _ attributesJson: UnsafePointer<CChar>) -> UnsafePointer<CChar>? {
    let viewIdString = String(cString: viewId)
    let textString = String(cString: text)
    let attributesJsonString = String(cString: attributesJson)
    
    let result = DCMauiNativeBridgeCoordinator.shared.measureText(
        viewId: viewIdString,
        text: textString,
        attributesJson: attributesJsonString
    )
    
    // Convert result to C string safely
    let resultCString = strdup(result)
    return UnsafePointer(resultCString)
}

// Register Swift FFI functions with C bridge
@_cdecl("dcmaui_register_swift_functions")
public func dcmaui_register_swift_functions(
    _ initialize: @convention(c) () -> Int8,
    _ create_view: @convention(c) (UnsafePointer<CChar>?, UnsafePointer<CChar>?, UnsafePointer<CChar>?) -> Int8,
    _ update_view: @convention(c) (UnsafePointer<CChar>?, UnsafePointer<CChar>?) -> Int8,
    _ delete_view: @convention(c) (UnsafePointer<CChar>?) -> Int8,
    _ attach_view: @convention(c) (UnsafePointer<CChar>?, UnsafePointer<CChar>?, Int32) -> Int8,
    _ set_children: @convention(c) (UnsafePointer<CChar>?, UnsafePointer<CChar>?) -> Int8
) {
    print("Swift FFI functions registered with C bridge")
}
