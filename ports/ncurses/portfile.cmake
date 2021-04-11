vcpkg_download_distfile(
    OUT_SOURCE_PATH SOURCE_PATH
    URLS "https://invisible-mirror.net/archives/ncurses/current/ncurses-6.2-20210403.tgz"
    FILENAME "ncurses-6.2-20210403.tgz"
    SHA512 54d666a0f19dd8f59d1cf1d1dd0bc6c0950036508c296f18144c8d4a82352df338fe561793f2a27f13b4c9a4a6f837f02d90112495a1b3091ee48a522bfc0c65
)

vcpkg_extract_source_archive_ex(
    SKIP_PATCH_CHECK
    OUT_SOURCE_PATH <SOURCE_PATH>
    ARCHIVE ARCHIVE
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ncurses RENAME copyright)
