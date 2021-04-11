vcpkg_download_distfile(
    OUT_SOURCE_PATH SOURCE_PATH
    URLS "https://github.com/mirror/ncurses/archive/refs/tags/v6.2.tar.gz"
    FILENAME "ncurses-6.2.tar.gz"
    SHA512 89eea695388837b5a6c51b3e8aa984ec51afdeba7652448992f1a0c83acc7a537fc8f9fef7f8ae438aadc06d6810f09add4b129c46a61b1bc5d4c0e4bf5f767e
)

vcpkg_extract_source_archive_ex(
    SKIP_PATCH_CHECK
    OUT_SOURCE_PATH <SOURCE_PATH>
    ARCHIVE ${ncurses-6.2.tar.gz}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ncurses RENAME copyright)
