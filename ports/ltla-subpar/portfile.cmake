vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/subpar
    REF "v${VERSION}"
    SHA512 5f939ab3112e381b50a4a837a05dede987f2a385a471a7fac8120f472d50aa228dcb2e5101c9d6d9a4f38e14fb0b76b03d77a021b85ec56fbf7b07edabbc5524
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSUBPAR_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_subpar
    CONFIG_PATH lib/cmake/ltla_subpar
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
