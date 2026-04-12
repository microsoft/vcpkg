vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brailcom/speechd
    REF "${VERSION}"
    SHA512 0  # TODO: fill via  vcpkg hash <tarball>
    HEAD_REF master
    PATCHES
        libs-only.patch
)
set(ENV{AUTOPOINT} true)
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    DETERMINE_BUILD_TRIPLET
    OPTIONS
        --enable-libs-only
        --disable-python
        --disable-doc
        --without-systemdsystemunitdir
        --without-systemduserunitdir
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LGPL")
