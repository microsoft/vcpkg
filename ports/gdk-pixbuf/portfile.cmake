if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

set(GDK_PIXBUF_VERSION 2.36)
set(GDK_PIXBUF_PATCH 6)
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gdk-pixbuf-${GDK_PIXBUF_VERSION}.${GDK_PIXBUF_PATCH})
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/gdk-pixbuf/${GDK_PIXBUF_VERSION}/gdk-pixbuf-${GDK_PIXBUF_VERSION}.${GDK_PIXBUF_PATCH}.tar.xz"
    FILENAME "gdk-pixbuf-${GDK_PIXBUF_VERSION}.${GDK_PIXBUF_PATCH}.tar.xz"
    SHA512 b963f01161b58463c83499079545aa946fd824ec5e7167e0898698ac46e0cc3fb3dcb0cac5afabd6b7d957391b9c9bba55f340294076433155fc91052d5403ec)

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
