vcpkg_download_distfile(
    ARCHIVE
    URLS "https://nice.freedesktop.org/releases/libnice-0.1.15.tar.gz"
    FILENAME "libnice-0.1.15.tar.gz"
    SHA512 60a8bcca06c0ab300dfabbf13e45aeac2085d553c420c5cc4d2fdeb46b449b2b9c9aee8015b0662c16bd1cecf5a49824b7e24951a8a0b66a87074cb00a619c0c
)
vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
   )

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_RELEASE -DOPTIMIZE=1
    OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(COPY ${SOURCE_PATH}/COPYING.LGPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(COPY ${SOURCE_PATH}/COPYING.MPL DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
