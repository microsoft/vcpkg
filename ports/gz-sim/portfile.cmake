# This port is not tested in vcpkg's curated registry due to excessive memory consumption
# that cause reliability problems for other customers.
# It must be checked manually after updates.
string(REGEX MATCH "^[0-9]+" VERSION_MAJOR "${VERSION}")
set(PACKAGE_NAME gazebo)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)

ignition_modular_library(
   NAME "${PACKAGE_NAME}"
   REF "${PORT}${VERSION_MAJOR}_${VERSION}"
   VERSION "${VERSION}"
   SHA512 81739e8ec0a954ce2470f3994502bafac8a288bf105d3108b955c7812b3788aa032b17d0e75bd6a2d524fcb0914de9449043af1ef24d21d69374f83b2ede55c6
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
