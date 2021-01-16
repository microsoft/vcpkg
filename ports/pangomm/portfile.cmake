vcpkg_fail_port_install(ON_ARCH "arm" "arm64")

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/pangomm/2.48/pangomm-2.48.0.tar.xz"
    FILENAME "pangomm-2.48.0.tar.xz"
    SHA512 bed19800b76e69cc51abeb5997bdc2f687f261ebcbe36aeee51f1fbf5010a46f4b9469033c34a912502001d9985135fd5c7f7574d3de8ba33cc5832520c6aa6f
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dmsvc14x-parallel-installable=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
