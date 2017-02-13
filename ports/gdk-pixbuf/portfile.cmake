
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gdk-pixbuf-2.36.5)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/gdk-pixbuf/2.36/gdk-pixbuf-2.36.5.tar.xz"
    FILENAME "gdk-pixbuf-2.36.5.tar.xz"
    SHA512 27c39bace7bc6cf713915dcb1f35eebfb80ae599d1c9106f48af4cd447050c41e37adee76d29d6b42fbe3d0123b054c8701f2d1b4b99060b4869aa7871523b70)

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
