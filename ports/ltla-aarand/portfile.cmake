vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/aarand
    REF "v${VERSION}"
    SHA512 d14845b57e5dc6cfb62ba7354e76b53b5b06669fde6d5a740a5c41ee9802b67c2b11c80f677e51641e1915d8026e0bb1b7c83bedac73e0c8a2e24251b25a2022
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAARAND_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_aarand
    CONFIG_PATH lib/cmake/ltla_aarand
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
