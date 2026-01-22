vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_hnsw
    REF "v${VERSION}"
    SHA512 3fb73a1b8cae2e93aecea41c2f0d14f83162553ff957136def98f49778b41545b4028c2edb4dd50fb4b97cd8f95a4b48352d124805d666f366f3b7875278dcff
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKNNCOLLE_HNSW_FETCH_EXTERN=OFF
        -DKNNCOLLE_HNSW_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME knncolle_hnsw
    CONFIG_PATH lib/cmake/knncolle_hnsw
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
