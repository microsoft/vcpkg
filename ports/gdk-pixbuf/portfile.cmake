
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gdk-pixbuf-2.36.3)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/gdk-pixbuf/2.36/gdk-pixbuf-2.36.3.tar.xz"
    FILENAME "gdk-pixbuf-2.36.3.tar.xz"
    SHA512 b9c9fdf45445ceeb7f5039e73cfc803756c5b34574eae4958cdfb525036e1722ab996c1b439fdaa85e73b11069762aeec43e11cadce514d1701d0e43626f20de)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DGDK_SKIP_HEADERS=ON
        -DGDK_SKIP_TOOLS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/gdk-pixbuf)

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/gdk-pixbuf)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gdk-pixbuf/COPYING ${CURRENT_PACKAGES_DIR}/share/gdk-pixbuf/copyright)
