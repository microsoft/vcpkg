vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO BLAKE3-team/BLAKE3
    REF "${VERSION}"
    SHA512 30f88bb075cc22638c33945181f70259131e43a38a2719e3227afece0a8d23ed49582771dc271ada9d096258f8f711ada81986394c5177c3d4619108873f1615
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
