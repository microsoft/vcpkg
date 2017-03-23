include(vcpkg_common_functions)

set(LIBTIFF_VERSION 4.0.7)
set(LIBTIFF_HASH 941357bdd5f947cdca41a1d31ae14b3fadc174ae5dce7b7981dbe58f61995f575ac2e97a7cc4fcc435184012017bec0920278263490464644f2cdfad9a6c5ddc)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/tiff-${LIBTIFF_VERSION})

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz"
    FILENAME "tiff-${LIBTIFF_VERSION}.tar.gz"
    SHA512 ${LIBTIFF_HASH})
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH} 
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/0001-disable-components.patch"
            "${CMAKE_CURRENT_LIST_DIR}/0002-fix-shared-libs.patch")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA)

vcpkg_build_cmake()
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(COPY ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtiff)
