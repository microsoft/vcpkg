include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/alac_decoder)
vcpkg_download_distfile(ARCHIVE
    URLS "https://distfiles.macports.org/alac_decoder/alac_decoder-0.2.0.tgz"
    FILENAME "alac_decoder-0.2.0.tgz"
    SHA512 4b37d4fe37681bfccaa4a27fbaf11eb2a1fba5f14e77d219a6d9814ff44d1168534d05eb19443dd2fd11e6fcdf4da3a22e3f3c79314cb7a6767c152351b13e29
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/decomp.c DESTINATION ${SOURCE_PATH})


vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/remove_stdint_headers.patch
        ${CMAKE_CURRENT_LIST_DIR}/no-pragma-warning.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/alac-decoder)

file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/alac-decoder RENAME copyright)
