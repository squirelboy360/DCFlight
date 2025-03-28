#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dcmaui_native_bridge.h"

// Function pointers to Swift implementations
static int8_t (*swift_initialize)() = NULL;
static int8_t (*swift_create_view)(const char*, const char*, const char*) = NULL;
static int8_t (*swift_update_view)(const char*, const char*) = NULL;
static int8_t (*swift_delete_view)(const char*) = NULL;
static int8_t (*swift_attach_view)(const char*, const char*, int32_t) = NULL;
static int8_t (*swift_set_children)(const char*, const char*) = NULL;

// Register Swift implementations - EVENTS REMOVED
void dcmaui_register_swift_functions(
    int8_t (*init)(),
    int8_t (*create)(const char*, const char*, const char*),
    int8_t (*update)(const char*, const char*),
    int8_t (*delete)(const char*),
    int8_t (*attach)(const char*, const char*, int32_t),
    int8_t (*set_children)(const char*, const char*)
) {
    // Store function pointers for UI operations
    swift_initialize = init;
    swift_create_view = create;
    swift_update_view = update;
    swift_delete_view = delete;
    swift_attach_view = attach;
    swift_set_children = set_children;
}

// ========== UI OPERATIONS (HIGH-PERFORMANCE FFI PATH) ==========

// Initialize the native bridge
int8_t dcmaui_initialize() {
    if (swift_initialize) {
        return swift_initialize();
    }
    return 0;
}

// Create a UI element
int8_t dcmaui_create_view(const char* view_id, const char* type, const char* props_json) {
    if (swift_create_view) {
        return swift_create_view(view_id, type, props_json);
    }
    return 0;
}

// Update a UI element's properties
int8_t dcmaui_update_view(const char* view_id, const char* props_json) {
    if (swift_update_view) {
        return swift_update_view(view_id, props_json);
    }
    return 0;
}

// Delete a UI element
int8_t dcmaui_delete_view(const char* view_id) {
    if (swift_delete_view) {
        return swift_delete_view(view_id);
    }
    return 0;
}

// Attach a child UI element to a parent
int8_t dcmaui_attach_view(const char* child_id, const char* parent_id, int32_t index) {
    if (swift_attach_view) {
        return swift_attach_view(child_id, parent_id, index);
    }
    return 0;
}

// Set all children for a UI element
int8_t dcmaui_set_children(const char* view_id, const char* children_json) {
    if (swift_set_children) {
        return swift_set_children(view_id, children_json);
    }
    return 0;
}

