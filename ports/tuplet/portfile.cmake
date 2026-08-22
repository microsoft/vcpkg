# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO codeinred/tuplet
    REF "v${VERSION}"
    SHA512 afab0ad34e9e15909c43112b77014821607ec8d429c395b882eea74873432204fca2b5a2c2e04f84cf6193e19bc0a9dcb7702d1e97668a32ec1541e02b6e798a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_INSTALL_INCLUDEDIR=include
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME tuplet CONFIG_PATH share/tuplet/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
)
# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
