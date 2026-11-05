vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/brpc
    REF "${VERSION}"
    SHA512 5574ac729ad1ecac4ddccf5d56a2f02ae95acb7f542c23a0b4c8f43a9bd9915694431d37a93f81f61da2d638f195616f6a47b59de55e4cf6f7fe7fa790ffebb6
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-warnings.patch
        disable-ubshm-without-ubring.patch
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

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/NOTICE"
    "${SOURCE_PATH}/src/butil/third_party/snappy/snappy.h"
    "${SOURCE_PATH}/src/butil/third_party/snappy/snappy-stubs-internal.h"
    "${SOURCE_PATH}/src/butil/third_party/symbolize/LICENSE"
)
