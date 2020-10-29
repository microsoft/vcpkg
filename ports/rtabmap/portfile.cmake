vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/introlab/rtabmap/archive/0.20.3.tar.gz"
    FILENAME "rtabmap"
    SHA512 2f8837e00f89210b270dbd863e1088d9786774a8fcf3db593efe35384251c2bb92bd97b261f823e4aee90312e30c886b42241ed22042a540091a218a2d1819f7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        001_opencv.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DWITH_QT=OFF
)

vcpkg_install_cmake()
