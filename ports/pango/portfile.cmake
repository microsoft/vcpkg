set(PANGO_VERSION 1.48.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/pango/1.48/pango-${PANGO_VERSION}.tar.xz"
    FILENAME "pango-${PANGO_VERSION}.tar.xz"
    SHA512 4819575a583134083819c1548d86bba71af97fd927f7cac05e3903b6d1c84de0ab1b593eea1e17b974f194e2d81123aa46e3af942eef258ad1bd14c72322342e)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${PANGO_VERSION}
    #PATCHES 0001-fix-static-symbols-export.diff
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dintrospection=disabled
        -Dfontconfig=enabled
        -Dsysprof=disabled
        -Dlibtahi=disabled
        -Dcairo=enabled
        -Dxft=disabled
        -Dfreetype=enabled
    ADDITIONAL_NATIVE_BINARIES glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
    ADDITIONAL_CROSS_BINARIES  glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES pango-view pango-list AUTO_CLEAN)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/pango.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" [[-I"${includedir}/pango-1.0"]] [[-I"${includedir}/pango-1.0" -I"${includedir}/harfbuzz"]])
endif()
set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/pango.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" [[-I"${includedir}/pango-1.0"]] [[-I"${includedir}/pango-1.0" -I"${includedir}/harfbuzz"]])
endif()
# option('gtk_doc',
       # description: 'Build API reference for Pango using GTK-Doc',
       # type: 'boolean',
       # value: false)
# option('introspection',
       # description: 'Build the GObject introspection data for Pango',
       # type: 'feature',
       # value: 'auto',
       # yield: true)
# option('install-tests',
       # description : 'Install tests',
       # type: 'boolean',
       # value: 'false')
# option('fontconfig',
       # description : 'Build with FontConfig support. Passing \'auto\' or \'disabled\' disables fontconfig where it is optional, i.e. on Windows and macOS. Passing \'disabled\' on platforms where fontconfig is required results in error.',
       # type: 'feature',
       # value: 'auto')
# option('sysprof',
       # type : 'feature',
       # value : 'disabled',
       # description : 'include tracing support for sysprof')
# option('libthai',
       # type : 'feature',
       # value : 'auto',
       # description : 'Build with libthai support')
# option('cairo',
       # type : 'feature',
       # value : 'auto',
       # description : 'Build with cairo support')
# option('xft',
       # type : 'feature',
       # value : 'auto',
       # description : 'Build with xft support')
# option('freetype',
       # type : 'feature',
       # value : 'auto',
       # description : 'Build with freetype support')
