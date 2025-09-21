vcpkg_download_distfile(
    FIX_PROTOBUF_INT64_PATCH
    URLS https://github.com/apache/brpc/commit/ee9a9787126a0a66498d538e51768fa0bb54ff7f.patch?full_index=1
    SHA512 8794d268384a6daaf5f8067fd9de8ed712132bbac45df028d2850d916d96abf3273182e25a9fb33468a9f588db4a6b18206534125df0de502f7d3407e6abc056
    FILENAME fix_protobuf_int64.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/brpc
    REF "${VERSION}"
    SHA512 954be2562f598ca9a0939a96cb6f0af98dbbd9b3d191db613516239be63643ccfd1836eeb0510549f3526915af92e7c1b7f3cab4c55b0257cfc0a3c5eb4fb7dd
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-warnings.patch
        ${FIX_PROTOBUF_INT64_PATCH}
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
