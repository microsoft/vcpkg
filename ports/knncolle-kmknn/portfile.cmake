vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_kmknn
    REF "v${VERSION}"
    SHA512 2e6716f33d5bb7addfe2bbed2ea9664e40c791cefb3e4526e7da770d00c02ac956f69b1808a4e94dd22ec803039780c13c41fe43913edfe767e1904e0b9248b3
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
