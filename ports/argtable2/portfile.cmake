include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://prdownloads.sourceforge.net/argtable/argtable2-13.tar.gz"
    FILENAME "argtable-2.13.zip"
    SHA512 3d8303f3ba529e3241d918c0127a16402ece951efb964d14a06a3a7d29a252812ad3c44e96da28798871e9923e73a2cfe7ebc84139c1397817d632cae25c4585
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        fix-install-dirs.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
