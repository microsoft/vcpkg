vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ridiculousfish/libdivide
    REF "v${VERSION}"
    SHA512 1c94dabca83984ef8190ba91b328e5e994a9bc41b4f4b6800d7417db3312283576759ba3039741a4f045adab6f0391b82ba93523b802bb6a37bc3fd693a80e05
    HEAD_REF master
    PATCHES
        no-werror.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        test BUILD_TESTS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBDIVIDE_SSE2=OFF
        -DLIBDIVIDE_AVX2=OFF
        -DLIBDIVIDE_AVX512=OFF
        -DLIBDIVIDE_NEON=OFF
        -DENABLE_VECTOR_EXTENSIONS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright) 
