vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Esri/lerc
    REF "js_v${VERSION}"
    SHA512 061558d3b29e2d0968d1169ac422795faa6e70dd3425945194c1c87f4522422e186878b0235a5fc42f037c47c54964bf070b7644f8d652f33dc19f692a6ba0af
    HEAD_REF master
    PATCHES
        create_package.patch
        cxx-linkage-pkgconfig.patch
        fix-climits-include.patch
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
