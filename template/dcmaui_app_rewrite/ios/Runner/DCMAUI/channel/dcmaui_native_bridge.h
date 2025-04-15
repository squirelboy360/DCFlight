#ifndef DCMAUI_NATIVE_BRIDGE_H
#define DCMAUI_NATIVE_BRIDGE_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#if defined(__APPLE__)
#define EXPORT __attribute__((visibility("default")))
#else
#define EXPORT
#endif

// Initialize the DCMAUI framework
EXPORT int8_t dcmaui_initialize(void);

// Create a view with properties
EXPORT int8_t dcmaui_create_view(const char* view_id, const char* view_type, const char* props_json);

// Update a view's properties
EXPORT int8_t dcmaui_update_view(const char* view_id, const char* props_json);

// Delete a view
EXPORT int8_t dcmaui_delete_view(const char* view_id);

// Attach a child view to a parent view
EXPORT int8_t dcmaui_attach_view(const char* child_id, const char* parent_id, int32_t index);

// Set all children for a view
EXPORT int8_t dcmaui_set_children(const char* view_id, const char* children_json);

// Measure text
EXPORT const char* dcmaui_measure_text(const char* view_id, const char* text, const char* attributes_json);

// NOTE: Layout operations removed from FFI interface
// They will be handled via method channels instead

#ifdef __cplusplus
}
#endif

#endif /* DCMAUI_NATIVE_BRIDGE_H */
