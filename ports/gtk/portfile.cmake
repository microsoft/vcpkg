
include(vcpkg_common_functions)
set(GTK_VERSION 3.22.11)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gtk+-${GTK_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/gnome/sources/gtk+/3.22/gtk+-${GTK_VERSION}.tar.xz"
    FILENAME "gtk+-${GTK_VERSION}.tar.xz"
    SHA512 0dd8c0b8cf01a687bd7b9548308a8719fda4a30e0b47139db049906333d23c1eee3867af130dc3ecd0fb4a1381c8065e9929ccd9cb4def376bbb0b136ec05a7e)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH})

# generate sources using python script installed with glib
if(NOT EXISTS ${SOURCE_PATH}/gtk/gtkdbusgenerated.h OR NOT EXISTS ${SOURCE_PATH}/gtk/gtkdbusgenerated.c)
    vcpkg_find_acquire_program(PYTHON3)
    set(GLIB_TOOL_DIR ${CURRENT_INSTALLED_DIR}/tools/glib)

    vcpkg_execute_required_process(
        COMMAND ${PYTHON3} ${GLIB_TOOL_DIR}/gdbus-codegen --interface-prefix org.Gtk. --c-namespace _Gtk --generate-c-code gtkdbusgenerated ./gtkdbusinterfaces.xml
        WORKING_DIRECTORY ${SOURCE_PATH}/gtk
        LOGNAME source-gen)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGTK_VERSION=${GTK_VERSION}
    OPTIONS_DEBUG
        -DGTK_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gtk)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gtk/COPYING ${CURRENT_PACKAGES_DIR}/share/gtk/copyright)
