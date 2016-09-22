include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE_FILE
    URL "http://zlib.net/zlib128.zip"
    FILENAME "zlib128.zip"
    SHA512 b0d7e71eca9032910c56fc1de6adbdc4f915bdeafd9a114591fc05701893004ef3363add8ad0e576c956b6be158f2fc339ab393f2dd40e8cc8c2885d641d807b
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/zlib-1.2.8
    OPTIONS
        -DSKIP_INSTALL_FILES=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_build_cmake()
vcpkg_install_cmake()

file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/zlibstatic.lib ${CURRENT_PACKAGES_DIR}/debug/lib/zlibstaticd.lib)
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zlib RENAME copyright)
vcpkg_copy_pdbs()
