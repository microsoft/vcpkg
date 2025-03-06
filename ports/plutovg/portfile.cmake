vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sammycage/plutovg
    REF "v${VERSION}"
    SHA512 1abf7da813d00987dcf724c50e924659d76d49d13c9e37219ec151f3a7357501ae6b9c220613104623d9021db14eaa6c7cf81a79ecafd589eeaeab50a63f7031
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPLUTOVG_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/plutovg)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/plutovg/plutovg.h" "defined(PLUTOVG_BUILD_STATIC)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
