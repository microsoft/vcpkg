vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zenomt/rtmfp-cpp
    REF "v${VERSION}"
    SHA512 cc8eac88c70b6a00a92a76bee66a3b319857a009fbfd82e9a710fe1c0fc452cf9fdf4128529e3f10931ed33c26eaf69253cab3b3e5a739eca6dd37a13f72800b
    HEAD_REF main
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
