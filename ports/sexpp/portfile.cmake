vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rnpgp/sexpp
    REF 625afd6efd3e40aa50ac96d7323f966ef992db98
    SHA512 72b0e3b51fc2f532c081e54b2a61d145ebb2af149027f76c27b248c77a3264a67105590ab7fc2459174b145ff8d4f2170065676cda2b1adda527457967838c72
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
