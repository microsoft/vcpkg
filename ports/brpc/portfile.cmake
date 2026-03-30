vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/brpc
    REF "${VERSION}"
    SHA512 ffcd624550c060fdff01fad0fb752b4aa113dd1dea5ad6d688cb3d3964ded5a120df07f01bbc4a9b15aee226634fc6a851ab4c24fbed6ea07f31c305f6fef71f
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-warnings.patch
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
