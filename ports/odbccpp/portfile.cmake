vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SAP/odbc-cpp-wrapper
    REF "v${VERSION}"
    SHA512 1c72fd203021104b37bd01b0db67cff587ca4f03f19dbd8a026fda4437a6d89fed168feb3d3788287df60d5e3cd3450797cd97153826e069fb3d242e7f136f74
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