
set(GTK_VERSION 4.0.1)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.gnome.org/sources/gtk/4.0/gtk-4.0.1.tar.xz"
    FILENAME "gtk-${GTK_VERSION}.tar.xz"
    SHA512 cab50b5bcf1a6bfdd5245c908e813330b9173531c49fdd63f9b5618f5329ddf2560f0a3548f61bba55dea6d816e57681d4e59941cfc50cf430544d3ebcd90aad
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES build.patch
            #link_fix_static.patch
)
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

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${OPTIONS}
        -Ddemos=false
        -Dbuild-examples=false
        -Dbuild-tests=false
        -Dinstall-tests=false
        -Dgtk_doc=false
        -Dman-pages=false
        -Dintrospection=disabled
        -Dsassc=enabled             # Rebuild themes using sassc
        -Dmedia-ffmpeg=disabled     # Build the ffmpeg media backend
        -Dmedia-gstreamer=disabled  # Build the gstreamer media backend
        -Dprint-cups=disabled       # Build the cups print backend
        -Dprint-cloudprint=disabled # Build the cloudprint print backend
        -Dvulkan=disabled           # Enable support for the Vulkan graphics API
        -Dxinerama=disabled         # Enable support for the X11 Xinerama extension
        -Dcloudproviders=disabled   # Enable the cloudproviders support
        -Dsysprof=disabled          # include tracing support for sysprof
        -Dtracker=disabled          # Enable Tracker3 filechooser search
        -Dcolord=disabled           # Build colord support for the CUPS printing backend
    ADDITIONAL_NATIVE_BINARIES glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
                               glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
                               gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'
                               glib-compile-schemas='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-schemas${VCPKG_HOST_EXECUTABLE_SUFFIX}'
                               sassc='${CURRENT_INSTALLED_DIR}/tools/sassc/bin/sassc${VCPKG_HOST_EXECUTABLE_SUFFIX}'
    ADDITIONAL_CROSS_BINARIES  glib-genmarshal='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-genmarshal'
                               glib-mkenums='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-mkenums'
                               glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
                               gdbus-codegen='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/gdbus-codegen'
                               glib-compile-schemas='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-schemas${VCPKG_HOST_EXECUTABLE_SUFFIX}'
                               sassc='${CURRENT_INSTALLED_DIR}/tools/sassc/bin/sassc${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_install_meson()

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
    #file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}${_path_suffix}/lib/gtk-4.0/4.0.0/media")
    #file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}${_path_suffix}/lib/gtk-4.0/4.0.0/immodules")
    #file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}${_path_suffix}/lib/gtk-4.0/4.0.0/printbackends")
    vcpkg_execute_required_process(
        COMMAND "${PYTHON3}" "${SOURCE_PATH}/build-aux/meson/post-install.py" 4.0 4.0.0 "${CURRENT_PACKAGES_DIR}${_path_suffix}/lib" "${CURRENT_PACKAGES_DIR}${_path_suffix}/share" "${CURRENT_PACKAGES_DIR}${_path_suffix}/bin"
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME post-install-${TARGET_TRIPLET}-${_short}
    )
    unset(ENV{PKG_CONFIG_PATH})
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}${_path_suffix}/lib/gtk-4.0")
    #file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}${_path_suffix}/bin/gtk-4.0")
    #file(RENAME "${CURRENT_PACKAGES_DIR}${_path_suffix}/lib/gtk-4.0/" "${CURRENT_PACKAGES_DIR}${_path_suffix}/bin/gtk-4.0")
    message(STATUS "Post install ${TARGET_TRIPLET}-${_short} done")
endforeach()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

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
