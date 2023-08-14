vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
set(filename readline-${VERSION}.tar.gz)
vcpkg_download_distfile(
    ARCHIVE
    URLS
        "https://ftpmirror.gnu.org/gnu/readline/${filename}"
        "https://ftp.gnu.org/gnu/readline/${filename}"
    FILENAME "${filename}"
    SHA512 0a451d459146bfdeecc9cdd94bda6a6416d3e93abd80885a40b334312f16eb890f8618a27ca26868cebbddf1224983e631b1cbc002c1a4d1cd0d65fba9fea49a
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    DETERMINE_BUILD_TRIPLET
    OPTIONS
        --with-curses=yes
        --disable-install-examples
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
