vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ERGO-Code/HiGHS
    REF "v${VERSION}"
    SHA512 c5759440cdcb4be02a464ba8f43bc63fd7edc3837bcd71392719a81ea60a564e164b0ecce5784eac03fda97f26ce0495c108f3c77299a1ea039b26d060fd1689
    HEAD_REF master
    PATCHES
        fix-hconfig-path.patch
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
vcpkg_copy_tools(TOOL_NAMES highs AUTO_CLEAN)
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/highs")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
