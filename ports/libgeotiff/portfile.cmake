vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/libgeotiff
    REF  8b1a8f52bc909f86e04ceadd699db102208074a2 #v1.6.0
    SHA512 41715d6a416307a93b2f95874c00ed27c3a0450d70311e77ed45f7ff477bd85f4a69b549bde01dfb9412a62a482467222fc8ed398478e2829e4d112012aab852
    HEAD_REF master
    PATCHES
        cmakelists.patch
        geotiff-config.patch
        fix-proj4.patch
        fix-staticbuild.patch
        fix-config-version.patch
)

set(SOURCE_PATH ${SOURCE_PATH}/libgeotiff)

# Delete FindPROJ4.cmake
file(REMOVE ${SOURCE_PATH}/cmake/FindPROJ4.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGEOTIFF_BIN_SUBDIR=bin
        -DGEOTIFF_DATA_SUBDIR=share
        -DWITH_TIFF=1
        -DWITH_PROJ4=1
        -DWITH_ZLIB=1
        -DWITH_JPEG=1
        -DWITH_UTILITIES=1
        -DCMAKE_MACOSX_BUNDLE=0
)

vcpkg_install_cmake()

vcpkg_copy_tools(TOOL_NAMES applygeo geotifcp listgeo makegeo AUTO_CLEAN)

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/geotiff TARGET_PATH share/geotiff)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/geotiff/geotiff-config.cmake "if (GeoTIFF_USE_STATIC_LIBS)" "if (1)")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/doc ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

