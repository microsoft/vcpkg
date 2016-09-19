include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE_FILE
    URL "http://downloads.sourceforge.net/project/expat/expat/2.1.1/expat-2.1.1.tar.bz2"
    FILENAME "expat-2.1.1.tar.bz2"
    MD5 7380a64a8e3a9d66a9887b01d0d7ea81
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/expat-2.1.1
    OPTIONS
        -DBUILD_examples=OFF
        -DBUILD_tests=OFF
        -DBUILD_tools=OFF
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/expat-2.1.1/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/expat RENAME copyright)
vcpkg_copy_pdbs()