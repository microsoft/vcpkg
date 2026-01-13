string(REGEX MATCH "^([0-9]*[.][0-9]*)" VERSION_MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(SOURCE_ARCHIVE
    URLS
        "https://download.gnome.org/sources/pango/${VERSION_MAJOR_MINOR}/pango-${VERSION}.tar.xz"
        "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/${PORT}/${VERSION_MAJOR_MINOR}/${PORT}-${VERSION}.tar.xz"
    FILENAME "pango-${VERSION}.tar.xz"
    SHA512 e3d251e0c2d5cb7f2e9d26e675aa2fae0c3cedce9e73b77f92a4abbeff55eaa819811e4c064ca036d3964a3ee4592f596ebfa7c0a760189b9d8c38a5f3a4ea3a
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${SOURCE_ARCHIVE}"
    PATCHES
        relax-gi-requirement.diff
)

if("introspection" IN_LIST FEATURES)
    list(APPEND OPTIONS_RELEASE -Dintrospection=enabled)
    vcpkg_get_gobject_introspection_programs(PYTHON3 GIR_COMPILER GIR_SCANNER)
else()
    list(APPEND OPTIONS_RELEASE -Dintrospection=disabled)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Ddocumentation=false
        -Dman-pages=false
        -Dbuild-testsuite=false
        -Dbuild-examples=false
        -Dfontconfig=enabled # Build with FontConfig support.
        -Dsysprof=disabled # include tracing support for sysprof
        -Dlibthai=disabled # Build with libthai support
        -Dcairo=enabled # Build with cairo support
        -Dxft=disabled # Build with xft support
        -Dfreetype=enabled # Build with freetype support
        ${OPTIONS}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    OPTIONS_DEBUG
        -Dintrospection=disabled
    ADDITIONAL_BINARIES
        "glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'"
        "glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'"
        "g-ir-compiler='${GIR_COMPILER}'"
        "g-ir-scanner='${GIR_SCANNER}'"
)

vcpkg_install_meson(ADD_BIN_TO_PATH)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES pango-view pango-list pango-segmentation AUTO_CLEAN)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
