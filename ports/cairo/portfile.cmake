set(CAIRO_VERSION 1.17.4)

if(NOT VCPKG_TARGET_IS_MINGW AND VCPKG_TARGET_IS_WINDOWS)
    set(PATCHES win_dll_def.patch)
endif()
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cairo/cairo
    REF 156cd3eaaebfd8635517c2baf61fcf3627ff7ec2 #v1.17.4
    SHA512 2c516ad3ffe56cf646b2435d6ef3cf25e8c05aeb13d95dd18a7d0510d134d9990cba1b376063352ff99483cfc4e5d2af849afd2f9538f9136f22d44d34be362c
    HEAD_REF master
    PATCHES #export-only-in-shared-build.patch
            #0001_fix_osx_defined.patch
            #build2.patch
            #remove_test_perf.patch
            #${PATCHES}
) 

if("fontconfig" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dfontconfig=enabled)
else()
    list(APPEND OPTIONS -Dfontconfig=disabled)
endif()

if("freetype" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dfreetype=enabled)
else()
    list(APPEND OPTIONS -Dfreetype=disabled)
endif()

if ("x11" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "Feature x11 only support UNIX.")
    endif()
    message(WARNING "You will need to install Xorg dependencies to use feature x11:\napt install libx11-dev libxft-dev\n")
    list(APPEND OPTIONS -Dxlib=enabled)
else()
    list(APPEND OPTIONS -Dxlib=disabled)
endif()
list(APPEND OPTIONS -Dxcb=disabled)
list(APPEND OPTIONS -Dxlib-xcb=disabled)

if("gobject" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        message(FATAL_ERROR "Feature gobject currently only supports dynamic build.")
    endif()
    list(APPEND OPTIONS -Dglib=enabled)
else()
    list(APPEND OPTIONS -Dglib=disabled)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(ENV{CPP} "cl_cpp_wrapper")
endif()

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${OPTIONS}
            -Dtests=disabled
            -Dzlib=enabled
            -Dpng=enabled
            -Dspectre=auto
            -Dsymbol-lookup=disabled
            -Dgtk2-utils=disabled
)
#More options
# Cairo surface backends
# option('cogl', type : 'feature', value : 'disabled')
# option('directfb', type : 'feature', value : 'disabled')
# option('gl-backend', type : 'combo', value : 'disabled',
       # # FIXME: https://github.com/mesonbuild/meson/issues/4566
       # choices : ['auto', 'gl', 'glesv2', 'glesv3', 'disabled'])
# option('glesv2', type : 'feature', value : 'disabled')
# option('glesv3', type : 'feature', value : 'disabled')
# option('drm', type : 'feature', value : 'disabled')
# option('openvg', type : 'feature', value : 'disabled')
# option('quartz', type : 'feature', value : 'auto')
# option('qt', type : 'feature', value : 'disabled')
# option('tee', type : 'feature', value : 'disabled')

vcpkg_install_meson()

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
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_copy_pdbs()

#if(VCPKG_TARGET_IS_WINDOWS)
#    set(ZLINK "-lzlibd")
#else()
#    set(ZLINK "-lz")
#endif()
#set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cairo-script.pc")
#if(EXISTS "${_file}")
#    vcpkg_replace_string("${_file}" "Libs: ${ZLINK}" "Requires.private: lzo2 zlib\nLibs: -L\${libdir} -lcairo-script-interpreter")
#    file(INSTALL "${_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/" RENAME cairo-script-interpreter.pc) #normally the *.pc file is named like the library
#endif()
#if(VCPKG_TARGET_IS_WINDOWS)
#    set(ZLINK "-lzlib")
#endif()
#set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/cairo-script.pc")
#if(EXISTS "${_file}")
#    vcpkg_replace_string("${_file}" "Libs: ${ZLINK}" "Requires.private: lzo2 zlib\nLibs: -L\${libdir} -lcairo-script-interpreter")
#    file(INSTALL "${_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/" RENAME cairo-script-interpreter.pc) #normally the *.pc file is named like the library
#endif()
vcpkg_fixup_pkgconfig()
