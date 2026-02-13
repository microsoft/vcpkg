
vcpkg_download_distfile(ARCHIVE
    URLS "https://archive.apache.org/dist/arrow/apache-arrow-nanoarrow-${VERSION}/apache-arrow-nanoarrow-${VERSION}.tar.gz"
    FILENAME "apache-arrow-nanoarrow-${VERSION}.tar.gz"
    SHA512 98f9f4c8dada0175e39e02d2baa01d0f63ad94636925cd289cbffa423de26bf0ede437aaa1ec10ff91e7d375e72cfddd950d040602520ab7891ab4c6337ce4f7
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(REMOVE_RECURSE "${SOURCE_PATH}/thirdparty")

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "dynamic" NANOARROW_INSTALL_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOARROW_INSTALL_SHARED=${NANOARROW_INSTALL_SHARED}
        -DNANOARROW_DEBUG_EXTRA_WARNINGS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME nanoarrow
    CONFIG_PATH lib/cmake/nanoarrow
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake" "${CURRENT_PACKAGES_DIR}/lib/cmake")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
