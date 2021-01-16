set(PANGO_VERSION 1.48.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/pango/1.48/pango-${PANGO_VERSION}.tar.xz"
    FILENAME "pango-${PANGO_VERSION}.tar.xz"
    SHA512 e4ac40f8da9c326e1e4dfaf4b1d2070601b17f88f5a12991a9a8bbc58bb08640404e2a794a5c68c5ebb2e7e80d9c186d4b26cd417bb63a23f024ef8a38bb152a)

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
        -Dintrospection=false
        -Dfontconfig=true
        -Dsysprof=disabled
        -Dlibtahi=false
        -Dcairo=true
        -Dxft=false
        -Dfreetype=true
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

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
