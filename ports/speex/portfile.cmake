if(VCPKG_TARGET_IS_WINDOWS)
  list(APPEND PATCHES "0001-make-pkg-config-lib-name-configurable.patch")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO xiph/speex
  REF 5dceaaf3e23ee7fd17c80cb5f02a838fd6c18e01 #Speex-1.2.1
  SHA512  d03da906ec26ddcea2e1dc4157ac6dd056e1407381b0f37edd350552a02a7372e9108b4e39ae522f1b165be04b813ee11db0b47d17607e4dad18118b9041636b
  HEAD_REF master
  PATCHES ${PATCHES}
)

if(VCPKG_TARGET_IS_WINDOWS)
  file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
  
  vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
  )
  vcpkg_cmake_install()

  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/speex/speex.h"
        "extern const SpeexMode"
        "__declspec(dllimport) extern const SpeexMode"
    )
  endif()
else()
  if(VCPKG_TARGET_IS_OSX)
      message("${PORT} currently requires the following libraries from the system package manager:\n    autoconf\n    automake\n    libtool\n\nIt can be installed with brew install autoconf automake libtool")
  elseif(VCPKG_TARGET_IS_LINUX)
      message("${PORT} currently requires the following libraries from the system package manager:\n    autoconf\n    automake\n    libtool\n\nIt can be installed with apt-get install autoconf automake libtool")
  endif()
  vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS --disable-binaries # no example programs (require libogg)
  )
  vcpkg_install_make()

  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
