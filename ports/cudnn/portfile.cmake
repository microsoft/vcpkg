if(VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_OSX)
  message(FATAL_ERROR "This port is only for Windows Desktop or Linux")
endif()

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "This port is only for x64 architectures")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled) # only release bits are provided

#note: this port must be kept in sync with CUDA port: every time one is upgraded, the other must be too
set(CUDNN_VERSION "7.6.0")
set(AUTO_DOWNLOAD_CUDNN_IF_CUDA_VERSION_IS "10.1")
set(CUDNN_FULL_VERSION "${CUDNN_VERSION}-cuda${AUTO_DOWNLOAD_CUDNN_IF_CUDA_VERSION_IS}_0")
string(REPLACE "." ";" VERSION_LIST ${CUDNN_VERSION})
list(GET VERSION_LIST 0 CUDNN_VERSION_MAJOR)
list(GET VERSION_LIST 1 CUDNN_VERSION_MINOR)
list(GET VERSION_LIST 2 CUDNN_VERSION_PATCH)

# Try to find CUDNN if it exists; only download if it doesn't exist
find_path(CUDNN_INCLUDE_DIR NAMES cudnn.h cudnn_v8.h cudnn_v7.h
  HINTS ${CUDA_HOME} ${CUDA_PATH} ${CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN} $ENV{CUDNN_ROOT_DIR}
  PATH_SUFFIXES cuda/include include)
find_library(CUDNN_LIBRARY NAMES cudnn cudnn8 cudnn7
  HINTS ${CUDA_HOME} ${CUDA_PATH} ${CUDA_TOOLKIT_ROOT_DIR} $ENV{cudnn} $ENV{CUDNN} $ENV{CUDNN_ROOT_DIR}
  PATH_SUFFIXES lib lib64 cuda/lib cuda/lib64 lib/x64)
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

if (CUDNN_INCLUDE_DIR AND CUDNN_LIBRARY AND _CUDNN_VERSION VERSION_GREATER_EQUAL CUDNN_VERSION)
  set(CUDNN_FOUND TRUE)
else()
  set(CUDNN_FOUND FALSE)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/../cuda/vcpkg_find_cuda.cmake)
vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT OUT_CUDA_VERSION CUDA_VERSION)

# Download CUDNN if not found
if (CUDNN_FOUND)
  message(STATUS "Found CUDNN ${CUDNN_VERSION} located on system: (include ${CUDNN_INCLUDE_DIR} lib: ${CUDNN_LIBRARY})")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
elseif(${CUDA_VERSION} VERSION_EQUAL ${AUTO_DOWNLOAD_CUDNN_IF_CUDA_VERSION_IS})
  message(STATUS "CUDNN not found on system - downloading v${CUDNN_VERSION}...")
  if(VCPKG_TARGET_IS_WINDOWS)
    set(CUDNN_DOWNLOAD_LINK "https://anaconda.org/anaconda/cudnn/${CUDNN_VERSION}/download/win-64/cudnn-${CUDNN_FULL_VERSION}.tar.bz2")
    set(SHA512_CUDNN "c0218407e7bc2b3c1497f1709dedee345bc619603ec0efa094e392888c0d513d645a1241501f9b406f688defa811578f36b49f456eb533535ecd526702156eea")
    set(CUDNN_OS "windows")
  elseif(VCPKG_TARGET_IS_LINUX)
    set(CUDNN_DOWNLOAD_LINK "https://anaconda.org/anaconda/cudnn/${CUDNN_VERSION}/download/linux-64/cudnn-${CUDNN_FULL_VERSION}.tar.bz2")
    set(SHA512_CUDNN "128ccdc0ec24a1133947d7a8eff6cd8edc224134fa5065a11a1a01a99dbaee7d799db1454e0a59e411cf6db244f8c2420c160488a5dd4830addc3578b2011e3d")
    set(CUDNN_OS "linux")
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
  elseif(VCPKG_TARGET_IS_LINUX)
    file(INSTALL "${SOURCE_PATH}/include/cudnn.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION_MAJOR}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  endif()

  file(INSTALL "${SOURCE_PATH}/info/LICENSE.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindCUDNN.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

else() # CUDNN NOT FOUND AND NOT AUTO-DOWNLOADABLE
  message(FATAL_ERROR "Please install manually cuDNN for your CUDA v${CUDA_VERSION}")
endif()
