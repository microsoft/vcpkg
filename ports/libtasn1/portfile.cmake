set(VERSION 4.17.0)

if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES msvc_fixes.patch)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libtasn1/libtasn1-${VERSION}.tar.gz"
    FILENAME "libtasn1-${VERSION}.tar.gz"
    SHA512 9cbd920196d1e4c8f5aa613259cded2510d40edb583ce20cc2702e2dee9bf32bee85a159c74600ffbebc2af2787e28ed0fe0adf15fc46839283747f4fe166d3d
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
    PATCHES
        ${PATCHES}
)

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
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --disable-doc
        --disable-gtk-doc
        --disable-gcc-warnings
        ${EXTRA_OPTS}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools" "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
