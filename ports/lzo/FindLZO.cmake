# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#.rst:
# FindLZO
# --------
#
# Find the native LZO includes and library.
#
# IMPORTED Targets
# ^^^^^^^^^^^^^^^^
#
# This module defines :prop_tgt:`IMPORTED` target ``LZO::LZO``, if
# LZO has been found.
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# This module defines the following variables:
#
# ::
#
#   LZO_INCLUDE_DIRS   - where to find LZO.h, etc.
#   LZO_LIBRARIES      - List of libraries when using LZO.
#   LZO_FOUND          - True if LZO found.
#
# ::
#
#   LZO_VERSION_STRING - The version of LZO found (x.y.z)
#   LZO_VERSION_MAJOR  - The major version of LZO
#   LZO_VERSION_MINOR  - The minor version of LZO
#   LZO_VERSION_PATCH  - The patch version of LZO
#   LZO_VERSION_TWEAK  - The tweak version of LZO
#
# Backward Compatibility
# ^^^^^^^^^^^^^^^^^^^^^^
#
# The following variable are provided for backward compatibility
#
# ::
#
#   LZO_MAJOR_VERSION  - The major version of LZO
#   LZO_MINOR_VERSION  - The minor version of LZO
#   LZO_PATCH_VERSION  - The patch version of LZO
#
# Hints
# ^^^^^
#
# A user may set ``LZO_ROOT`` to a LZO installation root to tell this
# module where to look.

set(_LZO_SEARCHES)

# Search LZO_ROOT first if it is set.
if(LZO_ROOT)
  set(_LZO_SEARCH_ROOT PATHS ${LZO_ROOT} NO_DEFAULT_PATH)
  list(APPEND _LZO_SEARCHES _LZO_SEARCH_ROOT)
endif()

# Normal search.
set(_LZO_SEARCH_NORMAL
  PATHS "[HKEY_LOCAL_MACHINE\\SOFTWARE\\GnuWin32\\lzo;InstallPath]"
        "$ENV{PROGRAMFILES}/lzo"
  )
list(APPEND _LZO_SEARCHES _LZO_SEARCH_NORMAL)

set(LZO_NAMES lzo lzo2 )
set(LZO_NAMES_DEBUG lzod lzod2 )

find_path(LZO_INCLUDE_DIR NAMES lzoconf.h PATH_SUFFIXES lzo)
mark_as_advanced(LZO_INCLUDE_DIR)
message(STATUS "MATCHED : ${LZO_INCLUDE_DIR}")

# Try each search configuration.
if(NOT LZO_INCLUDE_DIR)
    foreach(search ${_LZO_SEARCHES})
        message(STATUS "MATCHED : ${${search}}")
        find_path(LZO_INCLUDE_DIR NAMES lzoconf.h ${${search}} PATH_SUFFIXES include)
    endforeach()
endif()

# Allow LZO_LIBRARY to be set manually, as the location of the zlib library
if(NOT LZO_LIBRARY)
#   foreach(search ${_LZO_SEARCHES})
#     find_library(LZO_LIBRARY_RELEASE NAMES ${LZO_NAMES} ${${search}} PATH_SUFFIXES lib)
#     find_library(LZO_LIBRARY_DEBUG NAMES ${LZO_NAMES_DEBUG} ${${search}} PATH_SUFFIXES lib)
#   endforeach()

  include(SelectLibraryConfigurations)
  select_library_configurations(LZO)

  find_library(LZO_LIBRARY NAMES ${LZO_NAMES} PATH_SUFFIXES lib)

endif()

unset(LZO_NAMES)
unset(LZO_NAMES_DEBUG)

mark_as_advanced(LZO_INCLUDE_DIR)

if(LZO_INCLUDE_DIR AND EXISTS "${LZO_INCLUDE_DIR}/lzoconf.h")
    file(STRINGS "${LZO_INCLUDE_DIR}/lzoconf.h" LZO_H REGEX "^#define LZO_VERSION_STRING \"[^\"]*\"$")

    string(REGEX REPLACE "^.*LZO_VERSION \"([0-9]+).*$" "\\1" LZO_VERSION_MAJOR "${LZO_H}")
    string(REGEX REPLACE "^.*LZO_VERSION \"[0-9]+\\.([0-9]+).*$" "\\1" LZO_VERSION_MINOR  "${LZO_H}")
    string(REGEX REPLACE "^.*LZO_VERSION \"[0-9]+\\.[0-9]+\\.([0-9]+).*$" "\\1" LZO_VERSION_PATCH "${LZO_H}")
    set(LZO_VERSION_STRING "${LZO_VERSION_MAJOR}.${LZO_VERSION_MINOR}.${LZO_VERSION_PATCH}")

    # only append a TWEAK version if it exists:
    set(LZO_VERSION_TWEAK "")
    if( "${LZO_H}" MATCHES "LZO_VERSION \"[0-9]+\\.[0-9]+\\.[0-9]+\\.([0-9]+)")
        set(LZO_VERSION_TWEAK "${CMAKE_MATCH_1}")
        string(APPEND LZO_VERSION_STRING ".${LZO_VERSION_TWEAK}")
    endif()

    set(LZO_MAJOR_VERSION "${LZO_VERSION_MAJOR}")
    set(LZO_MINOR_VERSION "${LZO_VERSION_MINOR}")
    set(LZO_PATCH_VERSION "${LZO_VERSION_PATCH}")
endif()

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LZO REQUIRED_VARS LZO_LIBRARY LZO_INCLUDE_DIR
                                  VERSION_VAR LZO_VERSION_STRING)

if(LZO_FOUND)
    set(LZO_INCLUDE_DIRS ${LZO_INCLUDE_DIR})

    if(NOT LZO_LIBRARIES)
      set(LZO_LIBRARIES ${LZO_LIBRARY})
    endif()

    if(NOT TARGET LZO::LZO)
      add_library(LZO::LZO UNKNOWN IMPORTED)
      set_target_properties(LZO::LZO PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${LZO_INCLUDE_DIRS}")

      if(LZO_LIBRARY_RELEASE)
        set_property(TARGET LZO::LZO APPEND PROPERTY
          IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(LZO::LZO PROPERTIES
          IMPORTED_LOCATION_RELEASE "${LZO_LIBRARY_RELEASE}")
      endif()

      if(LZO_LIBRARY_DEBUG)
        set_property(TARGET LZO::LZO APPEND PROPERTY
          IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(LZO::LZO PROPERTIES
          IMPORTED_LOCATION_DEBUG "${LZO_LIBRARY_DEBUG}")
      endif()

      if(NOT LZO_LIBRARY_RELEASE AND NOT LZO_LIBRARY_DEBUG)
        set_property(TARGET LZO::LZO APPEND PROPERTY
          IMPORTED_LOCATION "${LZO_LIBRARY}")
      endif()
    endif()
endif()