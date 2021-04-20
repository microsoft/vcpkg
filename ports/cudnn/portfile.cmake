if(VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_OSX)
  message(FATAL_ERROR "This port is only for Windows Desktop or Linux")
endif()

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "This port is only for x64 architectures")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled) # only release bits are provided

set(MINIMUM_CUDNN_VERSION "7.6.5")

include(${CURRENT_INSTALLED_DIR}/share/cuda/vcpkg_find_cuda.cmake)
vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT OUT_CUDA_VERSION CUDA_VERSION)

# Try to find CUDNN if it exists; only download if it doesn't exist
find_path(CUDNN_INCLUDE_DIR NAMES cudnn.h cudnn_v8.h cudnn_v7.h
  HINTS ${CUDA_TOOLKIT_ROOT} $ENV{CUDA_PATH} $ENV{CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN} $ENV{CUDNN_ROOT_DIR} /usr/include
  PATH_SUFFIXES cuda/include include)
message(STATUS "CUDNN_INCLUDE_DIR: ${CUDNN_INCLUDE_DIR}")
find_library(CUDNN_LIBRARY NAMES cudnn cudnn8 cudnn7
  HINTS ${CUDA_TOOLKIT_ROOT} $ENV{CUDA_PATH} $ENV{CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN} $ENV{CUDNN_ROOT_DIR} /usr/lib/x86_64-linux-gnu/
  PATH_SUFFIXES lib lib64 cuda/lib cuda/lib64 lib/x64)
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
  set(CUDNN_FOUND TRUE)
else()
  set(CUDNN_FOUND FALSE)
endif()

# Download CUDNN if not found
if (CUDNN_FOUND)
  message(STATUS "Found CUDNN ${_CUDNN_VERSION} located on system: (include ${CUDNN_INCLUDE_DIR} lib: ${CUDNN_LIBRARY})")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
elseif(CUDA_VERSION VERSION_EQUAL "10.1" OR CUDA_VERSION VERSION_EQUAL "10.2")
  message(STATUS "CUDNN not found on system - downloading a version compatible with your CUDA v${CUDA_VERSION}...")
  if(${CUDA_VERSION} VERSION_EQUAL "10.1")
    set(CUDNN_VERSION "7.6.5")
    set(CUDNN_VERSION_MAJOR "7")
    set(CUDNN_FULL_VERSION "7.6.5-cuda10.1_0")
    if(VCPKG_TARGET_IS_WINDOWS)
      set(CUDNN_DOWNLOAD_LINK "https://anaconda.org/anaconda/cudnn/${CUDNN_VERSION}/download/win-64/cudnn-${CUDNN_FULL_VERSION}.tar.bz2")
      set(SHA512_CUDNN "0fb18dd49de877ad6bae24b53ffe007a99915cc9601697a556897e018cc6d99d3aa68716ea99248cf6a9dfaeeb1a551453c606d04e8bbb3e9315bf768184f15b")
      set(CUDNN_OS "windows")
    elseif(VCPKG_TARGET_IS_LINUX)
      set(CUDNN_DOWNLOAD_LINK "https://anaconda.org/anaconda/cudnn/${CUDNN_VERSION}/download/linux-64/cudnn-${CUDNN_FULL_VERSION}.tar.bz2")
      set(SHA512_CUDNN "4d901d96ee8f37e3977240b9e6e6eeecb33848388db953a789be47de8f357d815c3a106ceab04297c4df0d8ed9c2795b2a22304e93cd1e53322307d3f3cd668e")
      set(CUDNN_OS "linux")
    endif()
  elseif(${CUDA_VERSION} VERSION_EQUAL "10.2")
    set(CUDNN_VERSION "7.6.5")
    set(CUDNN_VERSION_MAJOR "7")
    set(CUDNN_FULL_VERSION "7.6.5-cuda10.2_0")
    if(VCPKG_TARGET_IS_WINDOWS)
      set(CUDNN_DOWNLOAD_LINK "https://anaconda.org/anaconda/cudnn/${CUDNN_VERSION}/download/win-64/cudnn-${CUDNN_FULL_VERSION}.tar.bz2")
      set(SHA512_CUDNN "86ca2f5f510d4fbeb37548d0bcab42474a1c4041be2cf96c4964f1e51c3641dc4bf25e8434cd5ff99fac9f53946e5f0e83bd845613144731d136cd60913d4aaa")
      set(CUDNN_OS "windows")
    elseif(VCPKG_TARGET_IS_LINUX)
      set(CUDNN_DOWNLOAD_LINK "https://anaconda.org/anaconda/cudnn/${CUDNN_VERSION}/download/linux-64/cudnn-${CUDNN_FULL_VERSION}.tar.bz2")
      set(SHA512_CUDNN "b15b554c2ec004105cec8ee2a99f33fab0f9aed12128522730be4fa6204a5b2dff29e42901b5c4840b5ebf35607e8a54f35eb30525885067165b05dd95aa391b")
      set(CUDNN_OS "linux")
    endif()
  endif()

  vcpkg_download_distfile(ARCHIVE
      URLS ${CUDNN_DOWNLOAD_LINK}
      FILENAME "cudnn-${CUDNN_FULL_VERSION}-${CUDNN_OS}.tar.bz2"
      SHA512 ${SHA512_CUDNN}
  )

  vcpkg_extract_source_archive_ex(
      OUT_SOURCE_PATH SOURCE_PATH
      ARCHIVE ${ARCHIVE}
      NO_REMOVE_ONE_LEVEL
  )

  if(VCPKG_TARGET_IS_WINDOWS)
    file(INSTALL "${SOURCE_PATH}/Library/include/cudnn.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    file(INSTALL "${SOURCE_PATH}/Library/lib/x64/cudnn.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL "${SOURCE_PATH}/Library/bin/cudnn64_${CUDNN_VERSION_MAJOR}.dll" DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    set(LICENSE_PATH "${SOURCE_PATH}/info/LICENSE.txt")
  elseif(VCPKG_TARGET_IS_LINUX)
    file(INSTALL "${SOURCE_PATH}/include/cudnn.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION_MAJOR}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    set(LICENSE_PATH "${SOURCE_PATH}/info/licenses/NVIDIA_SLA_cuDNN_Support.txt")
  endif()

  file(INSTALL "${LICENSE_PATH}" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindCUDNN.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

else() # CUDNN NOT FOUND AND NOT AUTO-DOWNLOADABLE
  message(FATAL_ERROR "Please install manually cuDNN for your CUDA v${CUDA_VERSION}")
endif()
