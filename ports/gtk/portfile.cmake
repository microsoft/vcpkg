vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/gtk
    REF  12bd668f4debe6000b5e2aaa0aa2fe7031045a84 #v4.9.2
    SHA512 c19f29898b760270dacf258e9f0044f5eb6c08a626b9896d16c93ae94707ad05080f7c42b8c40bbd23405d871a8ee6693066cc740fe32c81e02aa49727269c74
    HEAD_REF master # branch name
    PATCHES
        0001-build.patch
        0002-windows-build.patch
        0004-macos-build.patch
)

vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/libxml2") # for xmllint

vcpkg_find_acquire_program(PKGCONFIG)
get_filename_component(PKGCONFIG_DIR "${PKGCONFIG}" DIRECTORY )
vcpkg_add_to_path("${PKGCONFIG_DIR}") # Post install script runs pkg-config so it needs to be on PATH
vcpkg_add_to_path("${CURRENT_HOST_INSTALLED_DIR}/tools/glib/")

set(x11 false)
set(win32 false)
set(osx false)
if(VCPKG_TARGET_IS_LINUX)
    set(OPTIONS -Dwayland-backend=false) # CI missing at least wayland-protocols
    set(x11 true)
    # Enable the wayland gdk backend (only when building on Unix except for macOS)
elseif(VCPKG_TARGET_IS_WINDOWS)
    set(win32 true)
elseif(VCPKG_TARGET_IS_OSX)
    set(osx true)
endif()

list(APPEND OPTIONS -Dx11-backend=${x11}) #Enable the X11 gdk backend (only when building on Unix)
list(APPEND OPTIONS -Dbroadway-backend=false) #Enable the broadway (HTML5) gdk backend
list(APPEND OPTIONS -Dwin32-backend=${win32}) #Enable the Windows gdk backend (only when building on Windows)
list(APPEND OPTIONS -Dmacos-backend=${osx}) #Enable the macOS gdk backend (only when building on macOS)

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
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${OPTIONS}
        -Ddemos=false
        -Dbuild-examples=false
        -Dbuild-tests=false
        -Dgtk_doc=false
        -Dman-pages=false
        -Dmedia-ffmpeg=disabled     # Build the ffmpeg media backend
        -Dmedia-gstreamer=disabled  # Build the gstreamer media backend
        -Dprint-cups=disabled       # Build the cups print backend
        -Dvulkan=disabled           # Enable support for the Vulkan graphics API
        -Dcloudproviders=disabled   # Enable the cloudproviders support
        -Dsysprof=disabled          # include tracing support for sysprof
        -Dtracker=disabled          # Enable Tracker3 filechooser search
        -Dcolord=disabled           # Build colord support for the CUPS printing backend
    OPTIONS_DEBUG
        ${OPTIONS_DEBUG}
    OPTIONS_RELEASE
        ${OPTIONS_RELEASE}
    ADDITIONAL_NATIVE_BINARIES
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'
        glib-compile-schemas='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-schemas${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        sassc='${CURRENT_HOST_INSTALLED_DIR}/tools/sassc/bin/sassc${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-compiler='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-scanner='${GIR_TOOL_DIR}/tools/gobject-introspection/g-ir-scanner'
    ADDITIONAL_CROSS_BINARIES
        glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
        glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
        glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'
        glib-compile-schemas='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-schemas${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        sassc='${CURRENT_HOST_INSTALLED_DIR}/tools/sassc/bin/sassc${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-compiler='${CURRENT_HOST_INSTALLED_DIR}/tools/gobject-introspection/g-ir-compiler${VCPKG_HOST_EXECUTABLE_SUFFIX}'
        g-ir-scanner='${GIR_TOOL_DIR}/tools/gobject-introspection/g-ir-scanner'
)

vcpkg_install_meson(ADD_BIN_TO_PATH)

# If somebody finds out how to access and forward env variables to
# the meson install script be my guest. Nevertheless the script still
# needs manual execution in the crosscompiling case.
vcpkg_find_acquire_program(PYTHON3)
foreach(_config release debug)
    if(_config STREQUAL "release")
        set(_short rel)
        set(_path_suffix)
    else()
        set(_short dbg)
        set(_path_suffix /debug)
    endif()
    if(NOT EXISTS "${CURRENT_PACKAGES_DIR}${_path_suffix}/lib")
        continue()
    endif()
    message(STATUS "Running post install script: ${TARGET_TRIPLET}-${_short}")

    set(PKGCONFIG_INSTALLED_DIR "${CURRENT_INSTALLED_DIR}${_path_suffix}/lib/pkgconfig/")
    set(ENV{PKG_CONFIG_PATH} "${PKGCONFIG_INSTALLED_DIR}")

    message(STATUS "Post install ${TARGET_TRIPLET}-${_short} done")
endforeach()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

set(TOOL_NAMES gtk4-builder-tool
               gtk4-encode-symbolic-svg
               gtk4-query-settings
               gtk4-update-icon-cache)
if(VCPKG_TARGET_IS_LINUX)
    list(APPEND TOOL_NAMES gtk4-launch)
endif()
vcpkg_copy_tools(TOOL_NAMES ${TOOL_NAMES} AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
