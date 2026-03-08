vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle
    REF "v${VERSION}"
    SHA512 d7bb80ae5ca31896f332a932d3762ff3e39d7b131c04d006516043a98e846ae86ebf360bab1caf6232f6c8624f156a584911ef00b42bf36722671734a26e0222
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
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
