#.rst:
# FindFFMPEG
# --------
#
# Find the FFPMEG libraries
# Based on Cenit's orgional FindFFMPEG - https://github.com/Microsoft/vcpkg/blob/205dec5048b89c387d51547415be5dcbe50f10b4/ports/opencv/FindFFMPEG.cmake 
#
# Result Variables
# ^^^^^^^^^^^^^^^^
#
# The following variables will be defined:
#
#  ``FFMPEG_FOUND``
#    True if FFMPEG found on the local system
#
#  ``FFMPEG_INCLUDE_DIRS``
#    Location of FFMPEG header files
#
#  ``FFMPEG_LIBRARY_DIRS``
#    Location of FFMPEG libraries
#
#  ``FFMPEG_LIBRARIES``
#    List of the FFMPEG libraries found
#
# Hints
# ^^^^^
#
#  ``FFMPEG_ROOT``
#    Set this variable to a directory that contains a FFMPEG installation
#
#

#include(${CMAKE_CURRENT_LIST_DIR}/FindPackageHandleStandardArgs.cmake)
#include(${CMAKE_CURRENT_LIST_DIR}/SelectLibraryConfigurations.cmake)
include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

#  Platform dependent libraries required by FFMPEG
if(WIN32)
  if(NOT CYGWIN)
    set( FFMPEG_PLATFORM_DEPENDENT_LIBS wsock32 ws2_32 Secur32 )
  endif()
endif()

# Get FFMPEG_ROOT DIR from build system
find_path(FFMPEG_INCLUDE_DIRS NAMES libavcodec/avcodec.h)
get_filename_component(FFMPEG_ROOT ${FFMPEG_INCLUDE_DIRS} DIRECTORY)

# postproc disabled - for now
set(FFMPEG_LIB_NAMES avutil avcodec avformat avdevice avfilter avresample swscale swresample)


# If the user has provided ``FFMPEG_ROOT``, use it!  Choose items found
# at this location over system locations.
if( EXISTS "$ENV{FFMPEG_ROOT}" )
  file( TO_CMAKE_PATH "$ENV{FFMPEG_ROOT}" FFMPEG_ROOT )
  set( FFMPEG_ROOT "${FFMPEG_ROOT}" CACHE PATH "Prefix for FFMPEG installation." )
elseif(EXISTS "$ENV{FFMPEG_DIR}" )
  file( TO_CMAKE_PATH "$ENV{FFMPEG_DIR}" FFMPEG_ROOT )
  set( FFMPEG_ROOT "${FFMPEG_ROOT}" CACHE PATH "Prefix for FFMPEG installation." )
endif()

macro(FFMPEG_FIND varname shortname headername)
  if(NOT FFMPEG_${varname}_INCLUDE_DIRS)
    find_path(FFMPEG_${varname}_INCLUDE_DIRS NAMES lib${shortname}/${headername} PATHS ${FFMPEG_ROOT}/include ${FFMPEG_INCLUDE_DIRS} PATH_SUFFIXES ffmpeg Release Debug)
  endif()
  if(NOT FFMPEG_${varname}_LIBRARY)
    find_library(FFMPEG_${varname}_LIBRARY_RELEASE NAMES ${shortname} PATHS ${FFMPEG_ROOT} PATH_SUFFIXES lib ffmpeg ffmpeg/lib)
    find_library(FFMPEG_${varname}_LIBRARY_DEBUG NAMES ${shortname} ${shortname}d PATHS debug ${FFMPEG_ROOT}/debug PATH_SUFFIXES debug/lib lib ffmpeg ffmpeg/lib ffmpeg/debug/lib debug/ffmpeg/lib)
    select_library_configurations(FFMPEG_${varname})
  endif()
  if (FFMPEG_${varname}_LIBRARY AND FFMPEG_${varname}_INCLUDE_DIRS)
    set(FFMPEG_${varname}_FOUND 1)
  endif()
endmacro(FFMPEG_FIND)

if(WIN32)
  if(NOT FFMPEG_stdint_INCLUDE_DIRS)
    find_path(FFMPEG_stdint_INCLUDE_DIRS NAMES stdint.h PATHS ${FFMPEG_ROOT}/include ${FFMPEG_INCLUDE_DIRS} PATH_SUFFIXES ffmpeg Release Debug)
  endif()
  if (FFMPEG_stdint_INCLUDE_DIRS)
    set(STDINT_OK TRUE)
  endif()
else()
  set(STDINT_OK TRUE)
endif()

unset(FFMPEG_LIBRARIES)
foreach(FFMPEG_SUBLIBRARY ${FFMPEG_LIB_NAMES})
  FFMPEG_FIND("lib${FFMPEG_SUBLIBRARY}"   ${FFMPEG_SUBLIBRARY}   ${FFMPEG_SUBLIBRARY}.h)
endforeach()

if (STDINT_OK)
  foreach(FFMPEG_SUBLIBRARY ${FFMPEG_LIB_NAMES})
    if(FFMPEG_lib${FFMPEG_SUBLIBRARY}_FOUND)
      list(APPEND FFMPEG_INCLUDE_DIRS ${FFMPEG_lib${FFMPEG_SUBLIBRARY}_INCLUDE_DIRS})
      list(APPEND FFMPEG_LIBRARIES "${FFMPEG_lib${FFMPEG_SUBLIBRARY}_LIBRARY}")
    endif()
  endforeach()

  list(REMOVE_DUPLICATES FFMPEG_INCLUDE_DIRS)

  set(FFMPEG_INCLUDE_DIR ${FFMPEG_libavformat_INCLUDE_DIRS})
  set(FFMPEG_LIBRARY ${FFMPEG_LIBRARIES})
endif()

unset(FFMPEG_STATIC_LIBRARIES)
if(CMAKE_BUILD_TYPE MATCHES DEBUG)
  set(FFMPEG_STATIC_PATH ${FFMPEG_ROOT}/debug/static/lib)
else()
  set(FFMPEG_STATIC_PATH ${FFMPEG_ROOT}/static/lib)
endif()

foreach(FFMPEG_STATIC_SUBLIBRARY ${FFMPEG_LIB_NAMES})
  find_library(FFMPEG_lib${FFMPEG_STATIC_SUBLIBRARY}_STATIC_LIBRARY NAMES ${FFMPEG_STATIC_SUBLIBRARY} PATHS ${FFMPEG_STATIC_PATH} NO_DEFAULT_PATH)
  list(APPEND FFMPEG_STATIC_LIBRARIES ${FFMPEG_lib${FFMPEG_STATIC_SUBLIBRARY}_STATIC_LIBRARY})
endforeach()

list(APPEND FFMPEG_LIBRARIES ${FFMPEG_PLATFORM_DEPENDENT_LIBS})
list(APPEND FFMPEG_STATIC_LIBRARIES ${FFMPEG_PLATFORM_DEPENDENT_LIBS})

find_package_handle_standard_args(FFMPEG REQUIRED_VARS FFMPEG_LIBRARIES FFMPEG_INCLUDE_DIR)

# TODO - read versions from headers
set(FFMPEG_libavcodec_VERSION 57.107.100)
set(FFMPEG_libavformat_VERSION 57.83.100)
set(FFMPEG_libavutil_VERSION 55.78.100)
set(FFMPEG_libswscale_VERSION 4.8.100)
set(FFMPEG_libavresample_VERSION 3.7.0)