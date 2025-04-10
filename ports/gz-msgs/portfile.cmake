string(REGEX MATCH "^[0-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if(VCPKG_TARGET_IS_WINDOWS)
   set(WINDOWS_OPTIONS "-DCMAKE_CXX_FLAGS=/bigobj")
endif()

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 b96ec15d2ef46eebab6bebb6ffbd8f11b7bd9ed27156e753343603546d49db41afb3cf926b72de7eb9f702c40ad7e029dd3ddfe3e00d6d503cc45c1a0b8761d9
   OPTIONS
      ${WINDOWS_OPTIONS}
   PATCHES
      remove_ruby.patch
      move_bin_to_tools.patch
)

file(GLOB BIN_FILES "${CURRENT_PACKAGES_DIR}/bin/${PORT}${VERSION_MAJOR}_*")
file(COPY ${BIN_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/tools/${PORT}${VERSION_MAJOR})
file(REMOVE_RECURSE ${BIN_FILES})

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
   file(GLOB BIN_FILES "${CURRENT_PACKAGES_DIR}/debug/bin/${PORT}${VERSION_MAJOR}_*")
   file(REMOVE_RECURSE ${BIN_FILES})   
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}${VERSION_MAJOR}")
