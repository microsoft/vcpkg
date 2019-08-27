include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/charls-2.0.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/team-charls/charls/archive/2.0.0.tar.gz"
    FILENAME "charls-2.0.0.tar.gz"
    SHA512 0a2862fad6d65b941c81f5f838db1fdc6a4625887281ddbf27e21be9084f607d27c8a27d246d6252e08358b2ed4aa0c2b7407048ca559fb40e94313ca72487dd
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/License.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/charls RENAME copyright)

vcpkg_copy_pdbs()