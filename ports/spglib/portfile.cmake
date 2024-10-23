vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO spglib/spglib
    REF "v${VERSION}"
    SHA512 123b08ba7174a792c84bad42f94cced5ad213b50ef8dfd58a9301ebf8b66cbedb3ce037d25b748d579d0b2ee2a594c1134a463e179bfd09757fb3c98445160ac
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
