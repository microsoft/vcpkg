vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brailcom/speechd
    REF "${VERSION}"
    SHA512 8747c2cd09e378533a8c756126623b659a5adce8991602f2c8a8e4318f24dee6fd518472095bfab31911d683c4624ad9909e1f2f5c3ab5412e574b067f50068d
    HEAD_REF master
    PATCHES
        libs-only.patch
)
set(ENV{AUTOPOINT} true)
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --enable-libs-only
        --disable-python
        --disable-doc
        --without-systemdsystemunitdir
        --without-systemduserunitdir
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LGPL")
