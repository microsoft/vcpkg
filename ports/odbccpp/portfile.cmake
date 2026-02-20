vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SAP/odbc-cpp-wrapper
    REF "v${VERSION}"
    SHA512 49e7d47c039119e1bccf89975801978f0e7f68b5aedabfd2c3d2fd6b439a6c0139e3afd52b497bad15496b0009bd431e5bb88cf9c4cd06c3bf16feca11bd7a24
    HEAD_REF master
    PATCHES
        use-vcpkg-unixodbc.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGTEST_FOUND=OFF
        -DDOXYGEN_FOUND=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")