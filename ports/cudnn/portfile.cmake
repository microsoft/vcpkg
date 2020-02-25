include(vcpkg_common_functions)

if(VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_OSX)
  message(FATAL_ERROR "This port is only for Windows Desktop or Linux")
endif()

if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  message(FATAL_ERROR "This port is only for x64 architectures")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

#note: this port must be kept in sync with CUDA port: every time one is upgraded, the other must be too
set(CUDNN_VERSION "7.6.0")
set(CUDNN_FULL_VERSION "${CUDNN_VERSION}-cuda10.1_0")

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

string(REPLACE "." ";" VERSION_LIST ${CUDNN_VERSION})
list(GET VERSION_LIST 0 CUDNN_VERSION_MAJOR)
list(GET VERSION_LIST 1 CUDNN_VERSION_MINOR)
list(GET VERSION_LIST 2 CUDNN_VERSION_PATCH)

if(VCPKG_TARGET_IS_WINDOWS)
  file(INSTALL "${SOURCE_PATH}/Library/include/cudnn.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
  file(INSTALL "${SOURCE_PATH}/Library/lib/x64/cudnn.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(INSTALL "${SOURCE_PATH}/Library/bin/cudnn64_${CUDNN_VERSION_MAJOR}.dll" DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
  file(INSTALL "${SOURCE_PATH}/Library/lib/x64/cudnn.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(INSTALL "${SOURCE_PATH}/Library/bin/cudnn64_${CUDNN_VERSION_MAJOR}.dll" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
elseif(VCPKG_TARGET_IS_LINUX)
  file(INSTALL "${SOURCE_PATH}/include/cudnn.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION_MAJOR}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION}" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION_MAJOR}" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
endif()

file(INSTALL "${SOURCE_PATH}/info/LICENSE.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindCUDNN.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
