vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE3-team/BLAKE3
    REF "${VERSION}"
    SHA512 eb782d48240cf2fa8cc3cddd699dce3a362eb480b3ca58a97d54cd3595a0c969e51fe14374b91136036e8e29c8f745efbd5a4d1aaed2c17f23cb89fb756645d0
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
