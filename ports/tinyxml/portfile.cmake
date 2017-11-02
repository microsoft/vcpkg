include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tinyxml)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/tinyxml/files/tinyxml/2.6.2/tinyxml_2_6_2.tar.gz"
    FILENAME "tinyxml_2_6_2.tar.gz"
    SHA512 133b5db06131a90ad0c2b39b0063f1c8e65e67288a7e5d67e1f7d9ba32af10dc5dfa0462f9723985ee27debe8f09a10a25d4b5a5aaff2ede979b1cebe8e59d56
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_use_stl.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyxml RENAME copyright)
