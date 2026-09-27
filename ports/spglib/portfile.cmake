vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spglib/spglib
    REF "v${VERSION}"
    SHA512 38b5e5c50bdda2c530f0b3f24d0f89e12965d0c2d1067e6d8501e677926c49de875fbcbd548185724427c0969aa6df328cc86dd077d3c692630b3cd26fa66476
    HEAD_REF develop
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SPGLIB_SHARED_LIBS)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DSPGLIB_WITH_TESTS=OFF
    -DSPGLIB_SHARED_LIBS=${SPGLIB_SHARED_LIBS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Spglib)
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
