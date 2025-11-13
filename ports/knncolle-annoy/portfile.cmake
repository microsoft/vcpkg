vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_annoy
    REF "v${VERSION}"
    SHA512 1c6a98d189631355e124e1dcd8cfff0f3c8a45771dd2830d88530a84f6f4d58b7789f4e0484c5164f5b31cba6037c5724b89563982e3738c4a52d2ff811f9693
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
