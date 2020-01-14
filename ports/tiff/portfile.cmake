include(vcpkg_common_functions)

set(LIBTIFF_VERSION 4.0.10)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz"
    FILENAME "tiff-${LIBTIFF_VERSION}.tar.gz"
    SHA512 d213e5db09fd56b8977b187c5a756f60d6e3e998be172550c2892dbdb4b2a8e8c750202bc863fe27d0d1c577ab9de1710d15e9f6ed665aadbfd857525a81eea8
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIBTIFF_VERSION}
    PATCHES
        fix-stddef.patch
        cmakelists.patch
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set (TIFF_CXX_TARGET -Dcxx=OFF)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tool BUILD_TOOLS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_DOCS=OFF
        -DBUILD_CONTRIB=OFF
        -DBUILD_TESTS=OFF
        -Djbig=OFF # This is disabled by default due to GPL/Proprietary licensing.
        -Djpeg12=OFF
        -Dwebp=OFF
        -Dzstd=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenGL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GLUT=ON
        ${TIFF_CXX_TARGET}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share
)


file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiff)
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiff RENAME copyright)

if ("tool" IN_LIST FEATURES)
    file(GLOB TIFF_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(INSTALL ${TIFF_TOOLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    file(REMOVE ${TIFF_TOOLS})
    file(GLOB TIFF_TOOLS ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE ${TIFF_TOOLS})
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
endif()

vcpkg_copy_pdbs()
