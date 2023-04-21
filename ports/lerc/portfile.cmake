vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Esri/lerc
    REF  v4.0.0
    SHA512 36fe453b6e732f6bed554d1c1c5cd4668aec63593d6de11f12b659c7b9cbc059ac9aaacc6cea483b3257d522f1b07e13c299914d08b1f8aeb0bb2cde42ba47cf
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
