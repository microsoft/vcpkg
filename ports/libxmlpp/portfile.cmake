string(REGEX MATCH "^([0-9]*[.][0-9]*)" MAJOR_MINOR "${VERSION}")
vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/libxml++/${MAJOR_MINOR}/libxml++-${VERSION}.tar.xz"
         "https://www.mirrorservice.org/sites/ftp.gnome.org/pub/GNOME/sources/libxml++/${MAJOR_MINOR}/libxml++-${VERSION}.tar.xz"
    FILENAME "libxml++-${VERSION}.tar.xz"
    SHA512 bba28edf40c60ac186ff1b704d9f4f41f73c1be3126cfb345005283b32bb5c9a596b8def64be8ad8e295e1e169bed91d120d5105cbbb6cecc4675d10b897dfe6
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -Dbuild-documentation=false
        -Dbuild-manual=false
        -Dvalidation=false # Validate the tutorial XML file
        -Dbuild-examples=false
        -Dbuild-tests=false
        -Dbuild-deprecated-api=true # Build deprecated API and include it in the library
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
