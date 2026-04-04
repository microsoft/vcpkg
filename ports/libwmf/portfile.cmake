vcpkg_download_distfile(ZLIB_LIBPNG_PATCH
    URLS https://github.com/caolanm/libwmf/commit/65f830d3a8269353012e6880bd70e3f392bb3727.patch?full_index=1
    SHA512 c45cc74e2861e272744bf38a31b1359c2235f91d25b8e7f62b61a9a712083080661d6040aaffb34274606a1d8964757abbcec23dbaa39890ba1be73614ce8be9
    FILENAME zlib_libpng.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO caolanm/libwmf
    REF "v${VERSION}"
    SHA512 e95ab312ac06add60f278b9fa8cebb20bd8bd53b98f7159fe1ebc206cbcad1a186ef2ce4dd6c3c271dcad037e9b685493cda1267d4ebf9638906584eedb4f960
    HEAD_REF master
    PATCHES
        "${ZLIB_LIBPNG_PATCH}"
)

set(FONTMAP "${CURRENT_INSTALLED_DIR}/share/libwmf/fonts/fontmap")
set(FONTDIR "${CURRENT_INSTALLED_DIR}/share/libwmf/fonts")

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --without-x
        --with-xtrafontmap="${FONTMAP}"
        --with-fontdir="${FONTDIR}"
)

vcpkg_make_install()

set(LIBWMF_FONTMAP "${CURRENT_PACKAGES_DIR}/tools/libwmf/bin/libwmf-fontmap")
vcpkg_replace_string("${LIBWMF_FONTMAP}" "\"${FONTMAP}\"" [=["$(cd "$(dirname "${0}")" && pwd)"/../../../share/libwmf/fonts/fontmap]=])
vcpkg_replace_string("${LIBWMF_FONTMAP}" "\"${FONTDIR}\"" [=["$(cd "$(dirname "${0}")" && pwd)"/../../../share/libwmf/fonts]=])

set(LIBWMF_FONTMAP "${CURRENT_PACKAGES_DIR}/tools/libwmf/debug/bin/libwmf-fontmap")
if(EXISTS "${LIBWMF_FONTMAP}")
    vcpkg_replace_string("${LIBWMF_FONTMAP}" "\"${FONTMAP}\"" [=["$(cd "$(dirname "${0}")" && pwd)"/../../../../share/libwmf/fonts/fontmap]=])
    vcpkg_replace_string("${LIBWMF_FONTMAP}" "\"${FONTDIR}\"" [=["$(cd "$(dirname "${0}")" && pwd)"/../../../../share/libwmf/fonts]=])
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
