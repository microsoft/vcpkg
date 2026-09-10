vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ridiculousfish/libdivide
    REF "v${VERSION}"
    SHA512 df2e0b0f1b5a84e8e1ab2a362d21a77f5d07412619722ab4c0c7eeb7d039c056acdd45006b1049cdd1fe2abb39ea460c1626f6a8279ea2091de8ef4446ac8ea6
    HEAD_REF master
    PATCHES
        no-werror.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test LIBDIVIDE_BUILD_TESTS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBDIVIDE_SSE2=OFF
        -DLIBDIVIDE_AVX2=OFF
        -DLIBDIVIDE_AVX512=OFF
        -DLIBDIVIDE_NEON=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
