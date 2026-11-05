string(REGEX REPLACE "^([0-9]*[.][0-9]*)[.].*" "\\1" GNUTLS_BRANCH "${VERSION}")
vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
        "https://mirrors.dotsrc.org/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
    FILENAME "gnutls-${VERSION}.tar.xz"
    SHA512 71bf189a836fd18d58b9e995d4bfcecdb0aae6129dfd44247b98422b2f127dd868f9905d28fad2ca05afd919a0e6b3c8eebb6b95804067d3a8dab31ebdc72453
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${tarball}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        ccasflags.patch
        use-gmp-pkgconfig.patch
)

vcpkg_list(SET options)

if("nls" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-nls")
else()
    set(ENV{AUTOPOINT} true) # true, the program
    vcpkg_list(APPEND options "--disable-nls")
endif()
if ("openssl" IN_LIST FEATURES)
    vcpkg_list(APPEND options "--enable-openssl-compatibility")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_list(APPEND options "LIBS=\$LIBS -liconv -lcharset") # for libunistring
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_list(APPEND options "ac_cv_dlopen_soname_works=no") # ensure vcpkg libs
endif()

set(ENV{GTKDOCIZE} true) # true, the program
set(ENV{YACC} false)     # false, the program - not used here

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    LANGUAGES ASM C CXX
    OPTIONS
        --disable-dependency-tracking
        --disable-doc
        --disable-guile
        --disable-libdane
        --disable-maintainer-mode
        --disable-rpath
        --disable-tests
        --with-brotli=no
        --with-liboqs=no
        --with-p11-kit=no
        --with-tpm=no
        --with-tpm2=no
        --with-zlib=link
        --with-zstd=no
        ${options}
    OPTIONS_DEBUG
        --disable-tools
)
vcpkg_make_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tools(
    TOOL_NAMES
        certtool
        gnutls-cli
        gnutls-cli-debug
        gnutls-serv
        ocsptool
        psktool
    SEARCH_DIR "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    COMMENT [[
The main libraries (libgnutls and libdane) are released under the
GNU Lesser General Public License version 2.1 or later
(LGPLv2+, see COPYING.LESSERv2 for the license terms), and
the gnutls-openssl extra library and the application are under the
GNU General Public License version 3 or later
(GPLv3+, see COPYING for the license terms),
unless otherwise specified in the indivual source files.
]]
    FILE_LIST
        "${SOURCE_PATH}/COPYING.LESSERv2"
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/lib/inih/LICENSE.txt"
)
