set(MINIMUM_CUDNN_VERSION "7.6.5")

vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT OUT_CUDA_VERSION CUDA_VERSION)

# Try to find CUDNN if it exists; only download if it doesn't exist
file(GLOB CUDNN_VERSION_DIRS
  LIST_DIRECTORIES true
  "$ENV{CUDA_PATH}/../../../NVIDIA/CUDNN/v[1-9]*.[1-9]*"
)
find_path(CUDNN_INCLUDE_DIR NAMES cudnn.h cudnn_v8.h cudnn_v7.h
  HINTS ${CUDA_TOOLKIT_ROOT} $ENV{CUDA_PATH} $ENV{CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN} $ENV{CUDNN_ROOT_DIR} ${CUDNN_VERSION_DIRS} /usr/include /usr/include/x86_64-linux-gnu/ /usr/include/aarch64-linux-gnu/
  PATH_SUFFIXES cuda/include include include/11.8 include/12.0 include/12.1 include/12.2 include/12.3 include/12.4 include/12.5 include/12.6)
message(STATUS "CUDNN_INCLUDE_DIR: ${CUDNN_INCLUDE_DIR}")
find_library(CUDNN_LIBRARY NAMES cudnn cudnn8 cudnn7
  HINTS ${CUDA_TOOLKIT_ROOT} $ENV{CUDA_PATH} $ENV{CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN} $ENV{CUDNN_ROOT_DIR} ${CUDNN_VERSION_DIRS} /usr/lib/x86_64-linux-gnu/ /usr/include/aarch64-linux-gnu/ /usr/
  PATH_SUFFIXES lib lib64 cuda/lib cuda/lib64 lib/x64 cuda/lib/x64 lib/11.8/x64 lib/12.0/x64 lib/12.1/x64 lib/12.2/x64 lib/12.3/x64 lib/12.4/x64 lib/12.5/x64 lib/12.6/x64)
message(STATUS "CUDNN_LIBRARY: ${CUDNN_LIBRARY}")
if(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn.h")
  file(READ ${CUDNN_INCLUDE_DIR}/cudnn.h CUDNN_HEADER_CONTENTS)
elseif(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_v8.h")
  file(READ ${CUDNN_INCLUDE_DIR}/cudnn_v8.h CUDNN_HEADER_CONTENTS)
elseif(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_v7.h")
  file(READ ${CUDNN_INCLUDE_DIR}/cudnn_v7.h CUDNN_HEADER_CONTENTS)
endif()
if(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_version.h")
  file(READ "${CUDNN_INCLUDE_DIR}/cudnn_version.h" CUDNN_VERSION_H_CONTENTS)
  string(APPEND CUDNN_HEADER_CONTENTS "${CUDNN_VERSION_H_CONTENTS}")
  unset(CUDNN_VERSION_H_CONTENTS)
elseif(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_version_v8.h")
  file(READ "${CUDNN_INCLUDE_DIR}/cudnn_version_v8.h" CUDNN_VERSION_H_CONTENTS)
  string(APPEND CUDNN_HEADER_CONTENTS "${CUDNN_VERSION_H_CONTENTS}")
  unset(CUDNN_VERSION_H_CONTENTS)
elseif(EXISTS "${CUDNN_INCLUDE_DIR}/cudnn_version_v7.h")
  file(READ "${CUDNN_INCLUDE_DIR}/cudnn_version_v7.h" CUDNN_VERSION_H_CONTENTS)
  string(APPEND CUDNN_HEADER_CONTENTS "${CUDNN_VERSION_H_CONTENTS}")
  unset(CUDNN_VERSION_H_CONTENTS)
endif()
if(CUDNN_HEADER_CONTENTS)
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

if (CUDNN_INCLUDE_DIR AND CUDNN_LIBRARY AND _CUDNN_VERSION VERSION_GREATER_EQUAL MINIMUM_CUDNN_VERSION)
  message(STATUS "Found CUDNN ${_CUDNN_VERSION} located on system: (include ${CUDNN_INCLUDE_DIR} lib: ${CUDNN_LIBRARY})")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
elseif(VCPKG_TARGET_IS_WINDOWS)
  message(FATAL_ERROR "Please download CUDNN from official sources (https://developer.nvidia.com/cudnn) and install it")
else()
  message(FATAL_ERROR "Please install CUDNN using your system package manager (the same way you installed CUDA). For example: apt install libcudnn8-dev.")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/FindCUDNN.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
