include(vcpkg_common_functions)

set(VERSION 1.2.3)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/so_5_extra-${VERSION}/dev/so_5_extra)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/sobjectizer/files/sobjectizer/so_5_extra/so_5_extra-${VERSION}.zip/download"
    FILENAME "so_5_extra-${VERSION}.zip"
    SHA512 ed12cdae9d23d652cbedd12e37b7faa935ace4c951eb5cb3881306c1384973ac0a90bd59244471a671ec734f6319f0a3144f7a727342c94cec6330eb4195bae9
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
