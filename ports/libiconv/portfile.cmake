include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libiconv-1.14)
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/libiconv/libiconv-1.14.tar.gz"
    FILENAME "libiconv-1.14.tar.gz"
    SHA512 b96774fefc4fa1d07948fcc667027701373c34ebf9c4101000428e048addd85a5bb5e05e59f80eb783a3054a3a8a3c0da909450053275bbbf3ffde511eb3f387
)
vcpkg_extract_source_archive(${ARCHIVE})

#Since libiconv uses automake, make and configure, we use a custom CMake file
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-Add-export-definitions.patch
            ${CMAKE_CURRENT_LIST_DIR}/0002-Config-for-MSVC.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/libiconv)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libiconv/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/libiconv/copyright)

# clean out the debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)