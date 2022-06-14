vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/incubator-brpc
    REF 06247c18ed6307613f04c0d2357cb91d0c14131b
    SHA512 f31b1ce3bd99dd585686ec540c9713d5d5936b2d58aadfb3f0ef48faeaab1797f2373e14b73578c2f9f8355d1e9d03661e2ed9ed8c4349b4e43e510d2214b5ae
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-boost-ptr.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
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
