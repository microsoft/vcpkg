
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libsigc++-2.10.0)
vcpkg_download_distfile(ARCHIVE
    URLS "http://ftp.gnome.org/pub/GNOME/sources/libsigc++/2.10/libsigc++-2.10.0.tar.xz"
    FILENAME "libsigc++-2.10.0.tar.xz"
    SHA512 5b96df21d6bd6ba41520c7219e77695a86aabc60b7259262c7a9f4b8475ce0e2fd8dc37bcf7c17e24e818ff28c262d682b964c83e215b51bdbe000f3f58794ae)

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
