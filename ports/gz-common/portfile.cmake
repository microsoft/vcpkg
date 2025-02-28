string(REGEX MATCH "^[1-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 40db4747db743005d7c43ca25cfe93cf68ee19201abcb165e72de37708b92fd88553b11520c420db33b37f4cab7e01e4d79c91c5dc0485146b7156284b8baaee
   OPTIONS 
      -DBUILD_TESTING=OFF
      -DUSE_EXTERNAL_TINYXML2=ON
      "-DPKG_CONFIG_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf${VCPKG_HOST_EXECUTABLE_SUFFIX}"
   PATCHES
      gz_remotery_vis.patch
      003-include-chrono.patch
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
