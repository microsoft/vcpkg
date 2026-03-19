vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/powerit
    REF "v${VERSION}"
    SHA512 86d42254a3ef0364ade61d902144750ac3b86e218cef565201a92044a05b39f53e99c25426e864a3bf15b24bbf0e26c6a807beb092cbdbdf962192ba9fd35f82
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPOWERIT_FETCH_EXTERN=OFF
        -DPOWERIT_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_powerit
    CONFIG_PATH lib/cmake/ltla_powerit
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
