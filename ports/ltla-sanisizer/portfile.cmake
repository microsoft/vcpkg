vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/sanisizer
    REF "v${VERSION}"
    SHA512 945bb8aa680503300fc2fca72075df203f8413f9b002ea17f3c56445a83b722a8f33a152f96c8ea2af20d99cef3f570bab4453e13a8db4eb2ee2cd7cbbffe3e0
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSANISIZER_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_sanisizer
    CONFIG_PATH lib/cmake/ltla_sanisizer
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
