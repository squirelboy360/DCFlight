#include "dcmaui_native_bridge.h"

extern int8_t dcmaui_initialize_impl(void);
extern int8_t dcmaui_create_view_impl(const char* view_id, const char* view_type, const char* props_json);
extern int8_t dcmaui_update_view_impl(const char* view_id, const char* props_json);
extern int8_t dcmaui_delete_view_impl(const char* view_id);
extern int8_t dcmaui_attach_view_impl(const char* child_id, const char* parent_id, int32_t index);
extern int8_t dcmaui_set_children_impl(const char* view_id, const char* children_json);
extern int8_t dcmaui_update_view_layout_impl(const char* view_id, float left, float top, float width, float height);
extern const char* dcmaui_measure_text_impl(const char* view_id, const char* text, const char* attributes_json);
extern int8_t dcmaui_calculate_layout_impl(float screen_width, float screen_height);

// Function declarations for Swift implementations
extern const char* dcmaui_sync_node_hierarchy_impl(const char* root_id, const char* node_tree_json);
extern const char* dcmaui_get_node_hierarchy_impl(const char* node_id);

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

int8_t dcmaui_update_view_layout(const char* view_id, float left, float top, float width, float height) {
    return dcmaui_update_view_layout_impl(view_id, left, top, width, height);
}

const char* dcmaui_measure_text(const char* view_id, const char* text, const char* attributes_json) {
    return dcmaui_measure_text_impl(view_id, text, attributes_json);
}

int8_t dcmaui_calculate_layout(float screen_width, float screen_height) {
    return dcmaui_calculate_layout_impl(screen_width, screen_height);
}

const char* dcmaui_sync_node_hierarchy(const char* root_id, const char* node_tree_json) {
    return dcmaui_sync_node_hierarchy_impl(root_id, node_tree_json);
}

const char* dcmaui_get_node_hierarchy(const char* node_id) {
    return dcmaui_get_node_hierarchy_impl(node_id);
}

