include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/zlib-1.2.10)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://zlib.net/zlib1210.zip"
    FILENAME "zlib1210.zip"
    SHA512 e1f0ffaa1d6d9c322d6fd30dc8fba202272205943b719e5d6525323e6773b4fcdd82885928c3f59b4bf7ca55babda9f379e174632bf3b25dc9067adb89f58409
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