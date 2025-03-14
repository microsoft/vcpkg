string(REGEX MATCH "^[0-9]+" VERSION_MAJOR ${VERSION})
string(REGEX MATCH "^gz-([a-z-]+)" MATCHED_VALUE ${PORT})
set(PACKAGE_NAME ${CMAKE_MATCH_1})

ignition_modular_library(
   NAME ${PACKAGE_NAME}
   REF ${PORT}${VERSION_MAJOR}_${VERSION}
   VERSION ${VERSION}
   SHA512 0c652285b32d2d2f781595416fd80d6e52a6b765ba968d0018accc3688f4ee9d6ce62dbea74b98fa43ea40641c47020246e13645eac7940aa483057c958d3807
   OPTIONS 
      -DBUILD_TESTING=OFF
      "-DPKG_CONFIG_EXECUTABLE=${CURRENT_HOST_INSTALLED_DIR}/tools/pkgconf/pkgconf${VCPKG_HOST_EXECUTABLE_SUFFIX}"
   PATCHES
      gz_remotery_vis.patch
      003-include-chrono.patch
      detect_tinyxml.patch
)

foreach(component IN ITEMS av events geospatial graphics io profiler testing)
   if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/share/${PORT}${VERSION_MAJOR}-${component}/${PORT}${VERSION_MAJOR}-${component}-config.cmake")
      message(FATAL_ERROR "Failed to install component ${component}. Check configuration logs for missing dependencies.")
   endif()
endforeach()
