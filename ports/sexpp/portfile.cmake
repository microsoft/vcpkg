vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rnpgp/sexpp
    REF 8e90031bd554884a2238177601d17f7a97fd4973
    SHA512 87dabdc7b60504b58824e3c081ac227bf8d011ff5446cccbad761a75b54ab93374139fdf75970a1ef430989aaba516fcae3ad080cf2f65d3194892a9d353ad25
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_SEXP_TESTS=OFF
        -DWITH_SEXP_CLI=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME sexpp CONFIG_PATH "lib/cmake/sexpp")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
