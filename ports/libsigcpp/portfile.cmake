
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libsigc++-2.99.9)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.99/libsigc++-2.99.9.tar.xz"
    FILENAME "libsigc++-2.99.9.tar.xz"
    SHA512 3e8f8176a4618938a16b2367466415aff8ec10d83ef84de8973373a63fc0b9708d14115ad5c039c81b570385b205944651849a68e618c37c171cd748dd5b2403)

vcpkg_extract_source_archive(${ARCHIVE})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS_DEBUG
        -DSIGCPP_SKIP_HEADERS=ON)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/dont-import-symbols.patch)
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libsigcpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libsigcpp/COPYING ${CURRENT_PACKAGES_DIR}/share/libsigcpp/copyright)
