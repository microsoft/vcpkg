#..\src\libxml++-5-7c4d4a4cea.clean\meson.build:278:4: ERROR: Problem encountered: Static builds are not supported by MSVC-style builds
set(LIBXMLPP_VERSION 5.0.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/libxml++/5.0/libxml++-${LIBXMLPP_VERSION}.tar.xz"
    FILENAME "libxml++-${LIBXMLPP_VERSION}.tar.xz"
    SHA512 ae8d7a178e7a3b48a9f0e1ea303e8a4e4d879d0d9367124ede3783d0c31e31c862b98e5d28d72edc4c0b19c6b457ead2d25664efd33d65e44fd52c5783ec3091
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -Dbuild-documentation=false
        -Dvalidation=false # Validate the tutorial XML file
        -Dbuild-examples=false
        -Dbuild-tests=false
        -Dmsvc14x-parallel-installable=false # Use separate DLL and LIB filenames for Visual Studio 2017 and 2019
        -Dbuild-deprecated-api=true # Build deprecated API and include it in the library
)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Handle copyright and readme
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxmlpp RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxmlpp)
