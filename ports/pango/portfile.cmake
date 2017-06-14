include(vcpkg_common_functions)
set(PANGO_VERSION 1.40.6)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/pango-${PANGO_VERSION})
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/pango/1.40/pango-${PANGO_VERSION}.tar.xz"
    FILENAME "pango-${PANGO_VERSION}.tar.xz"
    SHA512 d916b364a77de3e68779e6d841d95bca456daf89405b92eaf51dceef093a9761cbb6c48f4c2971dec47c0bbdb645a3f3f4fb9af425274bf1d1822b278575e1f7)

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

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/pango)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pango/COPYING ${CURRENT_PACKAGES_DIR}/share/pango/copyright)
