vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle_kmknn
    REF "v${VERSION}"
    SHA512 18779c0a03783d177072531c621a4ba8cc76097afe0d3182e32284382ac40219ee7acd746b650375b31dbb90ec4bd8c0eac5f4bdde8f0ab94a36b5870b6a69db
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
