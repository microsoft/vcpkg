vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spglib/spglib
    REF "v${VERSION}"
    SHA512 15c0ced6168a436468d1f9db28bb93f3ff130467cd1f0b966cb9731d36be3d9877b3452561dbace3242351b7c9b41d41930a76ca2278f00c1b45620c06ee93e0
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
