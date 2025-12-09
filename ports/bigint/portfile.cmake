vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://mattmccutchen.net/bigint/bigint-2010.04.30.tar.bz2"
    FILENAME "bigint-2010.04.30.tar.bz2"
    SHA512 bb64380e51991f97a2489c04801ab4372f795b5e23870ad12d71087f1a2afba9b32f74dcdbdcb5228ebf0dd74a37185285bac7653dd3c62d6118d63c298689af
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES fix-osx-usage.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(INSTALL "${SOURCE_PATH}/README" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
