include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libssh2-1.8.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://www.libssh2.org/download/libssh2-1.8.0.tar.gz"
    FILENAME "libssh2-1.8.0.tar.gz"
    SHA512 289aa45c4f99653bebf5f99565fe9c519abc204feb2084b47b7cc3badc8bf4ecdedd49ea6acdce8eb902b3c00995d5f92a3ca77b2508b92f04ae0e7de7287558
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/0001-Fix-UWP.patch
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DENABLE_ZLIB_COMPRESSION=ON
    OPTIONS_DEBUG
        -DENABLE_DEBUG_LOGGING=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share)

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libssh2)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libssh2 RENAME copyright)

vcpkg_copy_pdbs()