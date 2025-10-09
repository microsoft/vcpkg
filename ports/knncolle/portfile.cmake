vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO knncolle/knncolle
    REF "v${VERSION}"
    SHA512 778f3b71cbc8dbbeddf26e24531e8f9b5f79927af8e89aa9782cc942fcd74fc65bf73141eb8fb0320394c07d19834068c653d8565b56af487bb5ea72b07ce875
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKNNCOLLE_FETCH_EXTERN=OFF
        -DKNNCOLLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME knncolle_knncolle
    CONFIG_PATH lib/cmake/knncolle_knncolle
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
