vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle
    REF "v${VERSION}"
    SHA512 0c1c552e9e86dfe6243c673c0f6e942f0a788a0b9b4ff3382c8f7d75e01057b8d30f9332f023d1c5e29f955ddd41ae1f18b303a4579490b3147c3248188c43bd
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKNNCOLLE_FETCH_EXTERN=OFF
        -DKNNCOLLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME knncolle_knncolle
    CONFIG_PATH lib/cmake/knncolle_knncolle
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
