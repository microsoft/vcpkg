if (OpenH264_INCLUDE_DIR)
  set (OPENH264_FIND_QUIETLY TRUE)
endif ()

find_package(PkgConfig QUIET)
pkg_check_modules(OPENH264 QUIET openh264)

set(OPENH264_VERSION OPENH264_VERSION_PLACEHOLDER)

find_path(OPENH264_INCLUDE_DIR wels/codec_api.h
  HINTS ${VCPKG_INSTALLED_DIR}/include
)

find_library(OPENH264_LIBRARY_RELEASE
  NAMES openh264
  HINTS ${CMAKE_CURRENT_LIST_DIR}/../../lib
  NO_DEFAULT_PATH REQUIRED
)

find_library(OPENH264_LIBRARY_DEBUG
  NAMES openh264
  HINTS ${CMAKE_CURRENT_LIST_DIR}/../../debug/lib
  NO_DEFAULT_PATH REQUIRED
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OpenH264 
  REQUIRED_VARS OPENH264_LIBRARY_RELEASE OPENH264_LIBRARY_DEBUG OPENH264_INCLUDE_DIR
  VERSION_VAR OPENH264_VERSION
)

if(OPENH264_FOUND)
  if (NOT TARGET OpenH264::OpenH264)
    add_library (OpenH264::OpenH264 UNKNOWN IMPORTED)
    set_target_properties (OpenH264::OpenH264 PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${OPENH264_INCLUDE_DIR}")
    
    set_target_properties(OpenH264::OpenH264 PROPERTIES IMPORTED_LOCATION_RELEASE "${OPENH264_LIBRARY_RELEASE}")
    set_property(TARGET OpenH264::OpenH264 APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)

    set_target_properties(OpenH264::OpenH264 PROPERTIES IMPORTED_LOCATION_DEBUG "${OPENH264_LIBRARY_DEBUG}")
    set_property(TARGET OpenH264::OpenH264 APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)

  endif()
endif()

mark_as_advanced(OPENH264_INCLUDE_DIR OPENH264_LIBRARY_RELEASE OPENH264_LIBRARY_DEBUG)
