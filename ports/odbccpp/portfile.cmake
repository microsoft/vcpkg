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
        -DCMAKE_DISABLE_FIND_PACKAGE_GTest=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")