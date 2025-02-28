string(REGEX MATCH "^[0-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 32be36f3b2d6e34b58ec43af05463c0074f84091378ce521b88b3eb795c6ee31a3d3159817fb28aaaf8fce5660aa5278be0c480481517c1ef41cae0979b6c324
   OPTIONS 
      -DBUILD_TESTING=OFF
      -DUSE_EXTERNAL_TINYXML2=ON
      "-DPKG_CONFIG_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf${VCPKG_HOST_EXECUTABLE_SUFFIX}"
   PATCHES
      gz_remotery_vis.patch
      003-include-chrono.patch
      detect_tinyxml.patch
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/${PORT}${VERSION_MAJOR}-graphics/${PORT}${VERSION_MAJOR}-graphics-config.cmake" "find_package(GTS "
"# Ensure that consumers get a pkg-config tool which is needed for GTS
set(PKG_CONFIG_EXECUTABLE \"\${CMAKE_CURRENT_LIST_DIR}/../../../${HOST_TRIPLET}/tools/pkgconf/pkgconf${VCPKG_HOST_EXECUTABLE_SUFFIX}\" CACHE STRING vcpkg)
find_package(GTS "
IGNORE_UNCHANGED)

foreach(component IN ITEMS av events geospatial graphics io profiler testing)
   if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/share/${PORT}${VERSION_MAJOR}-${component}/${PORT}${VERSION_MAJOR}-${component}-config.cmake")
      message(FATAL_ERROR "Failed to install component ${component}. Check configuration logs for missing dependencies.")
   endif()
endforeach()
