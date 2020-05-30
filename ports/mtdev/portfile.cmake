vcpkg_download_distfile(ARCHIVE
    URLS "http://bitmath.org/code/mtdev/mtdev-1.1.6.tar.gz"
    FILENAME "mtdev-1.1.6.tar.gz"
    SHA512 e643264baa880abfc31b53f8e8ed54fe1adea4bc110fab57d36be16caba84f970c09fc864244c64b0a76e85f5f021fd086c12f96badbd886da6ccf254ab678e9
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL "export ACLOCAL=\"aclocal -I ${CURRENT_INSTALLED_DIR}/share/xorg-macros/aclocal/\""
    OPTIONS xorg_cv_malloc0_returns_null=yes
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
