vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ridiculousfish/libdivide
    REF "v${VERSION}"
    SHA512 1a429b436e545360fb898e059ce689f5123d3fce25242d5a54e52588b75c97008918c1dc5e43f537eb8b2e61577339955ca66d9bbb0eb4440a00500a8a146ccf
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
