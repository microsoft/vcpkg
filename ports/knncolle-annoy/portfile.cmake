vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_annoy
    REF "v${VERSION}"
    SHA512 8fa9565fee81058819c2c1aefd17d156eec861d5d829c87c8c5b503ded101deb8b9f098281dc3805ab7f949c176a2c243527fd4207127f53e7a57037965c8c98
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKNNCOLLE_ANNOY_FETCH_EXTERN=OFF
        -DKNNCOLLE_ANNOY_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME knncolle_annoy
    CONFIG_PATH lib/cmake/knncolle_annoy
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
