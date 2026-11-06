vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO caolanm/libwmf
    REF "v${VERSION}"
    SHA512 f6c48e557b9cb69910fc106db2fa497c44c0e5fc5088f353abdc981746db5a5015a4ee0749f0ec713da3d0275a1f5f9e27e93430d26b9cacb574cd28928e1714
    HEAD_REF master
    PATCHES
)


if("jpeg" IN_LIST FEATURES)
    list(APPEND OPTIONS --with-jpeg=yes)
else()
    list(APPEND OPTIONS --with-jpeg=no)
endif()

if(NOT "pixbuf" IN_LIST FEATURES)
    list(APPEND OPTIONS --disable-pixbuf)
endif()

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --with-sys-gd=yes
        --with-libxml2=yes
        --with-expat=no
        --without-x
        ${OPTIONS}
)

vcpkg_make_install()

set(FONTMAP_BIN "${CURRENT_PACKAGES_DIR}/tools/libwmf/bin/libwmf-fontmap")
if(EXISTS "${FONTMAP_BIN}")
    file(REMOVE_RECURSE "${FONTMAP_BIN}")
endif()
set(FONTMAP_BIN "${CURRENT_PACKAGES_DIR}/tools/libwmf/debug/bin/libwmf-fontmap")
if(EXISTS "${FONTMAP_BIN}")
    file(REMOVE_RECURSE "${FONTMAP_BIN}")
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
