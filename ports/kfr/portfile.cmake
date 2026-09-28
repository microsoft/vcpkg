vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kfrlib/kfr
    REF "${VERSION}"
    SHA512 109a38f849b64ce3a96ab9995583dd89cbb1d91fa179f9a74eec0784b3926b17bfaaf3033af935efb2a747eec39f726f7e00bdd00f6dc104bb69696b7206a7d1
    HEAD_REF main
    PATCHES
        fix-audiotoolbox-link.patch
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
        # Use boost-math instead of fetching Boost.Math during the build
        -DKFR_USE_BOOST=ON
        -DKFR_USE_BOOST_MATH=OFF
        # Optional audio codecs
        -DCMAKE_DISABLE_FIND_PACKAGE_FLAC=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Ogg=ON
        -DALAC_INCLUDE_DIRS=OFF
        -DALAC_LIBRARY=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE
    "${CURRENT_PACKAGES_DIR}/LICENSE.txt"
    "${CURRENT_PACKAGES_DIR}/README.md"
    "${CURRENT_PACKAGES_DIR}/debug/LICENSE.txt"
    "${CURRENT_PACKAGES_DIR}/debug/README.md"
)

vcpkg_install_copyright(
    COMMENT [[
KFR is distributed under dual GPLv2/v3 and commercial license.
https://kfrlib.com/purchase
]]
    FILE_LIST "${SOURCE_PATH}/LICENSE.txt"
)
