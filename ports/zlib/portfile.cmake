include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/zlib-1.2.11)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://www.zlib.net/zlib-1.2.11.tar.gz" "https://downloads.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.gz"
    FILENAME "zlib1211.tar.gz"
    SHA512 73fd3fff4adeccd4894084c15ddac89890cd10ef105dd5e1835e1e9bbb6a49ff229713bd197d203edfa17c2727700fce65a2a235f07568212d820dca88b528ae
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSKIP_INSTALL_FILES=ON
    OPTIONS_DEBUG
        -DSKIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

# Both dynamic and static are built, so keep only the one needed
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