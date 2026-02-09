vcpkg_download_distfile(
    PROTOBUF_V6_PATCH
    URLS https://github.com/apache/brpc/commit/8d87814330d9ebbfe5b95774fdb71056fcb3170c.patch?full_index=1
    SHA512 d8787b11f91b50377869713f9f9159a36659c8f4ca43e77105968b3918c95cb13dbcaef6170329bd2eaa5e7455d00636cfa6db2fd99e8aace293a0e7e1b3df75
    FILENAME 8d87814330d9ebbfe5b95774fdb71056fcb3170c.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/brpc
    REF "${VERSION}"
    SHA512 93366c2b073de8a1af5ededa9ef5a6803ccd393bbb5fe1f9872c230e4997995759517fa4dd1a51ffd120a5c9040dcb00b1c580c5ccf032dd70561c0c3283f990
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-warnings.patch
        ${PROTOBUF_V6_PATCH}
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_BRPC_TOOLS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DWITH_THRIFT=ON
        -DWITH_GLOG=ON
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-brpc CONFIG_PATH share/unofficial-brpc)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/unofficial-brpc/unofficial-brpc-targets.cmake"
    "add_library(unofficial::brpc::brpc-"
    "add_library(#[[skip-usage-heuristics]] unofficial::brpc::brpc-"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/butil/third_party/superfasthash")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
