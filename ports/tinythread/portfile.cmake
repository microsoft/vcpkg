vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "http://tinythreadpp.bitsnbites.eu/files/TinyThread%2B%2B-1.1-src.tar.bz2"
    FILENAME "TinyThread++-1.1.tar.bz2"
    SHA512 407f54fcf3f68dd7fec25e9e0749a1803dffa5d52d606905155714d29f519b5eae64ff654b11768fecc32c0123a78c48be37c47993e0caf157a63349a2f869c6
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL "${SOURCE_PATH}/README.txt" DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinythread RENAME copyright)
