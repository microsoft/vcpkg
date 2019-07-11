include(vcpkg_common_functions)

set(VERSION 1.3.1)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/so5extra-${VERSION}/dev/so_5_extra)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/sobjectizer/files/sobjectizer/so_5_extra/so5extra-${VERSION}.zip/download"
    FILENAME "so5extra-${VERSION}.zip"
    SHA512 08d97d73eae01331ab4451ebdbf8cc20ee43301dc3aa54e5a54900086db230ae0f1228f073cd4a3b0101e587722f916c143354a496aebfcab43a75692f5772b0
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSO5EXTRA_INSTALL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/so5extra)

# Remove unnecessary stuff.
# These paths are empty and should be removed too.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/../../LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/so5extra RENAME copyright)
