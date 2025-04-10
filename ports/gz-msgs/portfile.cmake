string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
string(REGEX REPLACE "^gz-" "" PACKAGE_NAME "${PORT}")

set(options "")
if(VCPKG_CROSSCOMPILING)
   list(APPEND options
      "-Dgz-msgs${VERSION_MAJOR}_PROTO_GENERATOR_PLUGIN=${CURRENT_HOST_INSTALLED_DIR}/tools/gz-msgs${VERSION_MAJOR}/gz-msgs${VERSION_MAJOR}_protoc_plugin${VCPKG_HOST_EXECUTABLE_SUFFIX}"
      "-Dgz-msgs${VERSION_MAJOR}_PROTOC_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
   )
endif()

vcpkg_find_acquire_program(PYTHON3)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 b96ec15d2ef46eebab6bebb6ffbd8f11b7bd9ed27156e753343603546d49db41afb3cf926b72de7eb9f702c40ad7e029dd3ddfe3e00d6d503cc45c1a0b8761d9
   OPTIONS
      ${options}
      "-DCMAKE_PROJECT_INCLUDE=${CURRENT_PORT_DIR}/cmake-project-include.cmake"
      "-DPython3_EXECUTABLE=${PYTHON3}"
   PATCHES
      remove_ruby.patch
      move_bin_to_tools.patch
      pthread.diff
)

file(GLOB python_files_debug "${CURRENT_PACKAGES_DIR}/debug/bin/${PORT}${VERSION_MAJOR}_*.py")
file(GLOB python_files_release "${CURRENT_PACKAGES_DIR}/bin/${PORT}${VERSION_MAJOR}_*.py")
file(COPY ${python_files_release} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}${VERSION_MAJOR}")
file(REMOVE ${python_files_release} ${python_files_debug})

vcpkg_copy_tools(TOOL_NAMES "${PORT}${VERSION_MAJOR}_protoc_plugin" AUTO_CLEAN
   DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}${VERSION_MAJOR}"
)
