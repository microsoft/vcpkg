set(VCPKG_BUILD_TYPE release) # Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sentomk/patternia
    REF "v${VERSION}"
    SHA512 c50f11edce31e41a219b1505936bfb24c89909ce27b9aee7aa7783044aa294c20307ec665c7a3480ea3957602dcd2dca25b11fa95cbf748e3691f4ac768fc690
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPTN_INSTALL=ON
        -DPTN_BUILD_TESTS=OFF
        -DPTN_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
