
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)
set(PANGO_VERSION 1.40.5)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pango-${PANGO_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/pango/1.40/pango-${PANGO_VERSION}.tar.xz"
    FILENAME "pango-${PANGO_VERSION}.tar.xz"
    SHA512 40e8bf85dbb4b6fd35da3acec06a0d2b9dde95a3c5a212d243dbcbc0d00f12bd061757a04cb2f4a8db61329efd7ed9be53e3f5d6a2eb2a3defba1d12f9eed43d)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
	OPTIONS_DEBUG
	    -DPANGO_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pango)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pango/COPYING ${CURRENT_PACKAGES_DIR}/share/pango/copyright)
