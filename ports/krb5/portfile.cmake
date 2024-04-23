vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO krb5/krb5
    REF krb5-${VERSION}-final
    SHA512 184ef8645d7e17f30a8e3d4005364424d2095b3d0c96f26ecef0c2dd2f3a096a0dd40558ed113121483717e44f6af41e71be0e5e079c76a205535d0c11a2ea34
    HEAD_REF master
    PATCHES
        remove_tests_apps_utils.patch
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}/src"
    AUTOCONFIG
    OPTIONS
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat1")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat5")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat7")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/krb5/cat8")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/krb5/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/krb5/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/var")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/var")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/krb5/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/krb5/debug/")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/doc/copyright.rst")
