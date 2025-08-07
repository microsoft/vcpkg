vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kfrlib/kfr
    REF "${VERSION}"
    SHA512 83bbdede8b92c2d4833c84c922673c3ac85ac8f05c8e8a0372ee9775992163ba5e2788360086b8f600c7e3686500885efd06b1dd6c3083c5eb2535d4a5a4d756
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        capi KFR_ENABLE_CAPI_BUILD
        dft KFR_ENABLE_DFT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_TESTS=OFF
        -DENABLE_EXAMPLES=OFF
        -DKFR_ENABLE_ASMTEST=OFF
        -DKFR_REGENERATE_TESTS=OFF
        -DKFR_EXTENDED_TESTS=OFF
        -DKFR_SKIP_TESTS=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    COMMENT [[
KFR is distributed under dual GPLv2/v3 and commercial license.
https://kfrlib.com/purchase
]]
    FILE_LIST "${SOURCE_PATH}/LICENSE.txt"
)
