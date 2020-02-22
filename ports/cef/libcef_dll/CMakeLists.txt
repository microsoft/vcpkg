add_library(libcef_dll_wrapper STATIC IMPORTED GLOBAL)
set_target_properties(libcef_dll_wrapper PROPERTIES
  IMPORTED_LOCATION_RELEASE ${CURRENT_PACKAGES_DIR}/lib/libcef_dll_wrapper.lib
  IMPORTED_LOCATION_DEBUG ${CURRENT_PACKAGES_DIR}/debug/lib/libcef_dll_wrapper.lib
)
