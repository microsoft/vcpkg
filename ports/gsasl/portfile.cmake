vcpkg_download_distfile(ARCHIVE
    URLS
        "https://ftpmirror.gnu.org/gnu/gsasl/gsasl-${VERSION}.tar.gz"
        "https://ftp.gnu.org/gnu/gsasl/gsasl-${VERSION}.tar.gz"
    FILENAME "gsasl-${VERSION}.tar.gz"
    SHA512 62fb4a9383392e4816a036f3e8f408c5161a10723e59f0a8f6df5f72101e0b644787f3b07a71c772628fc4f4050960c842c7500736edacd24313ef654e703bc9
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        configure.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(CPPFLAGS_WINDOWS_STATIC "CPPFLAGS=\$CPPFLAGS -DGSASL_STATIC=1")
endif()

if("tool" IN_LIST FEATURES)
    vcpkg_list(APPEND FEATURE_OPTIONS --with-gsasl-tool)
endif()

set(ENV{AUTOPOINT} true)
set(ENV{GTKDOCIZE} true)
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        ${CPPFLAGS_WINDOWS_STATIC}
        ${FEATURE_OPTIONS}
        --disable-nls
        --disable-gssapi
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if("tool" IN_LIST FEATURES)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/gsasl.h" "defined GSASL_STATIC" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if("tool" IN_LIST FEATURES)
    list(APPEND tool_license_file "${SOURCE_PATH}/COPYING")
    set(tool_license_comment [[The GNU SASL Library is licensed under the GNU Lesser General Public License (LGPL) version 2.1 (or later).
The command-line application is licensed under the GNU General Public License license version 3.0 (or later).]]
)
endif()

vcpkg_install_copyright(
    COMMENT "${tool_license_comment}"
    FILE_LIST
    "${SOURCE_PATH}/COPYING.LESSER"
    ${tool_license_file}
)
