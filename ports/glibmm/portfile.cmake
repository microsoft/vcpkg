# Glib uses winapi functions not available in WindowsStore

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/glibmm/2.70/glibmm-2.70.0.tar.xz"
    FILENAME "glibmm-2.70.0.tar.xz"
    SHA512 059cab7f0b865303cef3cba6c4f3a29ae4e359aba428f5e79cea6fedd3f1e082199f673323cf804902cee14b91739598fbc6ff706ec36f19c4d793d032782518
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        build-support-vs2022-builds.patch
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -Dbuild-examples=false
        -Dmsvc14x-parallel-installable=false
)
vcpkg_install_meson()
vcpkg_copy_pdbs()

# intentionally 2.68 - glib does not install glibmm-2.70 files
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/lib/glibmm-2.68/proc"
    "${CURRENT_PACKAGES_DIR}/lib/glibmm-2.68/proc"
)

vcpkg_fixup_pkgconfig()

# Handle copyright and readme
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/README" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME readme.txt)
