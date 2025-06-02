vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kfrlib/kfr
    REF "${VERSION}"
    SHA512 2974f1c9e86447840de0225cd2a08bf72288ec8dd3f7f6fb55613e3d58d3364f0a488bd7babdb792ccb549976021bd4c18c2cbbb8af8ac79645606058259f7a2
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
