vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/optional
    REF "v${VERSION}"
    SHA512 3911F397440D4383721B92DE614DE1BEF5DB5C88371FA35F008B92F673F1E1EBF46E98FCFF4CD2D71E558C89537B9128AD549777197FD0390ED18A5BDFC5D6E0
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPTIONAL_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/tl-optional)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/cmake")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
