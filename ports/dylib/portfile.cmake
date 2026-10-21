vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martin-olivier/dylib
    REF "v${VERSION}"
    SHA512 9975c202aacc698b0b30cec1d839e31eb4fc60d7ee54fc56a114d5e8905a2ac4757aa97fc580b3b1a3c98bdba1420a49707339a09a646e4e8663ef17fe3cded3
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME dylib
    CONFIG_PATH lib/cmake/dylib
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
