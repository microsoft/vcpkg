vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ridiculousfish/libdivide
    REF "v${VERSION}"
    SHA512 0a60d2ab750116faefc7db7a5209599d4fac5bfd74f7ad7377a525a65d4523855f395eb3e62e75a9eb9bf4d564354a40b2a056737bcf6c21cb6b7fb1f5918453
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
