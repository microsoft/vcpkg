vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO argtable/argtable
    REF argtable-2.13
    FILENAME "argtable2-13.tar.gz"
    SHA512 3d8303f3ba529e3241d918c0127a16402ece951efb964d14a06a3a7d29a252812ad3c44e96da28798871e9923e73a2cfe7ebc84139c1397817d632cae25c4585
    PATCHES
        0001-fix-install-dirs.patch
        0002-include-correct-headers.patch
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
