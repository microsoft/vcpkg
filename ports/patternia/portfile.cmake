set(VCPKG_BUILD_TYPE release) # Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sentomk/patternia
    REF "v${VERSION}"
    SHA512 8203ae8974596538bbfeb74294d4f736e9a293c7d696b23808768a2e05fa5278eabfeb7e690b51aba2a1431a684ea2e0c948128f300035599de3001bfdfb2dd3
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
