vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Esri/lerc
    REF "js_v${VERSION}"
    SHA512 e7389576210e1fcc122b93194c20e5ea9c514514283695b8d770c3133ea1fdffdc06729552041aab2840c5aade676762b0d86e79bfc018fd57578987ad18e43a
    HEAD_REF master
    PATCHES
        "create_package.patch"
        "include_algorithm_for_std_min.patch"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-lerc)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/Lerc_c_api.h" "defined(LERC_STATIC)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/NOTICE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
