vcpkg_download_distfile(ARCHIVE
    URLS "http://dist.schmorp.de/liblzf/liblzf-${VERSION}.tar.gz"
    FILENAME "liblzf-${VERSION}.tar.gz"
    SHA512 701f70245a11e7cf3412b14ed26bf7b1464512d5b0cf3f913e70ebfdfe20574b8ebbae5a78f4b56ac0034d54830380309cac3057ca00a8028edbde3d091141f5
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        0001-add-extern-c.patch
        0002-fix-macro-expansion-ub.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/liblzf.def" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DVERSION=${VERSION}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-liblzf")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
