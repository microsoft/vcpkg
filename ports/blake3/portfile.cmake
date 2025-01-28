vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE3-team/BLAKE3
    REF "${VERSION}"
    SHA512 39b8c49f70a84ac23df1ddaf920ad3d829268db108077e67108b19bc7cdf7e18d468eba5d58a10d79269101204dad52c9463a5b1729d212e15f6c7a419fcfbe7
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_A2" "${SOURCE_PATH}/LICENSE_A2LLVM" "${SOURCE_PATH}/LICENSE_CC0")
