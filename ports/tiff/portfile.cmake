include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tiff-4.0.6)
vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/libtiff/tiff-4.0.6.tar.gz"
    FILENAME "tiff-4.0.6.tar.gz"
    SHA512 2c8dbaaaab9f82a7722bfe8cb6fcfcf67472beb692f1b7dafaf322759e7016dad1bc58457c0f03db50aa5bd088fef2b37358fcbc1524e20e9e14a9620373fdf8
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/add-component-options.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dcxx=OFF
        -DBUILD_TOOLS=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_CONTRIB=OFF
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share
)
file(INSTALL
    ${SOURCE_PATH}/COPYRIGHT
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiff
    RENAME copyright
)

vcpkg_copy_pdbs()
