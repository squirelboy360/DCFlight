#include "dcmaui_native_bridge.h"

extern int8_t dcmaui_initialize_impl(void);
extern int8_t dcmaui_create_view_impl(const char* view_id, const char* view_type, const char* props_json);
extern int8_t dcmaui_update_view_impl(const char* view_id, const char* props_json);
extern int8_t dcmaui_delete_view_impl(const char* view_id);
extern int8_t dcmaui_attach_view_impl(const char* child_id, const char* parent_id, int32_t index);
extern int8_t dcmaui_set_children_impl(const char* view_id, const char* children_json);
extern const char* dcmaui_measure_text_impl(const char* view_id, const char* text, const char* attributes_json);

// NOTE: Layout-related functions removed from FFI implementation
//?? They will be handled via method channels instead
//Why? cause method channels dispatch immediately asychronously thread jumping if in the rare possible case the vdom is busy using the synchronous ffi bridge for UI updates, cause UI is of higher priority.
// Implement the C interface functions
int8_t dcmaui_initialize(void) {
    return dcmaui_initialize_impl();
}

int8_t dcmaui_create_view(const char* view_id, const char* view_type, const char* props_json) {
    return dcmaui_create_view_impl(view_id, view_type, props_json);
}

int8_t dcmaui_update_view(const char* view_id, const char* props_json) {
    return dcmaui_update_view_impl(view_id, props_json);
}

int8_t dcmaui_delete_view(const char* view_id) {
    return dcmaui_delete_view_impl(view_id);
}

int8_t dcmaui_attach_view(const char* child_id, const char* parent_id, int32_t index) {
    return dcmaui_attach_view_impl(child_id, parent_id, index);
}

int8_t dcmaui_set_children(const char* view_id, const char* children_json) {
    return dcmaui_set_children_impl(view_id, children_json);
}

const char* dcmaui_measure_text(const char* view_id, const char* text, const char* attributes_json) {
    return dcmaui_measure_text_impl(view_id, text, attributes_json);
}

