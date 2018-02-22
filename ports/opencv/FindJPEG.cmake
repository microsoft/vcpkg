#
#.rst:
# FindJPEG
# --------
#
# Find JPEG
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# The following variables will be defined:
#
#   ``JPEG_FOUND``
#     True if JPEG found on local system
#
#   ``JPEG_INCLUDE_DIR``
#     Location of JPEG header files
#
#   ``JPEG_LIBRARY_DIR``
#     Location of JPEG libraries
#
#   ``JPEG_LIBRARY``
#     List of JPEG libraries
#
# Hints
# ^^^^^
#
#   ``JPEG_ROOT``
#     Set this variable to a directory that contains a JPEG installation
#
#

#include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
#include(${CMAKE_CURRENT_LIST_DIR}/SelectLibraryConfigurations.cmake)
include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

# If the user has provided ``JPEG_ROOT``, use it!  Choose items found
# at this location over system locations.
if( EXISTS "$ENV{JPEG_ROOT}" )
  file( TO_CMAKE_PATH "$ENV{JPEG_ROOT}" JPEG_ROOT )
  set( JPEG_ROOT "${JPEG_ROOT}" CACHE PATH "Prefix for JPEG installation." )
elseif(EXISTS "$ENV{JPEG_DIR}" )
  file( TO_CMAKE_PATH "$ENV{JPEG_DIR}" JPEG_ROOT )
  set( JPEG_ROOT "${JPEG_ROOT}" CACHE PATH "Prefix for JPEG installation." )
endif()

if(NOT JPEG_INCLUDE_DIR)
  find_path(JPEG_INCLUDE_DIR NAMES jpeglib.h jpeg.h PATHS ${JPEG_ROOT}/include ${JPEG_INCLUDE_DIRS} PATH_SUFFIXES jpeg Release Debug)
endif()

if(NOT JPEG_LIBRARY)
  find_library(JPEG_LIBRARY_RELEASE NAMES jpeg libjpeg PATHS ${JPEG_ROOT} PATH_SUFFIXES jpeg )
  find_library(JPEG_LIBRARY_DEBUG NAMES jpegd libjpegd PATHS ${JPEG_ROOT} PATH_SUFFIXES debug jpeg jpeg/debug debug/jpeg)
  select_library_configurations(JPEG)
endif()

set(JPEG_LIBRARIES ${JPEG_LIBRARY})

find_package_handle_standard_args(JPEG REQUIRED_VARS JPEG_LIBRARY JPEG_INCLUDE_DIR)
