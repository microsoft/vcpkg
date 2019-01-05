include(vcpkg_common_functions)

set(LIBTIFF_VERSION 4.0.10)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz"
    FILENAME "tiff-${LIBTIFF_VERSION}.tar.gz"
    SHA512 d213e5db09fd56b8977b187c5a756f60d6e3e998be172550c2892dbdb4b2a8e8c750202bc863fe27d0d1c577ab9de1710d15e9f6ed665aadbfd857525a81eea8
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIBTIFF_VERSION}
    PATCHES
        add-component-options.patch
        fix-cxx-shared-libs.patch
        crt-secure-no-deprecate.patch
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set (TIFF_CXX_TARGET -Dcxx=OFF)
endif()

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
        -Dzstd=OFF
        ${TIFF_CXX_TARGET}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share
)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/tiff)
configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    ${CURRENT_PACKAGES_DIR}/share/tiff
    @ONLY
)
file(INSTALL
    ${SOURCE_PATH}/COPYRIGHT
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiff
    RENAME copyright
)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiff)

vcpkg_copy_pdbs()

vcpkg_test_cmake(PACKAGE_NAME TIFF MODULE)
