# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#.rst:
# FindCURL
# --------
#
# Find the native CURL headers and libraries.
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
#
# This module defines :prop_tgt:`IMPORTED` target ``CURL::libcurl``, if
# curl has been found.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module defines the following variables:
#
# ``CURL_FOUND``
#   True if curl found.
#
# ``CURL_INCLUDE_DIRS``
#   where to find curl/curl.h, etc.
#
# ``CURL_LIBRARIES``
#   List of libraries when using curl.
#
# ``CURL_VERSION_STRING``
#   The version of curl found.

# Look for the header file.
find_path(CURL_INCLUDE_DIR NAMES curl/curl.h)
mark_as_advanced(CURL_INCLUDE_DIR)

if(NOT CURL_LIBRARY)
  # Look for the library (sorted from most current/relevant entry to least).
  find_library(CURL_LIBRARY_RELEASE NAMES
      curl
    # Windows MSVC prebuilts:
      curllib
      libcurl_imp
      curllib_static
    # Windows older "Win32 - MSVC" prebuilts (libcurl.lib, e.g. libcurl-7.15.5-win32-msvc.zip):
      libcurl
  )
  find_library(CURL_LIBRARY_DEBUG NAMES
    # Windows MSVC CMake builds in debug configuration on vcpkg:
      libcurl-d_imp
      libcurl-d
  )
  include(${CMAKE_CURRENT_LIST_DIR}/SelectLibraryConfigurations.cmake)
  select_library_configurations(CURL)
  mark_as_advanced(CURL_LIBRARY_RELEASE CURL_LIBRARY_DEBUG)
endif()

if(CURL_INCLUDE_DIR)
  foreach(_curl_version_header curlver.h curl.h)
    if(EXISTS "${CURL_INCLUDE_DIR}/curl/${_curl_version_header}")
      file(STRINGS "${CURL_INCLUDE_DIR}/curl/${_curl_version_header}" curl_version_str REGEX "^#define[\t ]+LIBCURL_VERSION[\t ]+\".*\"")

      string(REGEX REPLACE "^#define[\t ]+LIBCURL_VERSION[\t ]+\"([^\"]*)\".*" "\\1" CURL_VERSION_STRING "${curl_version_str}")
      unset(curl_version_str)
      break()
    endif()
  endforeach()
endif()

include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(CURL
                                  REQUIRED_VARS CURL_LIBRARY CURL_INCLUDE_DIR
                                  VERSION_VAR CURL_VERSION_STRING)

if(CURL_FOUND)
  set(CURL_LIBRARIES ${CURL_LIBRARY})
  set(CURL_INCLUDE_DIRS ${CURL_INCLUDE_DIR})

  if(NOT TARGET CURL::libcurl)
    add_library(CURL::libcurl UNKNOWN IMPORTED)
    set_target_properties(CURL::libcurl PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${CURL_INCLUDE_DIRS}")

    if(EXISTS "${CURL_LIBRARY}")
      set_property(TARGET CURL::libcurl APPEND PROPERTY
        IMPORTED_LOCATION "${CURL_LIBRARY}")
      set_target_properties(CURL::libcurl PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        INPORTED_LOCATION "${CURL_LIBRARY}")
    endif()
    if(EXISTS "${CURL_LIBRARY_RELEASE}")
      set_property(TARGET CURL::libcurl APPEND PROPERTY
        IMPORTED_CONFIGURATION RELEASE)
      set_target_properties(CURL::libcurl PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        INPORTED_LOCATION_RELEASE "${CURL_LIBRARY_RELEASE}")
    endif()
    if(EXISTS "${CURL_LIBRARY_DEBUG}")
      set_property(TARGET CURL::libcurl APPEND PROPERTY
        IMPORTED_CONFIGURATION DEBUG)
      set_target_properties(CURL::libcurl PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        INPORTED_LOCATION_DEBUG "${CURL_LIBRARY_DEBUG}")
    endif()
  endif()
endif()

mark_as_advanced(CURL_LIBRARY)
