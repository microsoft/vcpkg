vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports unix platform" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gpg/libgcrypt
    REF libgcrypt-1.8.7
    SHA512 43e50a1b8a3cdbf420171c785fe558f443b414b708defa585277ac5ea59f9d8ae7f4555ed291c16fa004e7d4dd93a5ab2011c3c591e784ce3c6662a3193fd3e1
    HEAD_REF master
    PATCHES
        fix-pkgconfig.patch
)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --disable-doc
        --disable-silent-rules
        --with-libgpg-error-prefix=${CURRENT_INSTALLED_DIR}/tools/libgpg-error
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig() 
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
