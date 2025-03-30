#ifndef DCMAUI_NATIVE_BRIDGE_H
#define DCMAUI_NATIVE_BRIDGE_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Swift implementations with renamed functions to avoid conflicts
extern int8_t dcmaui_initialize_swift_impl(void);
extern int8_t dcmaui_create_view_swift_impl(const char* view_id, const char* view_type, const char* props_json);
extern int8_t dcmaui_update_view_swift_impl(const char* view_id, const char* props_json);
extern int8_t dcmaui_delete_view_swift_impl(const char* view_id);
extern int8_t dcmaui_attach_view_swift_impl(const char* child_id, const char* parent_id, int32_t index);
extern int8_t dcmaui_set_children_swift_impl(const char* view_id, const char* children_ids_json);
extern int8_t dcmaui_update_view_layout_swift_impl(const char* view_id, float left, float top, float width, float height);
extern const char* dcmaui_measure_text_swift_impl(const char* view_id, const char* text, const char* attributes_json);

// C API functions remain the same
int8_t dcmaui_initialize(void);
int8_t dcmaui_create_view(const char* view_id, const char* view_type, const char* props_json);
int8_t dcmaui_update_view(const char* view_id, const char* props_json);
int8_t dcmaui_delete_view(const char* view_id);
int8_t dcmaui_attach_view(const char* child_id, const char* parent_id, int32_t index);
int8_t dcmaui_set_children(const char* view_id, const char* children_ids_json);
int8_t dcmaui_update_view_layout(const char* view_id, float left, float top, float width, float height);
const char* dcmaui_measure_text(const char* view_id, const char* text, const char* attributes_json);

#ifdef __cplusplus
}
#endif

#endif /* dcmaui_native_bridge_h */
