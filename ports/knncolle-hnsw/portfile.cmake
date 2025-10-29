vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_hnsw
    REF "v${VERSION}"
    SHA512 efedafc580aed0d0d33533aefa0183b1442e3496b18c7cfbdebce22555c3bbf8c4fdb83fc2db2a0ce50055a50ff402c41f93482121f06c04f09a03365b0cda31
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
