vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gpg/libassuan
    REF libassuan-2.5.3
    SHA512 5ec896eca6d9d7bec83aa400c8e2dc6f2b09c013050efb2125e2f2a4bd00f179723254483637ca4b7bc30bba951fc985e7ba7db98081606bb106caa7a2622dbe
    HEAD_REF master
    PATCHES
        fix-pkgconfig.patch
        fix-flags.patch
)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        --disable-doc
        --disable-silent-rules
        --with-libgpg-error-prefix=${CURRENT_INSTALLED_DIR}/tools/libgpg-error
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libassuan/bin/libassuan-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../..")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libassuan/debug/bin/libassuan-config" "${CURRENT_INSTALLED_DIR}" "`dirname $0`/../../../..")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
