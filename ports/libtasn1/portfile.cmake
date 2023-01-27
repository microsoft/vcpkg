vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libtasn1/libtasn1-${VERSION}.tar.gz"
    FILENAME "libtasn1-${VERSION}.tar.gz"
    SHA512 287f5eddfb5e21762d9f14d11997e56b953b980b2b03a97ed4cd6d37909bda1ed7d2cdff9da5d270a21d863ab7e54be6b85c05f1075ac5d8f0198997cf335ef4
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    SOURCE_BASE "v${VERSION}"
    PATCHES
        msvc_fixes.patch
)

vcpkg_find_acquire_program(BISON)

set(EXTRA_OPTS "")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # $LIBS is an environment variable that vcpkg already pre-populated with some libraries. 
    # We need to re-purpose it when passing LIBS option to make to avoid overriding the vcpkg's own list.  
    list(APPEND EXTRA_OPTS "LIBS=-lgettimeofday -lgetopt \$LIBS")
else()
    # restore the default ac_cv_prog_cc_g flags, otherwise it fails to compile
    set(VCPKG_C_FLAGS "-g -O2") 
    set(VCPKG_CXX_FLAGS "-g -O2")
endif()

# The upstream doesn't add this macro to the configure
if (VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND EXTRA_OPTS "CFLAGS=\$CFLAGS -DASN1_STATIC")
endif()

set(ENV{GTKDOCIZE} true)
vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        --disable-doc
        --disable-gtk-doc
        --disable-gcc-warnings
        ${EXTRA_OPTS}
        "YACC=${BISON}"
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${SOURCE_PATH}/doc/COPYING.LESSER"
        "${SOURCE_PATH}/doc/COPYING"
)
