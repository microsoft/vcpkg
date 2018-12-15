include(vcpkg_common_functions)

set(VERSION 1.2.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/so_5_extra-${VERSION}/dev/so_5_extra)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/sobjectizer/files/sobjectizer/so_5_extra/so_5_extra-${VERSION}.zip/download"
    FILENAME "so_5_extra-${VERSION}.zip"
    SHA512 84294839c800571e98e5599a16609c955296bb10ad90261c5600d3eb13fd1dfc08a7a895e89ad48b3547c9ebe28cd49c944158849a4f1d8e693d8d2259e94100
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSO5EXTRA_INSTALL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/so5extra")

# Remove unnecessary stuff.
# These paths are empty and should be removed too.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/../../LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/so5extra RENAME copyright)
