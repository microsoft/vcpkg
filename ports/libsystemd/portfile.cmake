vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO systemd/systemd
  REF "v${VERSION}"
  SHA512 3bbc431a292ab590b70d3b490a528f71d30ccf478ddfa66d1c210f40c260ef49ac30651c19f2d073acf38d68398a4a6fbf95391f0e3ea0333d94b9d4e81d514f
)

vcpkg_configure_meson(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -Dstatic-libsystemd=true
    -Daudit=false
  OPTIONS_DEBUG
    -Drootprefix=${CURRENT_PACKAGES_DIR}/debug
    -Dpkgconfiglibdir={CURRENT_PACKAGES_DIR}/debug
  OPTIONS_RELEASE
    -Drootprefix=${CURRENT_PACKAGES_DIR}
    -Dpkgconfiglibdir={CURRENT_PACKAGES_DIR}
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_build_ninja(
    TARGETS libsystemd.a devel
  )
else()
  vcpkg_build_ninja(
    TARGETS libsystemd devel
  )
endif()

file(INSTALL "${SOURCE_PATH}/src/systemd" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")

set(BUILD_DIR_RELEASE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(INSTALL "${BUILD_DIR_RELEASE}/libsystemd.a" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
else()
  file(INSTALL "${BUILD_DIR_RELEASE}/libsystemd.so" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" FOLLOW_SYMLINK_CHAIN)
endif()

set(BUILD_DIR_DEBUG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(INSTALL "${BUILD_DIR_DEBUG}/libsystemd.a" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
else()
  file(INSTALL "${BUILD_DIR_DEBUG}/libsystemd.so" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" FOLLOW_SYMLINK_CHAIN)
endif()

file(INSTALL "${BUILD_DIR_RELEASE}/src/libsystemd/libsystemd.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(INSTALL "${BUILD_DIR_DEBUG}/src/libsystemd/libsystemd.pc" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")

vcpkg_fixup_pkgconfig()

configure_file("${CMAKE_CURRENT_LIST_DIR}/Config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-systemd/unofficial-systemd-config.cmake" @ONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.LGPL2.1")
