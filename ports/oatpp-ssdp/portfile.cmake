set(OATPP_VERSION "1.3.0")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oatpp/oatpp-ssdp
    REF ${OATPP_VERSION}
    SHA512 ab6f10bb79cb058eb7ce4115327e2f2d85133753d02dc2b4339505cc2ed4ef8b6284b5e832d0e190de17b8ae70e0b9a99b1b074d0691ca9a613873e8d4e1ace8
    HEAD_REF master
    PATCHES
        fix_String_to_string.patch
        fix_win_close.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DOATPP_BUILD_TESTS:BOOL=OFF"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME oatpp-ssdp CONFIG_PATH lib/cmake/oatpp-ssdp-${OATPP_VERSION})
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
