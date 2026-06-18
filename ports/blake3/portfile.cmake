vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE3-team/BLAKE3
    REF "${VERSION}"
    SHA512 53344e5fa3d3058f9190f159991652a11951ce960236793d2ef2328b1c7f9310f11a7f84c6a2487aed253bc6d8269dbf4d7fbd30d765480849b2ef82e22c418e
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
