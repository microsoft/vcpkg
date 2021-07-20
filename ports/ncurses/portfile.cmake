vcpkg_fail_port_install(ON_TARGET "Windows" "UWP")

vcpkg_download_distfile(
    ARCHIVE_PATH
    URLS
        "https://invisible-mirror.net/archives/ncurses/ncurses-6.2.tar.gz"
        "ftp://ftp.invisible-island.net/ncurses/ncurses-6.2.tar.gz"
        "https://ftp.gnu.org/gnu/ncurses/ncurses-6.2.tar.gz"
    FILENAME "ncurses-6.2.tgz"
    SHA512 4c1333dcc30e858e8a9525d4b9aefb60000cfc727bc4a1062bace06ffc4639ad9f6e54f6bdda0e3a0e5ea14de995f96b52b3327d9ec633608792c99a1e8d840d
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE_PATH}
)

set(OPTIONS
    --disable-db-install
    --enable-pc-files
    --without-manpages
    --without-progs
    --without-tack
    --without-tests
)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    list(APPEND OPTIONS
        --with-shared
        --with-cxx-shared
        --without-normal
    )
endif()

set(OPTIONS_DEBUG
    --with-pkg-config-libdir=${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig
    --with-debug
)
set(OPTIONS_RELEASE
    --with-pkg-config-libdir=${CURRENT_INSTALLED_DIR}/lib/pkgconfig
    --without-debug
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

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
