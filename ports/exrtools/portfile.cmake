include(vcpkg_common_functions)

set(BASE_PATH ${CURRENT_BUILDTREES_DIR}/src/exrtools-0.4)
set(SOURCE_PATH ${BASE_PATH}/src)

vcpkg_download_distfile(ARCHIVE
    URLS "http://scanline.ca/exrtools/exrtools-0.4.tar.gz"
    FILENAME "exrtools-0.4.tar.gz"
    SHA512 8b24f948f1f9371fdf763782d67a2cd80bc1bb1b855886cc99f28ebbf73846e254c4f2ab6fb4c2e9c6f4993a1760dfbee2ee6c784582dfaf075ce863be31a6b1
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/remove_value_headers.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/cmake DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/getopt.h DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_TOOLS=ON -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_copy_tool_dependencies(tools/exrtools)

# Handle copyright
file(INSTALL ${BASE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/exrtools RENAME copyright)
