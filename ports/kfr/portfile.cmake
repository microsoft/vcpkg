vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kfrlib/kfr
    REF 5.0.1
    SHA512 e2d19813fd80bfc19e05576103d0500637bc30f7e7780fbe80e9ab5126a9530188965e5cb63d5de508beaceb94c6ff5c2dcf5d5f81fc5aa6122c707e0e155113
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        capi KFR_ENABLE_CAPI_BUILD
        dft KFR_ENABLE_DFT
        dft-np KFR_ENABLE_DFT_NP
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
