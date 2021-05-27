set(LIBTIFF_VERSION 4.1.0)

vcpkg_download_distfile(ARCHIVE
    URLS "http://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz"
    FILENAME "tiff-${LIBTIFF_VERSION}.tar.gz"
    SHA512 fd541dcb11e3d5afaa1ec2f073c9497099727a52f626b338ef87dc93ca2e23ca5f47634015a4beac616d4e8f05acf7b7cd5797fb218758cc2ad31b390491c5a6
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
	zstd WITH_ZSTD
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
        -Dzstd=${WITH_ZSTD}
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenGL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GLUT=ON
        ${TIFF_CXX_TARGET}
)

vcpkg_install_cmake()
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libtiff-4.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "-ltiff" "-ltiffd")
endif()

# Fix dependencies:
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libtiff-4.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "Version: 4.1.0" "Version: 4.1.0\nRequires.private: liblzma libjpeg")
endif() 
set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libtiff-4.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "Version: 4.1.0" "Version: 4.1.0\nRequires.private: liblzma libjpeg")
endif()

vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share
)


file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if ("tool" IN_LIST FEATURES)
    file(GLOB TIFF_TOOLS ${CURRENT_PACKAGES_DIR}/bin/*.exe)
    file(INSTALL ${TIFF_TOOLS} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/${PORT})
    file(REMOVE ${TIFF_TOOLS})
    file(GLOB TIFF_TOOLS ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
    file(REMOVE ${TIFF_TOOLS})

    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    endif()
endif()

vcpkg_copy_pdbs()
