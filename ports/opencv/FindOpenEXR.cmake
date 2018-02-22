#
#.rst:
# FindOpenEXR
# --------
#
# Find OpenEXR
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# The following variables will be defined:
#
#   ``OPENEXR_FOUND``
#     True if OpenEXR found on local system
#
#   ``OPENEXR_INCLUDE_PATHS``
#     Location of OpenEXR header files
#
#   ``OPENEXR_LIBRARIES``
#     List of OpenEXR libraries
#
# Hints
# ^^^^^
#
#   ``OPENEXR_ROOT``
#     Set this variable to a directory that contains a OpenEXR installation
#
#

#include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
#include(${CMAKE_CURRENT_LIST_DIR}/SelectLibraryConfigurations.cmake)
include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

# If the user has provided ``OPENEXR_ROOT``, use it!  Choose items found
# at this location over system locations.
if( EXISTS "$ENV{OPENEXR_ROOT}" )
  file( TO_CMAKE_PATH "$ENV{OPENEXR_ROOT}" OPENEXR_ROOT )
  set( OPENEXR_ROOT "${OPENEXR_ROOT}" CACHE PATH "Prefix for JPEG installation." )
elseif(EXISTS "$ENV{OPENEXR_DIR}" )
  file( TO_CMAKE_PATH "$ENV{OPENEXR_DIR}" OPENEXR_ROOT )
  set( OPENEXR_ROOT "${OPENEXR_ROOT}" CACHE PATH "Prefix for JPEG installation." )
endif()

if(NOT OPENEXR_INCLUDE_PATHS)
  find_path(OPENEXR_INCLUDE_PATHS NAMES ImfRgbaFile.h PATHS ${OPENEXR_ROOT}/include ${OPENEXR_INCLUDE_PATHS} PATH_SUFFIXES ilmbase openexr Release Debug)
endif()

if(NOT OPENEXR_HALF_LIBRARY)
  find_library(OPENEXR_HALF_LIBRARY_RELEASE NAMES Half half PATHS ${OPENEXR_ROOT} PATH_SUFFIXES ilmbase openexr)
  find_library(OPENEXR_HALF_LIBRARY_DEBUG NAMES Halfd halfd PATHS ${OPENEXR_ROOT} PATH_SUFFIXES debug ilmbase openexr ilmbase/debug openexr/debug debug/ilmbase debug/openexr)
  select_library_configurations(OPENEXR_HALF)
endif()

if(NOT OPENEXR_IEX_LIBRARY)
  find_library(OPENEXR_IEX_LIBRARY_RELEASE NAMES Iex iex PATHS ${OPENEXR_ROOT} PATH_SUFFIXES ilmbase openexr)
  find_library(OPENEXR_IEX_LIBRARY_DEBUG NAMES Iexd iexd PATHS ${OPENEXR_ROOT} PATH_SUFFIXES debug ilmbase openexr ilmbase/debug openexr/debug debug/ilmbase debug/openexr)
  select_library_configurations(OPENEXR_IEX)
endif()

if(NOT OPENEXR_IMATH_LIBRARY)
  find_library(OPENEXR_IMATH_LIBRARY_RELEASE NAMES Imath imath PATHS ${OPENEXR_ROOT} PATH_SUFFIXES ilmbase openexr)
  find_library(OPENEXR_IMATH_LIBRARY_DEBUG NAMES Imathd imathd PATHS ${OPENEXR_ROOT} PATH_SUFFIXES debug ilmbase openexr ilmbase/debug openexr/debug debug/ilmbase debug/openexr)
  select_library_configurations(OPENEXR_IMATH)
endif()

if(NOT OPENEXR_ILMIMF_LIBRARY)
  find_library(OPENEXR_ILMIMF_LIBRARY_RELEASE NAMES IlmImf ilmImf PATHS ${OPENEXR_ROOT} PATH_SUFFIXES ilmbase openexr)
  find_library(OPENEXR_ILMIMF_LIBRARY_DEBUG NAMES IlmImfd ilmImfd PATHS ${OPENEXR_ROOT} PATH_SUFFIXES debug ilmbase openexr ilmbase/debug openexr/debug debug/ilmbase debug/openexr)
  select_library_configurations(OPENEXR_ILMIMF)
endif()

if(NOT OPENEXR_ILMTHREAD_LIBRARY)
  find_library(OPENEXR_ILMTHREAD_LIBRARY_RELEASE NAMES IlmThread ilmThread PATHS ${OPENEXR_ROOT} PATH_SUFFIXES ilmbase openexr)
  find_library(OPENEXR_ILMTHREAD_LIBRARY_DEBUG NAMES IlmThreadd ilmThreadd PATHS ${OPENEXR_ROOT} PATH_SUFFIXES debug ilmbase openexr ilmbase/debug openexr/debug debug/ilmbase debug/openexr)
  select_library_configurations(OPENEXR_ILMTHREAD)
endif()

IF (OPENEXR_INCLUDE_PATHS AND OPENEXR_IMATH_LIBRARY AND OPENEXR_ILMIMF_LIBRARY AND OPENEXR_IEX_LIBRARY AND OPENEXR_HALF_LIBRARY)
    SET(OPENEXR_INCLUDE_PATH ${OPENEXR_INCLUDE_PATHS} CACHE PATH "The include paths needed to use OpenEXR")
    SET(OPENEXR_INCLUDE_DIR ${OPENEXR_INCLUDE_PATHS} CACHE PATH "The include paths needed to use OpenEXR")
    SET(OPENEXR_LIBRARIES ${OPENEXR_IMATH_LIBRARY} ${OPENEXR_ILMIMF_LIBRARY} ${OPENEXR_IEX_LIBRARY} ${OPENEXR_HALF_LIBRARY} ${OPENEXR_ILMTHREAD_LIBRARY} CACHE STRING "The libraries needed to use OpenEXR" FORCE)
ENDIF ()

FIND_PACKAGE_HANDLE_STANDARD_ARGS(OPENEXR REQUIRED_VARS OPENEXR_LIBRARIES OPENEXR_INCLUDE_PATHS)
