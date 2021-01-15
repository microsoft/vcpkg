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
    OPTIONS -Dbuild-documentation=false
            -Dvalidation=false
            -Dbuild-examples=false
            -Dbuild-tests=false
            -Dmsvc14x-parallel-installable=false)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Handle copyright and readme
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxmlpp RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxmlpp)


# option('maintainer-mode', type: 'combo', choices: ['false', 'if-git-build', 'true'],
  # value: 'if-git-build', description: 'Let mm-common-get copy some files to untracked/')
# option('warnings', type: 'combo', choices: ['no', 'min', 'max', 'fatal'],
  # value: 'min', description: 'Compiler warning level')
# option('dist-warnings', type: 'combo', choices: ['no', 'min', 'max', 'fatal'],
  # value: 'fatal', description: 'Compiler warning level when a tarball is created')
# option('build-deprecated-api', type: 'boolean', value: true,
  # description: 'Build deprecated API and include it in the library')
# option('build-documentation', type: 'combo', choices: ['false', 'if-maintainer-mode', 'true'],
  # value: 'if-maintainer-mode', description: 'Build and install the documentation')
# option('validation', type: 'boolean', value: true,
  # description: 'Validate the tutorial XML file')
# option('build-pdf', type: 'boolean', value: false,
  # description: 'Build tutorial PDF file')
# option('build-examples', type: 'boolean', value: true,
  # description: 'Build example programs')
# option('build-tests', type: 'boolean', value: true,
  # description: 'Build test programs')
# option('msvc14x-parallel-installable', type: 'boolean', value: true,
  # description: 'Use separate DLL and LIB filenames for Visual Studio 2017 and 2019')
