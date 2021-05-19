set(VERSION 4.16.0)

if(VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES msvc_fixes.patch)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libtasn1/libtasn1-${VERSION}.tar.gz"
    FILENAME "libtasn1-${VERSION}.tar.gz"
    SHA512 b356249535d5d592f9b59de39d21e26dd0f3f00ea47c9cef292cdd878042ea41ecbb7c8d2f02ac5839f5210092fe92a25acd343260ddf644887b031b167c2e71
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${VERSION}
    PATCHES
        ${PATCHES}
)

if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    # $LIBS is an environment variable that vcpkg already pre-populated with some libraries. 
    # We need to re-purpose it when passing LIBS option to make to avoid overriding the vcpkg's own list.  
    set(EXTRA_OPTS "LIBS=\"$LIBS -lgettimeofday -lgetopt\"")
else()
    # restore the default ac_cv_prog_cc_g flags, otherwise it fails to compile
    set(EXTRA_OPTS)
    set(VCPKG_C_FLAGS "-g -O2") 
    set(VCPKG_CXX_FLAGS "-g -O2")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    # These are hacks for MSVC since autoconf can't determine the absolute path correctly
    foreach(H stdint limits string stddef sys_types)
        find_file(H_PATH "${H}.h" PATHS $ENV{INCLUDE} NO_DEFAULT_PATH)
        string(REPLACE "\\" "/" H_PATH "${H_PATH}")
        list(APPEND EXTRA_OPTS "gl_cv_next_${H}_h='\"${H_PATH}\"'")
    endforeach()
endif()

set(ENV{GTKDOCIZE} true)

vcpkg_configure_make(
    USE_WRAPPERS
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        --disable-gtk-doc
        --disable-gcc-warnings
        ${EXTRA_OPTS}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/tools ${CURRENT_PACKAGES_DIR}/debug/share)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
