vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hyperrealm/libconfig
    REF "v${VERSION}"
    SHA512 c3ed6c8f500b449c4d94976745a3acba1c7176f87497d5cb0deb05e62f2ff009ca0636c7c9848601f6d92dd113d82983cbd1132735f0f2d4e40b32d257f4aaa7
    HEAD_REF master
    PATCHES
        static-build.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libconfig)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libconfig.h" "defined(LIBCONFIG_STATIC)" "1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libconfig.h++" "defined(LIBCONFIGXX_STATIC)" "1")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
