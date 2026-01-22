vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_kmknn
    REF "v${VERSION}"
    SHA512 96b8a11344454b4ac0a220e3301f7a167e7327b7656a252160ac5c04ca53fa55ce2b9db451a21e279f84d54d100516df1c47e2720ce91443736784bcf014ecc4
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKNNCOLLE_KMKNN_FETCH_EXTERN=OFF
        -DKNNCOLLE_KMKNN_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME knncolle_kmknn
    CONFIG_PATH lib/cmake/knncolle_kmknn
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
