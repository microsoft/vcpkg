set(VCPKG_BUILD_TYPE release) # Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sentomk/patternia
    REF "v${VERSION}"
    SHA512 ae8bc891a2caf3b2b4a8745b0049da3afb992b3001f92393383f84df047c28391a2f67443af7c36189a2ee15fd59db31f7ae7ba7886cf16166b4add90c4fac2d
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
