#ifndef DCMAUI_NATIVE_BRIDGE_H
#define DCMAUI_NATIVE_BRIDGE_H

#include <stdint.h>

// Register Swift implementations - EVENTS REMOVED FROM FFI INTERFACE
void dcmaui_register_swift_functions(
    int8_t (*init)(),
    int8_t (*create)(const char*, const char*, const char*),
    int8_t (*update)(const char*, const char*),
    int8_t (*delete)(const char*),
    int8_t (*attach)(const char*, const char*, int32_t),
    int8_t (*set_children)(const char*, const char*)
    // Event functions completely removed from FFI
);

// FFI functions - PURE UI OPERATIONS ONLY
// These functions handle high-performance UI rendering via FFI
int8_t dcmaui_initialize();
int8_t dcmaui_create_view(const char* view_id, const char* type, const char* props_json);
int8_t dcmaui_update_view(const char* view_id, const char* props_json);
int8_t dcmaui_delete_view(const char* view_id);
int8_t dcmaui_attach_view(const char* child_id, const char* parent_id, int32_t index);
int8_t dcmaui_set_children(const char* view_id, const char* children_json);

// EVENT HANDLING NOTE:
// All event handling is now done through Flutter method channels exclusively
// for improved performance and reliability. The FFI layer is optimized
// for UI operations only.

#endif // DCMAUI_NATIVE_BRIDGE_H
