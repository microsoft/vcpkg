# Find the nccl libraries
#
# The following variables are optionally searched for defaults
#  NCCL_ROOT: Base directory where all NCCL components are found
#  NCCL_INCLUDE_DIR: Directory where NCCL header is found
#  NCCL_LIB_DIR: Directory where NCCL library is found
#
# The following are set after configuration is done:
#  NCCL_FOUND
#  NCCL_INCLUDE_DIRS
#  NCCL_LIBRARIES

find_path(NCCL_INCLUDE_DIRS
  NAMES nccl.h
  PATH_SUFFIXES
  include
)

# Read version from header
if(EXISTS "${NCCL_INCLUDE_DIRS}/nccl.h")
  file(READ ${NCCL_INCLUDE_DIRS}/nccl.h NCCL_HEADER_CONTENTS)
endif()
if(NCCL_HEADER_CONTENTS)
  string(REGEX MATCH "define NCCL_MAJOR * +([0-9]+)"
               _NCCL_VERSION_MAJOR "${NCCL_HEADER_CONTENTS}")
  string(REGEX REPLACE "define NCCL_MAJOR * +([0-9]+)" "\\1"
               _NCCL_VERSION_MAJOR "${_NCCL_VERSION_MAJOR}")
  string(REGEX MATCH "define NCCL_MINOR * +([0-9]+)"
               _NCCL_VERSION_MINOR "${NCCL_HEADER_CONTENTS}")
  string(REGEX REPLACE "define NCCL_MINOR * +([0-9]+)" "\\1"
    _NCCL_VERSION_MINOR "${_NCCL_VERSION_MINOR}")
  string(REGEX MATCH "define NCCL_PATCH * +([0-9]+)"
    _NCCL_VERSION_PATCH "${NCCL_HEADER_CONTENTS}")
  string(REGEX REPLACE "define NCCL_PATCH * +([0-9]+)" "\\1"
    _NCCL_VERSION_PATCH "${_NCCL_VERSION_PATCH}")
  if(NOT _NCCL_VERSION_MAJOR)
    set(_NCCL_VERSION "?")
  else()
    set(_NCCL_VERSION "${_NCCL_VERSION_MAJOR}.${_NCCL_VERSION_MINOR}.${_NCCL_VERSION_PATCH}")
  endif()
endif()

find_library(NCCL_LIBRARIES
  NAMES nccl
  PATH_SUFFIXES
  lib
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NCCL
  REQUIRED_VARS NCCL_INCLUDE_DIRS NCCL_LIBRARIES
  VERSION_VAR   _NCCL_VERSION)

if(NCCL_FOUND)  # obtaining NCCL version and some sanity checks
  message(STATUS "Found NCCL ${_NCCL_VERSION} (include: ${NCCL_INCLUDE_DIRS}, library: ${NCCL_LIBRARIES})")
  mark_as_advanced(NCCL_ROOT_DIR NCCL_INCLUDE_DIRS NCCL_LIBRARIES NCCL_VERSION)
endif()
