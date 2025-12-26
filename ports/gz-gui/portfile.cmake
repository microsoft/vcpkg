string(REGEX MATCH "^[0-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 154d8e6149f762d7f32cebde2b41e17b42846b65a643a7216cabde93644ae821d626b10ba3a9faf9fe39c404976489cf726896e3373daf2598177b6738d76545
   OPTIONS 
   PATCHES
      dependencies.patch
)

if(VCPKG_TARGET_IS_WINDOWS)   
   file(GLOB plugins "${CURRENT_PACKAGES_DIR}/lib/${PORT}-${VERSION_MAJOR}/plugins/*.dll")
   if (NOT plugins STREQUAL "")
      file(COPY ${plugins} DESTINATION "${CURRENT_PACKAGES_DIR}/engine-plugins/")
      file(REMOVE ${plugins})
   endif()

   file(GLOB plugins_debug "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}-${VERSION_MAJOR}/plugins/*.dll")
   if (NOT plugins_debug STREQUAL "")
      file(COPY ${plugins_debug} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/engine-plugins/")
      file(REMOVE ${plugins_debug})
   endif()

endif()
