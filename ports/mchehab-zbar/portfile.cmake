vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mchehab/zbar
    REF "${VERSION}"
    SHA512 d73d71873bec68ee021997512a9edbd223f5f5fe43c66c4dd3502224ba6009be2e5e1714766cb8e1056244673e87e0939ed0319116f61d7371b5ab79fb5e04eb
    HEAD_REF master
    PATCHES
        c99.patch
        issue219.patch
        windows.patch
        x64.patch
)

vcpkg_list(SET options)
if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    vcpkg_list(APPEND options "--disable-nls")
    set(ENV{AUTOPOINT} true) # true, the program
    file(TOUCH "${SOURCE_PATH}/po/Makefile.in.in")
    # Get missing build-time m4 files from gettext source
    set(gettext_version 0.21.1)
    vcpkg_download_distfile(gettext_archive
        URLS "https://ftp.gnu.org/pub/gnu/gettext/gettext-${gettext_version}.tar.gz"
             "https://www.mirrorservice.org/sites/ftp.gnu.org/gnu/gettext/gettext-${gettext_version}.tar.gz"
        FILENAME "gettext-${gettext_version}.tar.gz"
        SHA512 ccd43a43fab3c90ed99b3e27628c9aeb7186398153b137a4997f8c7ddfd9729b0ba9d15348567e5206af50ac027673d2b8a3415bb3fc65f87ad778f85dc03a05
    )
    file(ARCHIVE_EXTRACT INPUT "${gettext_archive}"
        DESTINATION "${SOURCE_PATH}/gettext-autoconf"
        PATTERNS "*/gettext-runtime/m4/gettext.m4"
                 "*/gettext-runtime/m4/iconv.m4"
                 "*/gettext-runtime/m4/intlmacosx.m4"
                 "*/gettext-runtime/m4/nls.m4"
                 "*/gettext-runtime/m4/po.m4"
                 "*/gettext-runtime/m4/progtest.m4"
                 "*/gettext-runtime/gnulib-m4/host-cpu-c-abi.m4"
                 "*/gettext-runtime/gnulib-m4/lib-ld.m4"
                 "*/gettext-runtime/gnulib-m4/lib-link.m4"
                 "*/gettext-runtime/gnulib-m4/lib-prefix.m4"
    )
    file(GLOB_RECURSE m4_files "${SOURCE_PATH}/gettext-autoconf/*/*.m4")
    file(INSTALL ${m4_files} DESTINATION "${SOURCE_PATH}/config")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    ADD_BIN_TO_PATH # checking for working iconv
    OPTIONS
        ${options}
        --without-dbus
        --without-gtk
        --without-imagemagick
        --without-java
        --without-jpeg
        --without-python
        --without-qt
        --disable-video
        --without-xv
    OPTIONS_RELEASE
        --disable-assert
)

vcpkg_install_make()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/tools"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
