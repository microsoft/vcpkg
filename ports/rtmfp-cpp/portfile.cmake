vcpkg_download_distfile(ADD_CSTDINT
    URLS https://github.com/zenomt/rtmfp-cpp/commit/9c53bde974e6463537a4e5573a548e59eb45786c.diff?full_index=1
    FILENAME rtmfp-cpp-add-cstdint-9c53bde974e6463537a4e5573a548e59eb45786c.diff
    SHA512 7c6c4bf04f541c06a6f24b0e5033a26c13e1f985b5fa33bddcea8374e50e97bdfd768a2a16cb84ba0e67f1525036fd17af298053c909f48fd45f6974b1857d56
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zenomt/rtmfp-cpp
    REF "v${VERSION}"
    SHA512 cc8eac88c70b6a00a92a76bee66a3b319857a009fbfd82e9a710fe1c0fc452cf9fdf4128529e3f10931ed33c26eaf69253cab3b3e5a739eca6dd37a13f72800b
    HEAD_REF main
    PATCHES
        "${ADD_CSTDINT}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_REQUIRE_FIND_PACKAGE_OpenSSL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rtmfp)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
