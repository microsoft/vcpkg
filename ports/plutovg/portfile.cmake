vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sammycage/plutovg
    REF "v${VERSION}"
    SHA512 003048931c1d43d240c21473dae0485f2069328d873ea5496259889364f0c851dbf8a39c8fafe9ef02d1591c17b6830d6039f9b3329062901668ed5808335783
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPLUTOVG_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/plutovg)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/plutovg/plutovg.h" "defined(PLUTOVG_BUILD_STATIC)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
