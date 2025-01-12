set(PACKAGE_NAME msgs)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

if(VCPKG_TARGET_IS_WINDOWS)
   set(BIGOBJ_OPTION "/bigobj")
else()
   set(BIGOBJ_OPTION "-Wa,-mbig-obj")
endif()

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}_${VERSION}
   VERSION ${VERSION}
   SHA512 b96ec15d2ef46eebab6bebb6ffbd8f11b7bd9ed27156e753343603546d49db41afb3cf926b72de7eb9f702c40ad7e029dd3ddfe3e00d6d503cc45c1a0b8761d9
   OPTIONS
      "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS} ${BIGOBJ_OPTION}"
   PATCHES
      remove_ruby.patch
)

file(GLOB BIN_FILES "${CURRENT_PACKAGES_DIR}/bin/gz-msgs11_*")
file(INSTALL ${BIN_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(GLOB BIN_FILES_TO_REMOVE "${CURRENT_PACKAGES_DIR}/bin/gz-msgs11_*" "${CURRENT_PACKAGES_DIR}/debug/bin/gz-msgs11_*")
file(REMOVE ${BIN_FILES_TO_REMOVE})
