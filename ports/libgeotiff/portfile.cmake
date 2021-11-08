vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/libgeotiff
    REF  7da5bacae7814c65ebb78f0b64e1141fbcb3de1e #v1.7.0
    SHA512 36047778fbbb4a533a7b65e7b32ab8c0955f59b95417b68b68e7ddd398191445e730e00271756213bf657cbf7cd5eb028b25d4b0741e5b309c78c207b4ec01c6
    HEAD_REF master
    PATCHES
        cmakelists.patch
        geotiff-config.patch
        fix-staticbuild.patch
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
        -DWITH_JPEG=1
        -DWITH_UTILITIES=1
        -DCMAKE_MACOSX_BUNDLE=0
)

vcpkg_install_cmake()

vcpkg_copy_tools(TOOL_NAMES applygeo geotifcp listgeo makegeo AUTO_CLEAN)

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/GeoTIFF TARGET_PATH share/GeoTIFF)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/share/GeoTIFF/geotiff-config.cmake "if (GeoTIFF_USE_STATIC_LIBS)" "if (1)")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/doc ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

