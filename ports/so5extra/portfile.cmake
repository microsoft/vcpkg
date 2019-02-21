include(vcpkg_common_functions)

set(VERSION 1.2.2)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/so_5_extra-${VERSION}/dev/so_5_extra)

vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/sobjectizer/files/sobjectizer/so_5_extra/so_5_extra-${VERSION}.zip/download"
    FILENAME "so_5_extra-${VERSION}.zip"
    SHA512 957b8953f172cc2ea996fe1bd4e4979b0e3fd5fe8d2abff810ff3800c061e4bf5e2935e6bf190d0385621a182a7a623598959716451d9ad5a8f0f14faed725e2
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
