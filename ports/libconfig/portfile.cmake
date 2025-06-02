vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hyperrealm/libconfig
    REF "v${VERSION}"
    SHA512 7899d3898e1741d90cf2381561b172ec6ba2bcc47d1b3e6058bcef74d73634d9be33eb8f99a58c7af15ac99e56800510edf3c412d9c1f136e6a3ab744455b992
    HEAD_REF master
    PATCHES
        static-build.diff
        include-stdint.patch
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
