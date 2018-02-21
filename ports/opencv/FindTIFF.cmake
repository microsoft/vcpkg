# Distributed under the OSI-approved BSD 3-Clause License.
#
#.rst:
# FindTIFF
# --------
#
# Find the TIFF library
#
# Imported targets
# ^^^^^^^^^^^^^^^^
#
# This module defines the following imported targets
#
# ``TIFF::TIFF``
#   The TIFF library, if found.
#
# Result variables
# ^^^^^^^^^^^^^^^^
#
# This module will set the following variables in your project:
#
# ``TIFF_FOUND``
#   true if the TIFF headers and libraries were found
#
# ``TIFF_INCLUDE_DIR``
#   the directory containing the TIFF headers
#
# ``TIFF_INCLUDE_DIRS``
#   the directory containing the TIFF headers
#
# ``TIFF_LIBRARIES``
#   TIFF libraries to be linked
#
# Cache variables
# ^^^^^^^^^^^^^^^
#
# The following cache variables may also be set:
#
# ``TIFF_INCLUDE_DIR``
#   the directory containing the TIFF headers
#
# ``TIFF_LIBRARY``
#   the path to the TIFF library

#include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
#include(${CMAKE_CURRENT_LIST_DIR}/SelectLibraryConfigurations.cmake)
include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

if(TIFF_FIND_QUIETLY)
  set(_FIND_LZMA_ARG QUIET)
endif()
find_package(LibLZMA ${_FIND_LZMA_ARG})

find_path(TIFF_INCLUDE_DIR tiff.h)

set(TIFF_NAMES ${TIFF_NAMES} tiff libtiff tiff3 libtiff3)
foreach(name ${TIFF_NAMES})
  list(APPEND TIFF_NAMES_DEBUG "${name}d")
endforeach()

if(NOT TIFF_LIBRARY)
  find_library(TIFF_LIBRARY_RELEASE NAMES ${TIFF_NAMES})
  find_library(TIFF_LIBRARY_DEBUG NAMES ${TIFF_NAMES_DEBUG})
  select_library_configurations(TIFF)
  mark_as_advanced(TIFF_LIBRARY_RELEASE TIFF_LIBRARY_DEBUG)
endif()
unset(TIFF_NAMES)
unset(TIFF_NAMES_DEBUG)

if(TIFF_INCLUDE_DIR AND EXISTS "${TIFF_INCLUDE_DIR}/tiffvers.h")
    file(STRINGS "${TIFF_INCLUDE_DIR}/tiffvers.h" tiff_version_str
         REGEX "^#define[\t ]+TIFFLIB_VERSION_STR[\t ]+\"LIBTIFF, Version .*")

    string(REGEX REPLACE "^#define[\t ]+TIFFLIB_VERSION_STR[\t ]+\"LIBTIFF, Version +([^ \\n]*).*"
           "\\1" TIFF_VERSION_STRING "${tiff_version_str}")
    unset(tiff_version_str)
endif()

FIND_PACKAGE_HANDLE_STANDARD_ARGS(TIFF
                                  REQUIRED_VARS TIFF_LIBRARY TIFF_INCLUDE_DIR
                                  VERSION_VAR TIFF_VERSION_STRING)

if(TIFF_FOUND)
  set(TIFF_LIBRARIES ${TIFF_LIBRARY} ${LIBLZMA_LIBRARY})
  set(TIFF_INCLUDE_DIRS "${TIFF_INCLUDE_DIR}")

  if(NOT TARGET TIFF::TIFF)
    add_library(TIFF::TIFF UNKNOWN IMPORTED)
    if(TIFF_INCLUDE_DIRS)
      set_target_properties(TIFF::TIFF PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${TIFF_INCLUDE_DIRS}"
        INTERFACE_LINK_LIBRARIES ZLIB::ZLIB)
    endif()
    if(EXISTS "${TIFF_LIBRARY}")
      set_target_properties(TIFF::TIFF PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES "C"
        IMPORTED_LOCATION "${TIFF_LIBRARY}")
    endif()
    if(EXISTS "${TIFF_LIBRARY_RELEASE}")
      set_property(TARGET TIFF::TIFF APPEND PROPERTY
        IMPORTED_CONFIGURATIONS RELEASE)
      set_target_properties(TIFF::TIFF PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES_RELEASE "C"
        IMPORTED_LOCATION_RELEASE "${TIFF_LIBRARY_RELEASE}")
    endif()
    if(EXISTS "${TIFF_LIBRARY_DEBUG}")
      set_property(TARGET TIFF::TIFF APPEND PROPERTY
        IMPORTED_CONFIGURATIONS DEBUG)
      set_target_properties(TIFF::TIFF PROPERTIES
        IMPORTED_LINK_INTERFACE_LANGUAGES_DEBUG "C"
        IMPORTED_LOCATION_DEBUG "${TIFF_LIBRARY_DEBUG}")
    endif()
  endif()
endif()

mark_as_advanced(TIFF_INCLUDE_DIR TIFF_LIBRARY)
