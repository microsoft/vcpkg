vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stachenov/quazip
    REF v1.3
    SHA512 3861a9084059576ff2690e8b911394b0286a60542ab021a4cc588537a60ea3a186ed7903c76544698001fa383dfd0de96bdfed433abaefc44158d3b30ab16fe2
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/QuaZip-Qt5-1.3)
vcpkg_copy_pdbs()
if(VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/pkgconfig" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
else()
    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/" RENAME copyright)