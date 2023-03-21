if(VCPKG_TARGET_IS_LINUX)
    message("${PORT} currently requires the following tools and libraries from the system package manager:\n    autoreconf\n    libudev\n\nThese can be installed on Ubuntu systems via apt-get install autoreconf libudev-dev")
endif()

set(VERSION 1.0.26)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libusb/libusb
    REF fcf0c710ef5911ae37fbbf1b39d48a89f6f14e8a # v1.0.26.11791 2023-03-12
    SHA512 0aa6439f7988487adf2a3bff473fec80b5c722a47f117a60696d2aa25c87cc3f20fb6aaca7c66e49be25db6a35eb0bb5f71ed7b211d1b8ee064c5d7f1b985c73
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
