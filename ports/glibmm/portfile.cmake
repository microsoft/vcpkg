# Glib uses winapi functions not available in WindowsStore
vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/glibmm/2.68/glibmm-2.68.1.tar.xz"
    FILENAME "glibmm-2.68.1.tar.xz"
    SHA512 ca164f986da651e66bb5b98a760853e73d57ff84e035809d4c3b2c0a1b6ddf8ca68ffc49a71d0e0b2e14eca1c00e2e727e3bf3821e0b2b3a808397c3d33c6d5c
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -Dbuild-examples=false
        -Dmsvc14x-parallel-installable=false
)
vcpkg_install_meson()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

# Handle copyright and readme
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/README" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME readme.txt)
