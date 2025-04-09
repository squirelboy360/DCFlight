#ifndef DCMAUI_NATIVE_BRIDGE_H
#define DCMAUI_NATIVE_BRIDGE_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Initialize the DCMAUI framework
int8_t dcmaui_initialize(void);

// Create a view with properties
int8_t dcmaui_create_view(const char* view_id, const char* view_type, const char* props_json);

// Update a view's properties
int8_t dcmaui_update_view(const char* view_id, const char* props_json);

// Delete a view
int8_t dcmaui_delete_view(const char* view_id);

// Attach a child view to a parent view
int8_t dcmaui_attach_view(const char* child_id, const char* parent_id, int32_t index);

// Set all children for a view
int8_t dcmaui_set_children(const char* view_id, const char* children_json);

// Apply layout to a view directly (used ONLY for backward compatibility)
int8_t dcmaui_update_view_layout(const char* view_id, float left, float top, float width, float height);

// Measure text
const char* dcmaui_measure_text(const char* view_id, const char* text, const char* attributes_json);

// Calculate layout for the entire UI tree
int8_t dcmaui_calculate_layout(float screen_width, float screen_height);

#ifdef __cplusplus
}
#endif

#endif /* DCMAUI_NATIVE_BRIDGE_H */
