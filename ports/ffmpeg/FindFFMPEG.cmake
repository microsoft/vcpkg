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

include(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
include(${CMAKE_ROOT}/Modules/SelectLibraryConfigurations.cmake)
include(${CMAKE_ROOT}/Modules/CMakeFindDependencyMacro.cmake)

find_dependency(Threads)
#list(APPEND FFMPEG_PLATFORM_DEPENDENT_LIBS Threads::Threads)
if(UNIX)
  list(APPEND FFMPEG_PLATFORM_DEPENDENT_LIBS -pthread)
endif()

#  Platform dependent libraries required by FFMPEG
if(WIN32)
  if(NOT CYGWIN)
    list(APPEND FFMPEG_PLATFORM_DEPENDENT_LIBS wsock32 ws2_32 Secur32)
  endif()
else()
  list(APPEND FFMPEG_PLATFORM_DEPENDENT_LIBS m)
endif()

macro(FFMPEG_FIND varname shortname headername)
  if(NOT FFMPEG_${varname}_INCLUDE_DIRS)
    find_path(FFMPEG_${varname}_INCLUDE_DIRS NAMES lib${shortname}/${headername} ${headername} PATH_SUFFIXES ffmpeg)
  endif()
  if(NOT FFMPEG_${varname}_LIBRARY)
    find_library(FFMPEG_${varname}_LIBRARY_RELEASE NAMES ${shortname} PATH_SUFFIXES ffmpeg ffmpeg/lib)
    get_filename_component(FFMPEG_${varname}_LIBRARY_RELEASE_DIR ${FFMPEG_${varname}_LIBRARY_RELEASE} DIRECTORY)
    find_library(FFMPEG_${varname}_LIBRARY_DEBUG NAMES ${shortname}d ${shortname} PATHS debug PATH_SUFFIXES ffmpeg ffmpeg/lib ffmpeg/debug/lib debug/ffmpeg/lib)
    get_filename_component(FFMPEG_${varname}_LIBRARY_DEBUG_DIR ${FFMPEG_${varname}_LIBRARY_DEBUG} DIRECTORY)
    select_library_configurations(FFMPEG_${varname})
  endif()
  if (FFMPEG_${varname}_LIBRARY AND FFMPEG_${varname}_INCLUDE_DIRS)
    set(FFMPEG_${varname}_FOUND 1)
    list(APPEND FFMPEG_LIBRARY_DIRS ${FFMPEG_${varname}_LIBRARY_RELEASE_DIR} ${FFMPEG_${varname}_LIBRARY_DEBUG_DIR})
  endif()
endmacro(FFMPEG_FIND)

macro(FFMPEG_FIND_GENEX varname shortname headername)
  if(NOT FFMPEG_${varname}_INCLUDE_DIRS)
    find_path(FFMPEG_${varname}_INCLUDE_DIRS NAMES lib${shortname}/${headername} ${headername} PATH_SUFFIXES ffmpeg)
  endif()
  if(NOT FFMPEG_${varname}_LIBRARY)
    find_library(FFMPEG_${varname}_LIBRARY_RELEASE NAMES ${shortname} PATH_SUFFIXES ffmpeg ffmpeg/lib)
    get_filename_component(FFMPEG_${varname}_LIBRARY_RELEASE_DIR ${FFMPEG_${varname}_LIBRARY_RELEASE} DIRECTORY)
    find_library(FFMPEG_${varname}_LIBRARY_DEBUG NAMES ${shortname}d ${shortname} PATHS debug PATH_SUFFIXES ffmpeg ffmpeg/lib ffmpeg/debug/lib debug/ffmpeg/lib)
    get_filename_component(FFMPEG_${varname}_LIBRARY_DEBUG_DIR ${FFMPEG_${varname}_LIBRARY_DEBUG} DIRECTORY)
    set(FFMPEG_${varname}_LIBRARY "$<$<CONFIG:Debug>:${FFMPEG_${varname}_LIBRARY_DEBUG}>$<$<CONFIG:Release>:${FFMPEG_${varname}_LIBRARY_RELEASE}>" CACHE STRING "")
    set(FFMPEG_${varname}_LIBRARIES ${FFMPEG_${varname}_LIBRARY} CACHE STRING "")
  endif()
  if (FFMPEG_${varname}_LIBRARY AND FFMPEG_${varname}_INCLUDE_DIRS)
    set(FFMPEG_${varname}_FOUND 1)
    list(APPEND FFMPEG_LIBRARY_DIRS ${FFMPEG_${varname}_LIBRARY_RELEASE_DIR} ${FFMPEG_${varname}_LIBRARY_DEBUG_DIR})
  endif()
endmacro(FFMPEG_FIND)

if(WIN32)
  if(NOT FFMPEG_${varname}_INCLUDE_DIRS)
    find_path(FFMPEG_stdint_INCLUDE_DIRS NAMES stdint.h PATH_SUFFIXES ffmpeg)
  endif()
  if (FFMPEG_stdint_INCLUDE_DIRS)
    set(STDINT_OK TRUE)
  endif()
else()
  set(STDINT_OK TRUE)
endif()

FFMPEG_FIND(libavcodec    avcodec    avcodec.h)
FFMPEG_FIND(libavdevice   avdevice   avdevice.h)
FFMPEG_FIND(libavfilter   avfilter   avfilter.h)
FFMPEG_FIND(libavformat   avformat   avformat.h)
FFMPEG_FIND(libavutil     avutil     avutil.h)
FFMPEG_FIND(libswresample swresample swresample.h)
FFMPEG_FIND(libswscale    swscale    swscale.h)
FFMPEG_FIND_GENEX(libzlib zlib       zlib.h)

if (FFMPEG_libavcodec_FOUND AND FFMPEG_libavdevice_FOUND AND FFMPEG_libavfilter_FOUND AND FFMPEG_libavformat_FOUND AND FFMPEG_libavutil_FOUND AND FFMPEG_libswresample_FOUND AND FFMPEG_libswscale_FOUND AND FFMPEG_libzlib_FOUND AND STDINT_OK)
  list(APPEND FFMPEG_INCLUDE_DIRS ${FFMPEG_libavformat_INCLUDE_DIRS} ${FFMPEG_libavdevice_INCLUDE_DIRS} ${FFMPEG_libavcodec_INCLUDE_DIRS} ${FFMPEG_libavutil_INCLUDE_DIRS} ${FFMPEG_libswscale_INCLUDE_DIRS} ${FFMPEG_stdint_INCLUDE_DIRS})
  list(REMOVE_DUPLICATES FFMPEG_INCLUDE_DIRS)
  list(REMOVE_DUPLICATES FFMPEG_LIBRARY_DIRS)

  list(APPEND FFMPEG_LIBRARIES
    ${FFMPEG_libavformat_LIBRARY}
    ${FFMPEG_libavdevice_LIBRARY}
    ${FFMPEG_libavcodec_LIBRARY}
    ${FFMPEG_libavutil_LIBRARY}
    ${FFMPEG_libswscale_LIBRARY}
    ${FFMPEG_libavfilter_LIBRARY}
    ${FFMPEG_libswresample_LIBRARY}
    ${FFMPEG_libzlib_LIBRARY}
    ${FFMPEG_PLATFORM_DEPENDENT_LIBS}
  )
  set(FFMPEG_LIBRARY ${FFMPEG_LIBRARIES})

  set(FFMPEG_LIBRARIES ${FFMPEG_LIBRARIES} CACHE STRING "")
  set(FFMPEG_INCLUDE_DIRS ${FFMPEG_INCLUDE_DIRS} CACHE STRING "")
  set(FFMPEG_LIBRARY_DIRS ${FFMPEG_LIBRARY_DIRS} CACHE STRING "")
endif()

find_package_handle_standard_args(FFMPEG REQUIRED_VARS FFMPEG_LIBRARIES FFMPEG_LIBRARY_DIRS FFMPEG_INCLUDE_DIRS)
