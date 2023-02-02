file(GLOB UPB_PLUGINS "${_IMPORT_PREFIX}/../@HOST_TRIPLET@/tools/upb/protoc-gen-upb*")

foreach(PLUGIN ${UPB_PLUGINS})
  get_filename_component(PLUGIN_NAME "${PLUGIN}" NAME_WE)
  add_executable(upb::${PLUGIN_NAME} IMPORTED)
  set_property(TARGET upb::${PLUGIN_NAME} APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
  set_target_properties(upb::${PLUGIN_NAME} PROPERTIES
    IMPORTED_LOCATION_RELEASE "${PLUGIN}"
  )
endforeach()
