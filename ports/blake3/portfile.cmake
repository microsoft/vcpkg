vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE3-team/BLAKE3
    REF "${VERSION}"
    SHA512 a2ac662b0e45d1f4c4ee01a5e556a47c49ab5407a6057034033ce6fd0fc6b88f66dd428d80f5e7c4a8413356cb4b5ab655924d96138213499893e0204d7c8d24
    HEAD_REF main
    PATCHES
        fix-windows-arm-build-error.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/c"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
