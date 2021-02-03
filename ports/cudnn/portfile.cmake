if(VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_OSX)
  message(FATAL_ERROR "This port is only for Windows Desktop or Linux")
endif()

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "This port is only for x64 architectures")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled) # only release bits are provided

# note: this port must be kept in sync with CUDA port: every time one is upgraded, the other must be too
# Minimum version to find -- should match the CUDA port's minimum version's corresponding NCCL version
set(CUDNN_VERSION "7.6.0")
string(REPLACE "." ";" VERSION_LIST ${CUDNN_VERSION})
list(GET VERSION_LIST 0 CUDNN_VERSION_MAJOR)
list(GET VERSION_LIST 1 CUDNN_VERSION_MINOR)
list(GET VERSION_LIST 2 CUDNN_VERSION_PATCH)

# Try to find CUDNN if it exists
find_path(CUDNN_INCLUDE_DIR cudnn.h
  HINTS ${CUDA_HOME} ${CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN} $ENV{CUDNN_ROOT_DIR}
  PATH_SUFFIXES cuda/include include)
find_library(CUDNN_LIBRARY cudnn
  HINTS ${CUDA_HOME} ${CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN} $ENV{CUDNN_ROOT_DIR}
  PATH_SUFFIXES lib lib64 cuda/lib cuda/lib64 lib/x64)
if(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn.h")
  file(READ ${CUDNN_INCLUDE_DIR}/cudnn.h CUDNN_HEADER_CONTENTS)
  if(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_version.h")
    file(READ "${CUDNN_INCLUDE_DIR}/cudnn_version.h" CUDNN_VERSION_H_CONTENTS)
    string(APPEND CUDNN_HEADER_CONTENTS "${CUDNN_VERSION_H_CONTENTS}")
    unset(CUDNN_VERSION_H_CONTENTS)
  endif()
    string(REGEX MATCH "define CUDNN_MAJOR * +([0-9]+)"
                 _CUDNN_VERSION_MAJOR "${CUDNN_HEADER_CONTENTS}")
    string(REGEX REPLACE "define CUDNN_MAJOR * +([0-9]+)" "\\1"
                 _CUDNN_VERSION_MAJOR "${_CUDNN_VERSION_MAJOR}")
    string(REGEX MATCH "define CUDNN_MINOR * +([0-9]+)"
                 _CUDNN_VERSION_MINOR "${CUDNN_HEADER_CONTENTS}")
    string(REGEX REPLACE "define CUDNN_MINOR * +([0-9]+)" "\\1"
                 _CUDNN_VERSION_MINOR "${_CUDNN_VERSION_MINOR}")
    string(REGEX MATCH "define CUDNN_PATCHLEVEL * +([0-9]+)"
                 _CUDNN_VERSION_PATCH "${CUDNN_HEADER_CONTENTS}")
    string(REGEX REPLACE "define CUDNN_PATCHLEVEL * +([0-9]+)" "\\1"
                 _CUDNN_VERSION_PATCH "${_CUDNN_VERSION_PATCH}")
  if(NOT _CUDNN_VERSION_MAJOR)
    set(_CUDNN_VERSION "?")
  else()
    set(_CUDNN_VERSION "${_CUDNN_VERSION_MAJOR}.${_CUDNN_VERSION_MINOR}.${_CUDNN_VERSION_PATCH}")
  endif()
endif()

if (CUDNN_INCLUDE_DIR AND CUDNN_LIBRARY AND _CUDNN_VERSION VERSION_GREATER_EQUAL CUDNN_VERSION)
  set(CUDNN_FOUND TRUE)
else()
  set(CUDNN_FOUND FALSE)
endif()

if (CUDNN_FOUND)
  message(STATUS "Found CUDNN located on system: (include ${CUDNN_INCLUDE_DIR} lib: ${CUDNN_LIBRARY})")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()
  message(FATAL_ERROR "Could not find cuDNN. Before continuing, please download and install a cuDNN version "
    "\nthat matches your CUDA version from:"
    "\n    https://developer.nvidia.com/cuDNN\n")
endif()
