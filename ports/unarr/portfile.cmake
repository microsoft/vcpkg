vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO selmf/unarr
    REF "v${VERSION}"
    SHA512 da170e0391fbe92e9b2474beb6be9a96c9f905e4e572235aa839cda3f6faf3cb99773eede34e1054138a4997bf68a18ee84f4df47add202355449634c0fd6d93
    HEAD_REF master
    PATCHES
        debundle-7zip.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/lzmasdk")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_7Z=ON
        -DUSE_SYSTEM_BZ2=ON
        -DUSE_SYSTEM_LZMA=ON
        -DUSE_SYSTEM_ZLIB=ON
        -DUSE_ZLIB_CRC=ON
        -DBUILD_INTEGRATION_TESTS=OFF
        -DBUILD_FUZZER=OFF
        -DBUILD_UNIT_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/unarr")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
