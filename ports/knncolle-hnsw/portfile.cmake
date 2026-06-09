vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_hnsw
    REF "v${VERSION}"
    SHA512 0a5fa19c39c2c2069cfed74a5335e8372102389facf14c3d99646a5e9032d6485e249c85849a3cb84eec96702b6147478c9b126f5ff438d17317704f0e566ff3
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
