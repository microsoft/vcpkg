vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Esri/lerc
    REF "js_v${VERSION}"
    SHA512 655fff837b6b76d04c08a6a3c9271cf04286750acab0a577f46764de9e5f5f3f7ce4bfd93b95606df74031ebbe032ca80636f6d150826e0ced977b964c494d81
    HEAD_REF master
    PATCHES
        create_package.patch
        cxx-linkage-pkgconfig.patch
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
