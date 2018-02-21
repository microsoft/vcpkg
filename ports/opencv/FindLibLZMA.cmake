# Distributed under the OSI-approved BSD 3-Clause License.
#
#.rst:
# FindLibLZMA
# -----------
#
# Find LibLZMA
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# The following variables will be defined:
#
#   ``LIBLZMA_FOUND``
#     True if LibLZMA found on local system
#
#   ``LIBLZMA_INCLUDE_DIRS``
#     Location of LibLZMA header files
#
#   ``LIBLZMA_LIBRARIES``
#     List of LibLZMA libraries
#
# Hints
# ^^^^^
#
#   ``LIBLZMA_ROOT``
#     Set this variable to a directory that contains a LibLZMA installation
#
#

#include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
#include(${CMAKE_CURRENT_LIST_DIR}/SelectLibraryConfigurations.cmake)
include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

# If the user has provided ``LIBLZMA_ROOT``, use it!  Choose items found
# at this location over system locations.
if( EXISTS "$ENV{LIBLZMA_ROOT}" )
  file( TO_CMAKE_PATH "$ENV{LIBLZMA_ROOT}" LIBLZMA_ROOT )
  set( LIBLZMA_ROOT "${LIBLZMA_ROOT}" CACHE PATH "Prefix for LibLZMA installation." )
elseif(EXISTS "$ENV{LIBLZMA_DIR}" )
  file( TO_CMAKE_PATH "$ENV{LIBLZMA_DIR}" LIBLZMA_ROOT )
  set( LIBLZMA_ROOT "${LIBLZMA_ROOT}" CACHE PATH "Prefix for LibLZMA installation." )
endif()

if(NOT LIBLZMA_INCLUDE_DIR)
  find_path(LIBLZMA_INCLUDE_DIR NAMES lzma.h PATHS ${LIBLZMA_ROOT}/include ${LIBLZMA_INCLUDE_DIRS} PATH_SUFFIXES lzma Release Debug)
endif()

if(NOT LIBLZMA_LIBRARY)
  find_library(LIBLZMA_LIBRARY_RELEASE NAMES lzma PATHS ${LIBLZMA_ROOT} PATH_SUFFIXES lzma )
  find_library(LIBLZMA_LIBRARY_DEBUG NAMES lzmad PATHS ${LIBLZMA_ROOT} PATH_SUFFIXES debug lzma lzma/debug debug/lzma)
  select_library_configurations(LIBLZMA)
endif()

set(LIBLZMA_LIBRARIES ${LIBLZMA_LIBRARY})
set(LIBLZMA_INCLUDE_DIRS ${LIBLZMA_INCLUDE_DIR})

FIND_PACKAGE_HANDLE_STANDARD_ARGS(LIBLZMA REQUIRED_VARS LIBLZMA_INCLUDE_DIR LIBLZMA_LIBRARY)
