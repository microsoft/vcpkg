vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE3-team/BLAKE3
    REF "${VERSION}"
    SHA512 d0861c3c0294d84a46a3760e5e51734f4040036aa74d72d32242adb9311c0f85f580c17fbee9ca17dc2b3818ff68048b3156a19b8d11fe5c459c5e9266709fb9
    HEAD_REF main
    PATCHES
        fix-windows-arm-build-error.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS BLAKE3_FEATURE_OPTIONS
    FEATURES
        tbb BLAKE3_USE_TBB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/c"
    OPTIONS
        ${BLAKE3_FEATURE_OPTIONS}
        -DBLAKE3_FETCH_TBB=OFF
        -DBLAKE3_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_A2" "${SOURCE_PATH}/LICENSE_A2LLVM" "${SOURCE_PATH}/LICENSE_CC0")
