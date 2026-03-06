set(VCPKG_BUILD_TYPE release) # Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sentomk/patternia
    REF "v${VERSION}"
    SHA512 55ee011a65697978a0ef33ef51cf71ef6aa25239953423c13ebd78cb39749b7e3091be5f9dec5c74a6339c7b53895e11830d7df96f849b518d5453af20dafd84
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
