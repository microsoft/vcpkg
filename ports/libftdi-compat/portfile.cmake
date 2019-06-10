include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.intra2net.com/en/developer/libftdi/download/libftdi-0.20.tar.gz"
    FILENAME "libftdi-0.20.tar.gz"
    SHA512 540e5eb201a65936c3dbabff70c251deba1615874b11ff27c5ca16c39d71c150cf61758a68b541135a444fe32ab403b0fba0daf55c587647aaf9b3f400f1dee7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF v0.20
    PATCHES
        usb-header.patch
        cmake-fix.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake/FindUSB.cmake DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY  ${CMAKE_CURRENT_LIST_DIR}/cmake/LibFTDIConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libftdi-compat)
file(COPY  ${CMAKE_CURRENT_LIST_DIR}/cmake/LibFTDIConfigVersion.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libftdi-compat)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libftdi-compat)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libftdi-compat/LICENSE ${CURRENT_PACKAGES_DIR}/share/libftdi-compat/copyright)

vcpkg_copy_pdbs()
