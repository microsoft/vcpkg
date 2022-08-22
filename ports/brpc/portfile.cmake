vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/incubator-brpc
    REF 29491107cbf405a494aaf80ee32344ba34e1d7e4 #1.2.0
    SHA512 bd4c67967796592030903041ddb9205e24c9f196e63ebc153e08fbce723d93d27cd4f30f3c2cf904a93cda66ffa9db7d465d6e5fdac27a045ae84afad3dd1dc3
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-boost-ptr.patch
        brpc-1783.diff #https://github.com/apache/incubator-brpc/pull/1783
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
