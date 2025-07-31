string(REGEX MATCH "^[0-9]+" VERSION_MAJOR ${VERSION})
set(PACKAGE_NAME gazebo)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 4ac9debe27a41233c7c2116bd80f277ebe74f4ae639f06555cec4209bb7af6fe741197705fac222b4e00c8493daaf701b1eefee4ff639fdea70703bed80e0f8a
   OPTIONS
      -DSKIP_PYBIND11=ON
      "-DPython3_EXECUTABLE=${PYTHON3}"
      "-DCMAKE_PROJECT_INCLUDE=${CURRENT_PORT_DIR}/cmake-project-include.cmake"
   PATCHES
      dependencies.patch
)

IF(EXISTS "${CURRENT_PACKAGES_DIR}/lib/${PORT}-${VERSION_MAJOR}/")
   file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/plugins")
   file(RENAME "${CURRENT_PACKAGES_DIR}/lib/${PORT}-${VERSION_MAJOR}/" "${CURRENT_PACKAGES_DIR}/plugins/${PORT}-${VERSION_MAJOR}/")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}-${VERSION_MAJOR}/")
   file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/plugins")
   file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}-${VERSION_MAJOR}/" "${CURRENT_PACKAGES_DIR}/debug/plugins/${PORT}-${VERSION_MAJOR}/")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
   file(GLOB BIN_DLLS "${CURRENT_PACKAGES_DIR}/lib/${PORT}${VERSION_MAJOR}-*.dll")
   file(GLOB BIN_DEBUG_DLLS "${CURRENT_PACKAGES_DIR}/debug/lib/${PORT}${VERSION_MAJOR}-*.dll")

   file(COPY ${BIN_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/bin/")
   file(COPY ${BIN_DEBUG_DLLS} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin/")

   file(REMOVE_RECURSE ${BIN_DLLS} ${BIN_DEBUG_DLLS})
endif()
