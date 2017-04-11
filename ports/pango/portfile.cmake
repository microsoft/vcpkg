
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)
set(PANGO_VERSION 1.40.4)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pango-${PANGO_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/pango/1.40/pango-${PANGO_VERSION}.tar.xz"
    FILENAME "pango-${PANGO_VERSION}.tar.xz"
    SHA512 8c7413f6712eaf9fd4bd92a9260a85e7e4bd5e1a03c4c89db139e1704e8681e9834f8b98394b9f4b87babd45155a15b6cffd583ad8f89a48a4849305d43aa613)

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
