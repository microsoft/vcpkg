vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://tinythreadpp.bitsnbites.eu/files/TinyThread%2B%2B-1.1-src.tar.bz2"
    FILENAME "TinyThread++-1.1.tar.bz2"
    SHA512 407f54fcf3f68dd7fec25e9e0749a1803dffa5d52d606905155714d29f519b5eae64ff654b11768fecc32c0123a78c48be37c47993e0caf157a63349a2f869c6
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

file(INSTALL "${SOURCE_PATH}/README.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
