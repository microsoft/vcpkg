vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
string(SUBSTRING "${VERSION}" 5 -1 VERSION)

vcpkg_download_distfile(ARCHIVE
    URLS "https://snowballstem.org/dist/libstemmer_c-${VERSION}.tar.gz"
    FILENAME "libstemmer_c-${VERSION}.tar.gz"
    SHA512 6b76a94fd5bdb557c041c937bdfc1887927346a87c987fe3b964a7286e176543b578729e9d7ed97b521faee0d8b484df1aa9be23522b191a87f3a65dc12c5f15
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
