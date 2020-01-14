include(vcpkg_common_functions)

set(GTK_VERSION 3.22.19)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/gnome/sources/gtk+/3.22/gtk+-${GTK_VERSION}.tar.xz"
    FILENAME "gtk+-${GTK_VERSION}.tar.xz"
    SHA512 c83198794433ee6eb29f8740d59bd7056cd36808b4bff1a99563ab1a1742e6635dab4f2a8be33317f74d3b336f0d1adc28dd91410da056b50a08c215f184dce2
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${GTK_VERSION}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH})
configure_file(${SOURCE_PATH}/config.h.win32 ${SOURCE_PATH}/config.h COPYONLY)
configure_file(${SOURCE_PATH}/gdk/gdkconfig.h.win32_broadway ${SOURCE_PATH}/gdk/gdkconfig.h COPYONLY)

# generate sources using python script installed with glib
vcpkg_find_acquire_program(PYTHON3)
set(GLIB_TOOL_DIR ${CURRENT_INSTALLED_DIR}/tools/glib)

vcpkg_execute_required_process(
    COMMAND ${PYTHON3} ${GLIB_TOOL_DIR}/gdbus-codegen
        --interface-prefix org.Gtk.
        --c-namespace _Gtk
        --generate-c-code gtkdbusgenerated
        ./gtkdbusinterfaces.xml
    WORKING_DIRECTORY ${SOURCE_PATH}/gtk
    LOGNAME source-gen
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGTK_VERSION=${GTK_VERSION}
    OPTIONS_DEBUG
        -DGTK_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/etc/gtk-3.0)
file(WRITE ${CURRENT_PACKAGES_DIR}/etc/gtk-3.0/settings.ini "[Settings]
gtk-theme-name=win32
")

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gtk/COPYING ${CURRENT_PACKAGES_DIR}/share/gtk/copyright)
