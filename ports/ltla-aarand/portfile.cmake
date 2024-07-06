vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/aarand
    REF 84d48b65d49ce8b844398f11aff3015b86e17197
    SHA512 78b175055768dd8b0abab421b66d0d16ad9bc23f1d1406d774874d4ea12b11e199554ccf6a6ef02d10ef96ad5f652863e403aa3ec9522211958c78d243821ee5
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
