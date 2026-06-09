vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CrowCpp/crow
    REF "v${VERSION}"
    SHA512 b413cfbd5e25ed2a1eb6f06ad3e997cc3f592775fd98db900c15a95a13a31578ce7563ec372794f77bf1a4b7c21a7998e9129a0c5e0dc840e8e7d83e688a75ad
    HEAD_REF master
    PATCHES remove-cpm.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCROW_BUILD_EXAMPLES=OFF
        -DCROW_BUILD_TESTS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Crow)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
