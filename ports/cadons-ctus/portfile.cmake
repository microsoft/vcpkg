vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Cadons/ctus
    REF ${VERSION}
    SHA512 79ad70b945d0cb9ac64838dd4e76fa2ed18aa58e63d6b2ecfa20d313f6cfe4b50e42294ebef71e25b7d87d24b5b511decdc4f695987500f8726906925dcc4a97
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ctus CONFIG_PATH lib/cmake/ctus)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
