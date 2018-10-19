include(vcpkg_common_functions)

set(LIBTIFF_VERSION 4.0.9)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz"
    FILENAME "tiff-${LIBTIFF_VERSION}.tar.gz"
    SHA512 04f3d5eefccf9c1a0393659fe27f3dddd31108c401ba0dc587bca152a1c1f6bc844ba41622ff5572da8cc278593eff8c402b44e7af0a0090e91d326c2d79f6cd
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
