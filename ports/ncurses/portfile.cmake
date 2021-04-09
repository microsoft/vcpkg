vcpkg_download_distfile(
    SOURCE_PATH
    URLS "https://invisible-mirror.net/archives/ncurses/current/ncurses-6.2-20210403.tgz"
    FILENAME "ncurses-6.2-20210403.tgz"
    SHA512 45d55a99cc4090d7f6ec58dd0a8f1b2839a0949f8073d73ed13c98989542dfda0ecf8fb8652ff2a952a8b7fcbbebac8a2070adb84522fc0084d6404c5bd1d6ad
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ncurses RENAME copyright)
