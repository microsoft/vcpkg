vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hobuinc/laz-perf
    REF ${VERSION}
    SHA512 ec3e133d671a388f9cc448599035a57d0334015f18e6787ed05e463b4d3eddb5a4a09336a410f23c24d590d0d3242f3621ab49d4ce1400f226112e26f0759311
    HEAD_REF master
    PATCHES
        static.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/LAZPERF PACKAGE_NAME lazperf)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
