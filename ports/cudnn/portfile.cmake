vcpkg_fail_port_install(ON_ARCH "arm" "arm64" "x86" ON_TARGET "OSX" "UWP")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

#note: this port must be kept in sync with CUDA port: every time one is upgraded, the other must be too
set(CUDNN_VERSION "7.6.5")
set(CUDNN_FULL_VERSION "${CUDNN_VERSION}-cuda10.2_0")

if(VCPKG_TARGET_IS_WINDOWS)
  set(CUDNN_DOWNLOAD_LINK "https://anaconda.org/anaconda/cudnn/${CUDNN_VERSION}/download/win-64/cudnn-${CUDNN_FULL_VERSION}.tar.bz2")
  set(SHA512_CUDNN "86ca2f5f510d4fbeb37548d0bcab42474a1c4041be2cf96c4964f1e51c3641dc4bf25e8434cd5ff99fac9f53946e5f0e83bd845613144731d136cd60913d4aaa")
  set(CUDNN_OS "windows")
elseif(VCPKG_TARGET_IS_LINUX)
  set(CUDNN_DOWNLOAD_LINK "https://anaconda.org/anaconda/cudnn/${CUDNN_VERSION}/download/linux-64/cudnn-${CUDNN_FULL_VERSION}.tar.bz2")
  set(SHA512_CUDNN "b15b554c2ec004105cec8ee2a99f33fab0f9aed12128522730be4fa6204a5b2dff29e42901b5c4840b5ebf35607e8a54f35eb30525885067165b05dd95aa391b")
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
  file(INSTALL "${SOURCE_PATH}/info/LICENSE.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
elseif(VCPKG_TARGET_IS_LINUX)
  file(INSTALL "${SOURCE_PATH}/include/cudnn.h" DESTINATION ${CURRENT_PACKAGES_DIR}/include)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION_MAJOR}" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION}" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so.${CUDNN_VERSION_MAJOR}" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(INSTALL "${SOURCE_PATH}/lib/libcudnn.so" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
  file(INSTALL "${SOURCE_PATH}/info/licenses/NVIDIA_SLA_cuDNN_Support.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endif()


file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/FindCUDNN.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
