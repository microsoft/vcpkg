include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/zlib-1.2.10)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://www.zlib.net/zlib-1.2.10.tar.gz"
    FILENAME "zlib1210.zip"
    SHA512 5fa71052a418a0f2b345fce28af9941bbd1c6ee276ce506ab3092157f15776ee41f96bb1799657227513b852913f96ac52dae8122a437f34b43933ee48d63ee0
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