set(warning_length 24)
string(LENGTH "${CURRENT_BUILDTREES_DIR}" buildtrees_path_length)
if(buildtrees_path_length GREATER warning_length AND CMAKE_HOST_WIN32)
    message(WARNING "${PORT}'s buildsystem uses very long paths and may fail on your system.\n"
        "We recommend moving vcpkg to a short path such as 'C:\\vcpkg' or using the subst command."
    )
endif()

vcpkg_from_gitlab(
    OUT_SOURCE_PATH SOURCE_PATH
    GITLAB_URL https://gitlab.gnome.org
    REPO GNOME/gtk
    REF 3.24.34
    SHA512 20a91e30a89070461af06b33829bc723b348806b4a785d0743af8bd4789b55dade24686e08bf1b2f0335240463aacc040134babb0605b809186b15de9cf261e4
    PATCHES
        0001-build.patch
)

vcpkg_find_acquire_program(PKGCONFIG)
get_filename_component(PKGCONFIG_DIR "${PKGCONFIG}" DIRECTORY )
vcpkg_add_to_path("${PKGCONFIG_DIR}") # Post install script runs pkg-config so it needs to be on PATH
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/glib/")
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/gdk-pixbuf")
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dwayland_backend=false
        -Ddemos=false
        -Dexamples=false
        -Dtests=false
        -Dgtk_doc=false
        -Dman=false
        -Dxinerama=no               # Enable support for the X11 Xinerama extension
        -Dcloudproviders=false      # Enable the cloudproviders support
        -Dprofiler=false            # include tracing support for sysprof
        -Dtracker3=false            # Enable Tracker3 filechooser search
        -Dcolord=no                 # Build colord support for the CUPS printing backend
        -Dintrospection=false
    ADDITIONAL_NATIVE_BINARIES
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'
        glib-compile-schemas='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-schemas${VCPKG_HOST_EXECUTABLE_SUFFIX}'
    ADDITIONAL_CROSS_BINARIES
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'
        glib-compile-schemas='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-schemas${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

set(GTK_TOOLS
    gtk-builder-tool
    gtk-encode-symbolic-svg
    gtk-launch
    gtk-query-immodules-3.0
    gtk-query-settings
    gtk-update-icon-cache
)
vcpkg_copy_tools(TOOL_NAMES ${GTK_TOOLS} AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/etc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
