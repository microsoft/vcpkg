# Glib uses winapi functions not available in WindowsStore
vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/glibmm/2.68/glibmm-2.68.0.tar.xz"
    FILENAME "glibmm-2.68.0.tar.xz"
    SHA512 a13121052315e949acf2528e226079f1a2cf7853080aec770dcb269e422997e5515ed767c7a549231fb3fa5f913b3fd9ef083080589283824b6a218d066b253e
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
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME readme.txt)
