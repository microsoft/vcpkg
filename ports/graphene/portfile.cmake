vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/graphene/1.10/graphene-${VERSION}.tar.xz"
    FILENAME "graphene-${VERSION}.tar.xz"
    SHA512 c56dab6712cf58387d0512a213cd0cd456679e46a495ee5cfd9bc25440cda2d72d56974af4e462f3c863869a1e2e506b702f468933045609d35fdf006212c67d
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        fix_clang-cl.patch
)

if("introspection" IN_LIST FEATURES)
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        message(FATAL_ERROR "Feature introspection currently only supports dynamic build.")
    endif()
    list(APPEND OPTIONS_DEBUG -Dintrospection=disabled)
    list(APPEND OPTIONS_RELEASE -Dintrospection=enabled)
else()
    list(APPEND OPTIONS -Dintrospection=disabled)
endif()

if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(GIR_TOOL_DIR ${CURRENT_INSTALLED_DIR})
else()
    set(GIR_TOOL_DIR ${CURRENT_HOST_INSTALLED_DIR})
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgtk_doc=false #Enable generating the API reference (depends on GTK-Doc)
        -Dgobject_types=true #Enable GObject types (depends on GObject)
        -Dtests=false
        -Dinstalled_tests=false
        ${OPTIONS}
    OPTIONS_DEBUG
        ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    ADDITIONAL_BINARIES
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        g-ir-compiler='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-scanner='${GIR_TOOL_DIR}/tools/gobject-introspection/g-ir-scanner'
)

vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
