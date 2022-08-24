set(NCURSES_VERSION_STR 6.3)
vcpkg_download_distfile(
    ARCHIVE_PATH
    URLS
        "https://invisible-mirror.net/archives/ncurses/ncurses-${NCURSES_VERSION_STR}.tar.gz"
        "ftp://ftp.invisible-island.net/ncurses/ncurses-${NCURSES_VERSION_STR}.tar.gz"
        "https://ftp.gnu.org/gnu/ncurses/ncurses-${NCURSES_VERSION_STR}.tar.gz"
    FILENAME "ncurses-${NCURSES_VERSION_STR}.tgz"
    SHA512 5373f228cba6b7869210384a607a2d7faecfcbfef6dbfcd7c513f4e84fbd8bcad53ac7db2e7e84b95582248c1039dcfc7c4db205a618f7da22a166db482f0105
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE_PATH}"
)

set(OPTIONS
    --disable-db-install
    --enable-pc-files
    --without-ada
    --without-manpages
    --without-progs
    --without-tack
    --without-tests
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND OPTIONS
        --with-shared
        --with-cxx-shared
        --without-normal
    )
endif()
if(VCPKG_TARGET_IS_MINGW)
    list(APPEND OPTIONS
        --disable-home-terminfo
        --enable-term-driver
        --disable-termcap
    )
endif()

set(OPTIONS_DEBUG
    "--with-pkg-config-libdir=${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
    --with-debug
    --without-normal
)
set(OPTIONS_RELEASE
    "--with-pkg-config-libdir=${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    --without-debug
    --with-normal
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${OPTIONS}
    OPTIONS_DEBUG ${OPTIONS_DEBUG}
    OPTIONS_RELEASE ${OPTIONS_RELEASE}
    NO_ADDITIONAL_PATHS
)
vcpkg_install_make()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
