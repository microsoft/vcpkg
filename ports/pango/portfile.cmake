include(vcpkg_common_functions)
set(PANGO_VERSION 1.40.11)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pango-${PANGO_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/pango/1.40/pango-${PANGO_VERSION}.tar.xz"
    FILENAME "pango-${PANGO_VERSION}.tar.xz"
    SHA512 e4ac40f8da9c326e1e4dfaf4b1d2070601b17f88f5a12991a9a8bbc58bb08640404e2a794a5c68c5ebb2e7e80d9c186d4b26cd417bb63a23f024ef8a38bb152a)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001-fix-static-symbols-export.diff)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS_DEBUG
	    -DPANGO_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pango)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pango/COPYING ${CURRENT_PACKAGES_DIR}/share/pango/copyright)
