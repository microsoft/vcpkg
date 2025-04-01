vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ERGO-Code/HiGHS
    REF "v${VERSION}"
    SHA512 b6155859fda446725406fb062c7e89ea90b254767c680f31e1581eca6cdb3e68f6cf74abefac9c095a54a6dde6d6b14bec5e2429c79506acff9d5b0586e53a57
    HEAD_REF master
    PATCHES
        fix-hconfig-path.patch
        fix-uwp.patch
        fix-cuda.patch
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
