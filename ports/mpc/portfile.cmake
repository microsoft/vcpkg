vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnu.org/gnu/mpc/mpc-1.2.0.tar.gz"
    FILENAME "mpc-1.2.0.tar.gz"
    SHA512 84fa3338f51d369111456a63ad040256a1beb70699e21e2a932c779aa1c3bd08b201412c1659ecbb58403ea0548faacc35996d94f88f0639549269b7563c61b7
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
)

vcpkg_install_make()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING.LESSER" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

