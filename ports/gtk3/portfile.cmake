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
    REF "${VERSION}"
    SHA512 ffb52ee34074be6e88fda40a025044b653d05b69c35819eed159a020a6f1c881a83735aa7bec943470c465328bb3bb20b34afeb3b98cdcfca9d2eaaed3ab61ef
    PATCHES
        0001-build.patch
        cairo-cpp-linkage.patch
)

vcpkg_find_acquire_program(PKGCONFIG)
get_filename_component(PKGCONFIG_DIR "${PKGCONFIG}" DIRECTORY )
vcpkg_add_to_path("${PKGCONFIG_DIR}") # Post install script runs pkg-config so it needs to be on PATH
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/glib/")
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/gdk-pixbuf")
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/gettext/bin")


vcpkg_list(SET ADDITIONAL_BINARIES)
if("introspection" IN_LIST FEATURES)
    list(APPEND OPTIONS_DEBUG -Dintrospection=false)
    list(APPEND OPTIONS_RELEASE -Dintrospection=true)
    if(CMAKE_HOST_WIN32 AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(GIR_TOOL_DIR "${CURRENT_INSTALLED_DIR}")
    else()
        set(GIR_TOOL_DIR "${CURRENT_HOST_INSTALLED_DIR}")
    endif()
    vcpkg_list(APPEND ADDITIONAL_BINARIES
        "g-ir-compiler='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'"
        "g-ir-scanner='${GIR_TOOL_DIR}/tools/gobject-introspection/g-ir-scanner'"
    )
else()
    list(APPEND OPTIONS -Dintrospection=false)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
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
    OPTIONS_DEBUG
        ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    ADDITIONAL_BINARIES
        "glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'"
        "glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'"
        "glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'"
        "gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'"
        "glib-compile-schemas='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-schemas${VCPKG_HOST_EXECUTABLE_SUFFIX}'"
        ${ADDITIONAL_BINARIES}
)

# Reduce command line lengths, in particular for static windows builds.
foreach(dir IN ITEMS "${TARGET_TRIPLET}-dbg" "${TARGET_TRIPLET}-rel")
    if(EXISTS "${CURRENT_BUILDTREES_DIR}/${dir}/build.ninja")
        vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${dir}/build.ninja" "/${dir}/../src/" "/src/")
    endif()
endforeach()
vcpkg_install_meson(ADD_BIN_TO_PATH)

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

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

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
