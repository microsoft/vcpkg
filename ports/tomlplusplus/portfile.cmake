vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO marzer/tomlplusplus
    REF v${VERSION}
    SHA512 6ab2de83b7fc44de40e58a47c28a9507bf7c50fa9b08925b5a6d48958868a86e6790aff684d29ceb50ad18905e3832840719e1b7bfec3b8a0c00b15bb0f70f38
    HEAD_REF master
    PATCHES
        fix-installdir.patch
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgenerate_cmake_config=true
        -Dbuild_tests=false
        -Dbuild_examples=false
)

vcpkg_install_meson()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/tomlplusplus)
cmake_path(NATIVE_PATH SOURCE_PATH native_source_path)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/tomlplusplus/tomlplusplusConfig.cmake" "${native_source_path}" "")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
