include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bigint-2010.04.30)
vcpkg_download_distfile(ARCHIVE
    URLS "https://mattmccutchen.net/bigint/bigint-2010.04.30.tar.bz2"
    FILENAME "bigint-2010.04.30.tar.bz2"
    SHA512 bb64380e51991f97a2489c04801ab4372f795b5e23870ad12d71087f1a2afba9b32f74dcdbdcb5228ebf0dd74a37185285bac7653dd3c62d6118d63c298689af
)
vcpkg_extract_source_archive(${ARCHIVE})

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/bigint RENAME copyright)
