vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/incubator-brpc
    REF "${VERSION}"
    SHA512 c9779e2bf4a69228ba37960101844f2d33c1a442204d5630e7e191d11b496831a61f1d5da37813b135f24c491bd7d23eb18fa0de9423ac7e13bbf84d8fc48fb8
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-boost-ptr.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DWITH_THRIFT=ON
        -DWITH_MESALINK=OFF
        -DWITH_GLOG=ON
        -DDOWNLOAD_GTEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-brpc CONFIG_PATH share/unofficial-brpc)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/butil/third_party/superfasthash")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
