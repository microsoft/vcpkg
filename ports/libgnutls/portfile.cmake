string(REGEX REPLACE "^([0-9]*[.][0-9]*)[.].*" "\\1" GNUTLS_BRANCH "${VERSION}")
vcpkg_download_distfile(tarball
    URLS
        "https://gnupg.org/ftp/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
        "https://mirrors.dotsrc.org/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnupg.org/gcrypt/gnutls/v${GNUTLS_BRANCH}/gnutls-${VERSION}.tar.xz"
    FILENAME "gnutls-${VERSION}.tar.xz"
    SHA512 22e78db86b835843df897d14ad633d8a553c0f9b1389daa0c2f864869c6b9ca889028d434f9552237dc4f1b37c978fbe0cce166e3768e5d4e8850ff69a6fc872
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${tarball}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
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

if(VCPKG_CROSSCOMPILING)
    vcpkg_cmake_get_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    set(ccas "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
    cmake_path(GET ccas PARENT_PATH ccas_dir)
    vcpkg_add_to_path("${ccas_dir}")
    cmake_path(GET ccas FILENAME ccas_command)
    vcpkg_list(APPEND options "CCAS=${ccas_command}")
endif()

set(ENV{GTKDOCIZE} true) # true, the program
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-dependency-tracking
        --disable-doc
        --disable-guile
        --disable-libdane
        --disable-maintainer-mode
        --disable-rpath
        --disable-tests
        --with-brotli=no
        --with-p11-kit=no
        --with-tpm=no
        --with-tpm2=no
        --with-zstd=no
        ${options}
        YACC=false # false, the program - not used here
    OPTIONS_DEBUG
        --disable-tools
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/doc/COPYING"
        "${SOURCE_PATH}/doc/COPYING.LESSER"
)
