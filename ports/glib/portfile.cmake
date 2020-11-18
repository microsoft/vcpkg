# Glib uses winapi functions not available in WindowsStore
vcpkg_fail_port_install(ON_TARGET "UWP")

# Glib relies on DllMain on Windows
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

set(GLIB_VERSION 2.65.2)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/gnome/sources/glib/2.65/glib-${GLIB_VERSION}.tar.xz"
    FILENAME "glib-${GLIB_VERSION}.tar.xz"
    SHA512 9a2ebd226b2d0bcd7fbfeeff7a0dd48f7a604636a19672dae5c0547dd8abe5f2bf3bd505e48797095f740775bac5e8eeb1230e754b9d03171d7d04c2363432fc)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GLIB_VERSION}
    PATCHES
        remove_tests.patch
        #use-libiconv-on-windows.patch
        #arm64-defines.patch
        #fix-arm-builds.patch
)


if (selinux IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_WINDOWS AND NOT EXISTS "/usr/include/selinux")
    message("Selinux was not found in its typical system location. Your build may fail. You can install Selinux with \"apt-get install selinux\".")
    list(APPEND OPTIONS -Dselinux=enabled)
else()
    list(APPEND OPTIONS -Dselinux=disabled)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -Diconv=external)
else()
    #list(APPEND OPTIONS -Diconv=libc) ?
endif()

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dbuild_tests=false
        ${OPTIONS}
        
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

set(GLIB_TOOLS  gdbus
                gio
                gio-querymodules
                glib-compile-resources
                glib-compile-schemas
                gobject-query
                gresource
                gsettings
                )
if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND GLIB_TOOLS gapplication glib-gettextize gtester)
endif()
set(GLIB_SCRIPTS gdbus-codegen glib-genmarshal glib-mkenums gtester-report)


if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "x64|arm64")
    list(APPEND GLIB_TOOLS  gspawn-win64-helper${VCPKG_EXECUTABLE_SUFFIX}
                            gspawn-win64-helper-console${VCPKG_EXECUTABLE_SUFFIX})
elseif(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    list(APPEND GLIB_TOOLS  gspawn-win32-helper${VCPKG_EXECUTABLE_SUFFIX}
                            gspawn-win32-helper-console${VCPKG_EXECUTABLE_SUFFIX})
endif()
vcpkg_copy_tools(TOOL_NAMES ${GLIB_TOOLS} AUTO_CLEAN)
foreach(script IN LISTS GLIB_SCRIPTS)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    
IF(VCPKG_TARGET_IS_WINDOWS)
    set(SYSTEM_LIBRARIES dnsapi iphlpapi winmm lshlwapi)
else()
    set(SYSTEM_LIBRARIES resolv mount blkid selinux)
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gio-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/gio-2.0.pc" "\${bindir}" "\${bindir}/../tools/${PORT}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gio-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/gio-2.0.pc" "\${bindir}" "\${bindir}/../../tools/${PORT}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/glib-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/glib-2.0.pc" "\${bindir}" "\${bindir}/../tools/${PORT}")
endif()
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glib-2.0.pc")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glib-2.0.pc" "\${bindir}" "\${bindir}/../../tools/${PORT}")
endif()
vcpkg_fixup_pkgconfig(NOT_STATIC_PKGCONFIG SYSTEM_LIBRARIES ${SYSTEM_LIBRARIES} IGNORE_FLAGS "-Wl,--export-dynamic")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)



# option('runtime_libdir',
       # type : 'string',
       # value : '',
       # description : 'install runtime libraries relative to libdir')

# option('iconv',
       # type : 'combo',
       # choices : ['auto', 'libc', 'external'],
       # value : 'auto',
       # description : 'iconv implementation to use (\'libc\' = \'Part of the C library\'; \'external\' = \'External libiconv\'; \'auto\' = \'Auto-detect which iconv is available\')')

# option('charsetalias_dir',
       # type : 'string',
       # value : '',
       # description : 'directory for charset.alias dir (default to \'libdir\' if unset)')

# option('gio_module_dir',
       # type : 'string',
       # value : '',
       # description : 'load gio modules from this directory (default to \'libdir/gio/modules\' if unset)')

# option('selinux',
       # type : 'feature',
       # value : 'auto',
       # description : 'build with selinux support')

# option('xattr',
       # type : 'boolean',
       # value : true,
       # description : 'build with xattr support')

# option('libmount',
       # type : 'feature',
       # value : 'auto',
       # description : 'build with libmount support')

# option('internal_pcre',
       # type : 'boolean',
       # value : false,
       # description : 'whether to use internal PCRE')

# option('man',
       # type : 'boolean',
       # value : false,
       # description : 'generate man pages (requires xsltproc)')

# option('dtrace',
       # type : 'boolean',
       # value : false,
       # description : 'include tracing support for dtrace')

# option('systemtap',
       # type : 'boolean',
       # value : false,
       # description : 'include tracing support for systemtap')

# option('tapset_install_dir',
       # type : 'string',
       # value : '',
       # description : 'path where systemtap tapsets are installed')

# option('sysprof',
       # type : 'feature',
       # value : 'disabled',
       # description : 'include tracing support for sysprof')

# option('gtk_doc',
       # type : 'boolean',
       # value : false,
       # description : 'use gtk-doc to build documentation')

# option('bsymbolic_functions',
       # type : 'boolean',
       # value : true,
       # description : 'link with -Bsymbolic-functions if supported')

# option('force_posix_threads',
       # type : 'boolean',
       # value : false,
       # description : 'Also use posix threads in case the platform defaults to another implementation (on Windows for example)')

# option('fam',
       # type : 'boolean',
       # value : false,
       # description : 'Use fam for file system monitoring')

# option('installed_tests',
       # type : 'boolean',
       # value : false,
       # description : 'enable installed tests')

# option('nls',
       # type : 'feature',
       # value : 'auto',
       # yield: true,
       # description : 'Enable native language support (translations)')

# option('oss_fuzz',
       # type : 'feature',
       # value : 'disabled',
       # description : 'Indicate oss-fuzz build environment')

# option('glib_assert',
       # type : 'boolean',
       # value : true,
       # yield : true,
       # description : 'Enable GLib assertion (see docs/macros.txt)')

# option('glib_checks',
       # type : 'boolean',
       # value : true,
       # yield : true,
       # description : 'Enable GLib checks such as API guards (see docs/macros.txt)')

