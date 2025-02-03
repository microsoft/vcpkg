vcpkg_download_distfile(
    PROTOBUF_V5_PATCH
    URLS https://github.com/apache/brpc/commit/282776acaf2c894791d2b5d4c294a28cfa2d4138.patch?full_index=1
    SHA512 2e62617ed56047a037f0e673a7dcc43e02c9bff46b6c9d1ae0098e4c73630f1a9a67c113e770bf1cc12d86d273f88f504f83af1ed69ee771f35cccac1a472990
    FILENAME 282776acaf2c894791d2b5d4c294a28cfa2d4138.patch
)

vcpkg_download_distfile(
    PROTOBUF_29_PATCH
    URLS https://github.com/apache/brpc/commit/8d1ee6d06ffdf84a33bd083463663ece5fb9e7a9.patch?full_index=1
    SHA512 d271aadc636c97bc3b2ad514558e7ae0f41af076b98346169f13f4e79be6165a69a9aa0da83c7db8ddfca5689e3d67afc8dd14ecd893f54441bde1135eafaf8e
    FILENAME 8d1ee6d06ffdf84a33bd083463663ece5fb9e7a9.patch
)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO apache/brpc
    REF "${VERSION}"
    SHA512 eb2f9528f055a31db5b2bbf57d302b17d2229d387c3bc6afd7dec5f3d21d1f882275d43d49c04cb5190442c2daa746ac2a174b3741d943e531ebbbd82526d510
    HEAD_REF master
    PATCHES
        fix-build.patch
        fix-warnings.patch
        ${PROTOBUF_V5_PATCH}
        ${PROTOBUF_29_PATCH}
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
