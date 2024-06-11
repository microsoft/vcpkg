vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/snappy
    REF ${VERSION}
    SHA512 3578597f1d4ec09104ce0296b825b013590351230dfe56c635081fd282ce7a13a34caf2c283ac77bd24065e2d27af6db068d1f84b98cec2fd39a0e37a0d77070
    HEAD_REF master
    PATCHES
        fix_clang-cl_build.patch
        no-werror.patch
        pkgconfig.diff
)
file(COPY "${CURRENT_PORT_DIR}/snappy.pc.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSNAPPY_BUILD_TESTS=OFF
        -DSNAPPY_BUILD_BENCHMARKS=OFF

        # These variables can be overriden in a custom triplet, see usage file
        -DSNAPPY_HAVE_SSSE3=OFF
        -DSNAPPY_HAVE_X86_CRC32=OFF
        -DSNAPPY_HAVE_NEON_CRC32=OFF
        -DSNAPPY_HAVE_BMI2=OFF
        -DSNAPPY_HAVE_NEON=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Snappy)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
