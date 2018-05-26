include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/szip-2.1.1)
vcpkg_download_distfile(ARCHIVE
    URLS "https://support.hdfgroup.org/ftp/lib-external/szip/2.1.1/src/szip-2.1.1.tar.gz"
    FILENAME "szip-2.1.1.tar.gz"
    SHA512 ada6406efb096cd8a2daf8f9217fe9111a96dcae87e29d1c31f58ddd2ad2aa7bac03f23c7205dc9360f3b62d259461759330c7189ef0c2fe559704b1ea9d40dd
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/disable-static-lib-in-shared-build.patch
        ${CMAKE_CURRENT_LIST_DIR}/default-component-shared.patch
        ${CMAKE_CURRENT_LIST_DIR}/fix-szip-config-to-set-szip-found.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DSZIP_INSTALL_DATA_DIR=share/szip/data
        -DSZIP_INSTALL_CMAKE_DIR=share/szip
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/szip)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/szip/data/COPYING ${CURRENT_PACKAGES_DIR}/share/szip/copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
