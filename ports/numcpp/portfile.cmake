# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dpilger26/NumCpp
    REF "Version_${VERSION}"
    SHA512 8474e38b2522b52235b38abb556c60284b7c44861b450f310bfa1a66938053006e47dde9106c73dad843bf049a2dd8988cbe2d2ba747a86f548c1f356f39e081
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME NumCpp CONFIG_PATH share/NumCpp/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
