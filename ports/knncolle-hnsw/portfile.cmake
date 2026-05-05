vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_hnsw
    REF "v${VERSION}"
    SHA512 4122b65f0513733a235b93bc09a3714d6e9a9538451f2f41c087ac4583a69682d411790e1db62246f331124f0924b57f04da66982d5082c450bae0c5b7f65273
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
