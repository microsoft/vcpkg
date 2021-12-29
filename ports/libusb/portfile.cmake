
if(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n    autoreconf\n    libudev\n\nThese can be installed on Ubuntu systems via apt-get install autoreconf libudev-dev")
endif()

set(VERSION 1.0.24)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/libusb
    REF c6a35c56016ea2ab2f19115d2ea1e85e0edae155 # v1.0.24
    SHA512 985c020d9ae6f7135e3bfee68dddcf70921481db3d10e420f55d5ee9534f7fe7be6a2a31ee73a3b282b649fcc36da4fed848e0bd0410c20eaf1deb9a8e3086e8
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS)
  if(VCPKG_PLATFORM_TOOLSET MATCHES "v142")
    set(MSVS_VERSION 2019)
  elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
    set(MSVS_VERSION 2017)
  else()
    set(MSVS_VERSION 2015)
  endif()

  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
      set(LIBUSB_PROJECT_TYPE dll)
      if (VCPKG_CRT_LINKAGE STREQUAL static)
        file(READ "${SOURCE_PATH}/msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj" PROJ_FILE)
        string(REPLACE "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>" "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>" PROJ_FILE "${PROJ_FILE}")
        string(REPLACE "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>" "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>" PROJ_FILE "${PROJ_FILE}")
        file(WRITE "${SOURCE_PATH}/msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj" "${PROJ_FILE}")
      endif()
  else()
      set(LIBUSB_PROJECT_TYPE static)
      if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
        file(READ "${SOURCE_PATH}/msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj" PROJ_FILE)
        string(REPLACE "<RuntimeLibrary>MultiThreaded</RuntimeLibrary>" "<RuntimeLibrary>MultiThreadedDLL</RuntimeLibrary>" PROJ_FILE "${PROJ_FILE}")
        string(REPLACE "<RuntimeLibrary>MultiThreadedDebug</RuntimeLibrary>" "<RuntimeLibrary>MultiThreadedDebugDLL</RuntimeLibrary>" PROJ_FILE "${PROJ_FILE}")
        file(WRITE "${SOURCE_PATH}/msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj" "${PROJ_FILE}")
      endif()
  endif()

  # The README.md file in the archive is a symlink to README
  # which causes issues with the windows MSBUILD process
  file(REMOVE "${SOURCE_PATH}/README.md")

  vcpkg_install_msbuild(
      SOURCE_PATH "${SOURCE_PATH}"
      PROJECT_SUBPATH msvc/libusb_${LIBUSB_PROJECT_TYPE}_${MSVS_VERSION}.vcxproj
      LICENSE_SUBPATH COPYING
  )
  file(INSTALL "${SOURCE_PATH}/libusb/libusb.h"  DESTINATION "${CURRENT_PACKAGES_DIR}/include/libusb-1.0")
  set(prefix "")
  set(exec_prefix [[${prefix}]])
  set(libdir [[${prefix}/lib]])
  set(includedir [[${prefix}/include]])  
  configure_file("${SOURCE_PATH}/libusb-1.0.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libusb-1.0.pc" @ONLY)
  if(NOT VCPKG_BUILD_TYPE)
      set(includedir [[${prefix}/../include]])  
      configure_file("${SOURCE_PATH}/libusb-1.0.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libusb-1.0.pc" @ONLY)
  endif()
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
    )
    vcpkg_install_make()
endif()

vcpkg_fixup_pkgconfig()

configure_file("${CURRENT_PORT_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)
configure_file("${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
