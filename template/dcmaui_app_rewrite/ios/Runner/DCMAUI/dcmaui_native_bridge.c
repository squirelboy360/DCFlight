#include "dcmaui_native_bridge.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// These functions are implemented in Swift through bridging
extern int8_t dcmaui_initialize_swift_impl(void);
extern int8_t dcmaui_create_view_swift_impl(const char* view_id, const char* view_type, const char* props_json);
extern int8_t dcmaui_update_view_swift_impl(const char* view_id, const char* props_json);
extern int8_t dcmaui_delete_view_swift_impl(const char* view_id);
extern int8_t dcmaui_attach_view_swift_impl(const char* child_id, const char* parent_id, int32_t index);
extern int8_t dcmaui_set_children_swift_impl(const char* view_id, const char* children_ids_json);
extern int8_t dcmaui_update_view_layout_swift_impl(const char* view_id, float left, float top, float width, float height);
extern const char* dcmaui_measure_text_swift_impl(const char* view_id, const char* text, const char* attributes_json);

// Initialize the bridge
int8_t dcmaui_initialize(void) {
    return dcmaui_initialize_swift_impl();
}

// Create a view with properties
int8_t dcmaui_create_view(const char* view_id, const char* view_type, const char* props_json) {
    return dcmaui_create_view_swift_impl(view_id, view_type, props_json);
}

// Update a view's properties
int8_t dcmaui_update_view(const char* view_id, const char* props_json) {
    return dcmaui_update_view_swift_impl(view_id, props_json);
}

// Delete a view
int8_t dcmaui_delete_view(const char* view_id) {
    return dcmaui_delete_view_swift_impl(view_id);
}

// Attach a child view to a parent
int8_t dcmaui_attach_view(const char* child_id, const char* parent_id, int32_t index) {
    return dcmaui_attach_view_swift_impl(child_id, parent_id, index);
}

// Set children for a view
int8_t dcmaui_set_children(const char* view_id, const char* children_ids_json) {
    return dcmaui_set_children_swift_impl(view_id, children_ids_json);
}

// Update a view's layout directly
int8_t dcmaui_update_view_layout(const char* view_id, float left, float top, float width, float height) {
    return dcmaui_update_view_layout_swift_impl(view_id, left, top, width, height);
}

// Measure text with given attributes
const char* dcmaui_measure_text(const char* view_id, const char* text, const char* attributes_json) {
    return dcmaui_measure_text_swift_impl(view_id, text, attributes_json);
}

