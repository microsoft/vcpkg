vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hyperrealm/libconfig
    REF "v${VERSION}"
    SHA512 3749bf9eb29bab0f6b14f4fc759f0c419ed27a843842aaabed1ec1fbe0faa8c93322ff875ca1291d69cb28a39ece86d512aec42c2140d566c38c56dc616734f4
    HEAD_REF master
    PATCHES
        libconfig++-cmake-export.diff
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libconfig.h" "defined(LIBCONFIG_STATIC)" "1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libconfig.h++" "defined(LIBCONFIGXX_STATIC)" "1")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
