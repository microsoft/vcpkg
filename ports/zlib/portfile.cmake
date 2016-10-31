include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/zlib-1.2.8)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://zlib.net/zlib128.zip"
    FILENAME "zlib128.zip"
    SHA512 b0d7e71eca9032910c56fc1de6adbdc4f915bdeafd9a114591fc05701893004ef3363add8ad0e576c956b6be158f2fc339ab393f2dd40e8cc8c2885d641d807b
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSKIP_INSTALL_FILES=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/zlibstatic.lib ${CURRENT_PACKAGES_DIR}/debug/lib/zlibstaticd.lib)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/zlib.lib ${CURRENT_PACKAGES_DIR}/debug/lib/zlibd.lib)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/zlibstatic.lib ${CURRENT_PACKAGES_DIR}/lib/zlib.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/zlibstaticd.lib ${CURRENT_PACKAGES_DIR}/debug/lib/zlibd.lib)
endif()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/zlib RENAME copyright)

vcpkg_copy_pdbs()