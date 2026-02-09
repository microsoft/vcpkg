vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_hnsw
    REF "v${VERSION}"
    SHA512 b75fdc19862d53023119b9464cd2361bd70a17b1f27e899c5f3277431d55c9f7d18a749381b10f0841deebc35d51cea0f95e579b19c671b31eb3588bbd02de1e
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
