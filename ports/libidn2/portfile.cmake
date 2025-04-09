set(IDN2_FILENAME "libidn2-${VERSION}.tar.gz")

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}"
         "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}"
    FILENAME "${IDN2_FILENAME}"
    SHA512 eab5702bc0baed45492f8dde43a4d2ea3560ad80645e5f9e0cfa8d3b57bccd7fd782d04638e000ba07924a5d9f85e760095b55189188c4017b94705bef9b4a66
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        disable-subdirs.patch
        fix-uwp.patch
)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    vcpkg_list(APPEND options "--disable-nls")
endif()
set(ENV{AUTOPOINT} true) # true, the program

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_list(APPEND options "CPPFLAGS=\$CPPFLAGS -DIDN2_STATIC")
endif()

set(ENV{GTKDOCIZE} true)
vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    COPY_SOURCE # include dir order problem
    OPTIONS
        ${options}
        --disable-gtk-doc
        --disable-doc
        --disable-gcc-warnings
    OPTIONS_RELEASE
        "--with-libiconv-prefix=${CURRENT_INSTALLED_DIR}"
        "--with-libunistring-prefix=${CURRENT_INSTALLED_DIR}"
    OPTIONS_DEBUG
        "--with-libiconv-prefix=${CURRENT_INSTALLED_DIR}/debug"
        "--with-libunistring-prefix=${CURRENT_INSTALLED_DIR}/debug"
        "CFLAGS=\$CFLAGS -I${CURRENT_INSTALLED_DIR}/include"
)

vcpkg_make_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/idn2.h" "defined IDN2_STATIC" "1")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
)

vcpkg_install_copyright(
    COMMENT [[
The installed C library libidn2 is dual-licensed under LGPLv3+|GPLv2+,
while the rest of the package is GPLv3+.
]]
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/COPYING.LESSERv3"
        "${SOURCE_PATH}/COPYINGv2"
        "${SOURCE_PATH}/COPYING.unicode"
)
