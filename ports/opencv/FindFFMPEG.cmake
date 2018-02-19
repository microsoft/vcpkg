# Distributed under the OSI-approved BSD 3-Clause License.
#
#.rst:
# FindFFMPEG
# --------
#
# Find the FFPMEG libraries
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

include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

#  Platform dependent libraries required by FFMPEG
if(WIN32)
  if(NOT CYGWIN)
    set( FFMPEG_PLATFORM_DEPENDENT_LIBS wsock32 ws2_32 Secur32 )
  endif()
endif()

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
    find_library(FFMPEG_${varname}_LIBRARY_RELEASE NAMES ${shortname} PATHS ${FFMPEG_ROOT} PATH_SUFFIXES ffmpeg ffmpeg/lib)
    find_library(FFMPEG_${varname}_LIBRARY_DEBUG NAMES ${shortname} ${shortname}d PATHS ${FFMPEG_ROOT} PATH_SUFFIXES ffmpeg ffmpeg/lib ffmpeg/debug/lib debug/ffmpeg/lib)
    select_library_configurations(FFMPEG_${varname})
  endif()
  if (FFMPEG_${varname}_LIBRARY AND FFMPEG_${varname}_INCLUDE_DIRS)
    set(FFMPEG_${varname}_FOUND 1)
  endif(FFMPEG_${varname}_LIBRARY AND FFMPEG_${varname}_INCLUDE_DIRS)
endmacro(FFMPEG_FIND)

if(WIN32)
  if(NOT FFMPEG_${varname}_INCLUDE_DIRS)
    find_path(FFMPEG_stdint_INCLUDE_DIRS NAMES stdint.h PATHS ${FFMPEG_ROOT}/include ${FFMPEG_INCLUDE_DIRS} PATH_SUFFIXES ffmpeg Release Debug)
  endif()
  if (FFMPEG_stdint_INCLUDE_DIRS)
    set(STDINT_OK TRUE)
  endif()
else()
  set(STDINT_OK TRUE)
endif()


FFMPEG_FIND(libavformat   avformat   avformat.h)
FFMPEG_FIND(libavdevice   avdevice   avdevice.h)
FFMPEG_FIND(libavcodec    avcodec    avcodec.h)
FFMPEG_FIND(libavutil     avutil     avutil.h)
FFMPEG_FIND(libswscale    swscale    swscale.h)

set(FFMPEG_FOUND "NO")

if (FFMPEG_libavformat_FOUND AND FFMPEG_libavdevice_FOUND AND FFMPEG_libavcodec_FOUND AND FFMPEG_libavutil_FOUND AND FFMPEG_libswscale_FOUND AND STDINT_OK)
  set(FFMPEG_FOUND "YES")

  set(FFMPEG_INCLUDE_DIRS ${FFMPEG_libavformat_INCLUDE_DIRS})
  set(FFMPEG_LIBRARY_DIRS ${FFMPEG_libavformat_LIBRARY_DIRS})
  set(FFMPEG_INCLUDE_DIR ${FFMPEG_libavformat_INCLUDE_DIRS})
  set(FFMPEG_LIBRARY_DIR ${FFMPEG_libavformat_LIBRARY_DIRS})

  list(APPEND FFMPEG_LIBRARIES
    ${FFMPEG_libavformat_LIBRARY}
    ${FFMPEG_libavdevice_LIBRARY}
    ${FFMPEG_libavcodec_LIBRARY}
    ${FFMPEG_libavutil_LIBRARY}
    ${FFMPEG_libswscale_LIBRARY}
    ${FFMPEG_PLATFORM_DEPENDENT_LIBS}
  )
endif()
