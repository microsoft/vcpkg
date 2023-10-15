vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ERGO-Code/HiGHS
    REF "v${VERSION}"
    SHA512 9229d2e960354b8b8fd45588cd4eec7e54826ee6f3939ac691d7b2b6eb0580a66a3a2649c940a3869f58dbbcf08fdd9641919fc92666948c62e70c4bce8ac130
    HEAD_REF master
    PATCHES
        fix-hconfig-path.patch
        fix-cmake-output.patch
        fix-threads.patch
        fix-compiler.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DFAST_BUILD=ON
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/highs")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
