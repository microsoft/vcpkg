set(CAIRO_VERSION 1.16.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/cairo-${CAIRO_VERSION}.tar.xz"
    FILENAME "cairo-${CAIRO_VERSION}.tar.xz"
    SHA512 9eb27c4cf01c0b8b56f2e15e651f6d4e52c99d0005875546405b64f1132aed12fbf84727273f493d84056a13105e065009d89e94a8bfaf2be2649e232b82377f
)

if(NOT VCPKG_TARGET_IS_MINGW AND VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES win_dll_def.patch)
endif()

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${CAIRO_VERSION}
    PATCHES
        export-only-in-shared-build.patch
        0001_fix_osx_defined.patch
        build2.patch
        remove_test_perf.patch
        ${PATCHES}
)

#TODO the autoconf script has a lot of additional option which use auto detection and should be disabled!
if("fontconfig" IN_LIST FEATURES)
    list(APPEND OPTIONS --enable-fc=yes)
else()
    list(APPEND OPTIONS --enable-fc=no)
endif()

if("freetype" IN_LIST FEATURES)
    list(APPEND OPTIONS --enable-ft=yes)
else()
    list(APPEND OPTIONS --enable-ft=no)
endif()

if ("x11" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "Feature x11 only support UNIX.")
    endif()
    message(WARNING "You will need to install Xorg dependencies to use feature x11:\napt install libx11-dev libxft-dev\n")
    list(APPEND OPTIONS --with-x --enable-xlib=yes)
else()
    list(APPEND OPTIONS --enable-xlib=no)
endif()

if("gobject" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        message(FATAL_ERROR "Feature gobject currently only supports dynamic build.")
    endif()
    list(APPEND OPTIONS --enable-gobject=yes)
else()
    list(APPEND OPTIONS --enable-gobject=no)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(ENV{CPP} "cl_cpp_wrapper")
endif()

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS ${OPTIONS}
        ax_cv_c_float_words_bigendian=no
        ac_cv_lib_z_compress=yes
        ac_cv_lib_lzo2_lzo2a_decompress=yes
        lt_cv_deplibs_check_method=pass_all
)
vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

set(_file "${CURRENT_PACKAGES_DIR}/include/cairo/cairo.h")
file(READ ${_file} CAIRO_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(REPLACE "defined (CAIRO_WIN32_STATIC_BUILD)" "1" CAIRO_H "${CAIRO_H}")
else()
    string(REPLACE "defined (CAIRO_WIN32_STATIC_BUILD)" "0" CAIRO_H "${CAIRO_H}")
endif()
file(WRITE ${_file} "${CAIRO_H}")


# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_copy_pdbs()

if(VCPKG_TARGET_IS_WINDOWS)
    set(ZLINK "-lzlibd")
else()
    set(ZLINK "-lz")
endif()
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cairo-script.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "Libs: ${ZLINK}" "Requires.private: lzo2 zlib\nLibs: -L\${libdir} -lcairo-script-interpreter")
    file(INSTALL "${_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/" RENAME cairo-script-interpreter.pc) #normally the *.pc file is named like the library
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    set(ZLINK "-lzlib")
endif()
set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/cairo-script.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "Libs: ${ZLINK}" "Requires.private: lzo2 zlib\nLibs: -L\${libdir} -lcairo-script-interpreter")
    file(INSTALL "${_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/" RENAME cairo-script-interpreter.pc) #normally the *.pc file is named like the library
endif()
vcpkg_fixup_pkgconfig()