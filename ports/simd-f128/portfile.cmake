vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tiw302/simd-f128
    REF v1.6.2
    SHA512 3d8914b45676bfe816e78b4c940bf5f367a7d2f70b9977dc41d2341fe2abbf7dd1f844a90c8d435b669a19111d4865791167a288d5447a0624b0eb4fc43a8215
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSIMD_F128_BUILD_EXAMPLES=OFF
        -DSIMD_F128_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME simd_f128 CONFIG_PATH lib/cmake/simd_f128)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
