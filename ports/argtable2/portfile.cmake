include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/argtable2-13)
vcpkg_download_distfile(ARCHIVE
    URLS "http://prdownloads.sourceforge.net/argtable/argtable2-13.tar.gz"
    FILENAME "argtable-2.13.zip"
    SHA512 3d8303f3ba529e3241d918c0127a16402ece951efb964d14a06a3a7d29a252812ad3c44e96da28798871e9923e73a2cfe7ebc84139c1397817d632cae25c4585
)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-install-dirs.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Remove duplicate include installs
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/argtable2 RENAME copyright)
