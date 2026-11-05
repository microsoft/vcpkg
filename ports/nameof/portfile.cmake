vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/nameof
    REF "v${VERSION}"
    SHA512 fa0ea421c77988767cf438146cdb5941b7b33049aacc37b7db3df49fdec71106f883387431acf5630987043f7782e4eed0e05b18166a482a30730fc81f5200f5
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNAMEOF_OPT_BUILD_EXAMPLES=OFF
        -DNAMEOF_OPT_BUILD_TESTS=OFF
        -DNAMEOF_OPT_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
