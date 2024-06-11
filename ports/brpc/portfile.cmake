vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/brpc
    REF "${VERSION}"
    SHA512 a908c3cf63224d6fb98f1855aca75c3adf528c40da5180c6e298cc52ee9ccbef08809a81078333bdd6ac1a4af54448edac8dd4e0333e72e9dec2790454355e7a
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-glog.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_BRPC_TOOLS=OFF
        -DWITH_THRIFT=ON
        -DWITH_GLOG=ON
        -DDOWNLOAD_GTEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-brpc CONFIG_PATH share/unofficial-brpc)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/butil/third_party/superfasthash")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
