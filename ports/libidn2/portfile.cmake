vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

set(IDN2_FILENAME "libidn2-${VERSION}.tar.gz")

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}" "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/libidn/${IDN2_FILENAME}"
    FILENAME "${IDN2_FILENAME}"
    SHA512 a6e90ccef56cfd0b37e3333ab3594bb3cec7ca42a138ca8c4f4ce142da208fa792f6c78ca00c01001c2bc02831abcbaf1cf9bcc346a5290fd7b30708f5a462f3
)

vcpkg_list(SET patches)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    # Fix linking static libidn2 into shared library
    # https://gitlab.com/libidn/libidn2/-/issues/80
    vcpkg_list(APPEND patches "fix-static-into-shared-linking.patch")
endif()

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        ${patches}
        disable-subdirs.patch
        fix-msvc.patch
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
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    COPY_SOURCE # include dir order problem
    USE_WRAPPERS
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

vcpkg_install_make()
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
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/COPYING.LESSERv3"
        "${SOURCE_PATH}/COPYINGv2"
        "${SOURCE_PATH}/COPYING.unicode"
)
