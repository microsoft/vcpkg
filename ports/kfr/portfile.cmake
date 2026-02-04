vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kfrlib/kfr
    REF "${VERSION}"
    SHA512 2bf6698efc4eb577104308bcb0477bf631f39848842129993222227fcaad7793e776c04dbe7ec66b155018a5e9f09c15fe0864576860362effc63ced8f22bba5
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
