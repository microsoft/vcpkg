include(vcpkg_common_functions)

set(LIBTIFF_VERSION 4.0.7)
set(LIBTIFF_HASH 941357bdd5f947cdca41a1d31ae14b3fadc174ae5dce7b7981dbe58f61995f575ac2e97a7cc4fcc435184012017bec0920278263490464644f2cdfad9a6c5ddc)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tiff-${LIBTIFF_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz"
    FILENAME "tiff-${LIBTIFF_VERSION}.tar.gz"
    SHA512 ${LIBTIFF_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/add-component-options.patch
            ${CMAKE_CURRENT_LIST_DIR}/fix-uwp.patch
            ${CMAKE_CURRENT_LIST_DIR}/fix-cxx-shared-libs.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TOOLS=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_CONTRIB=OFF
        -DBUILD_TESTS=OFF
        -Djbig=OFF # This is disabled by default due to GPL/Proprietary licensing.
        -Djpeg12=OFF
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
