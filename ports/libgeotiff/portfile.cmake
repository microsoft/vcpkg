vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/libgeotiff
    REF  1.7.1
    SHA512 3c71a19f02a46a86d546777e2afe6bd715098779845967a5253ca949e0cacc0117c697cabd099611247e85e15cf1813733ae0ef445b136d7001f34667a4c8dd6
    HEAD_REF master
    PATCHES
        cmakelists.patch
        skip-doc-install.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
       tools    WITH_JPEG
       tools    WITH_UTILITIES 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libgeotiff"
    OPTIONS
        -DGEOTIFF_BIN_SUBDIR=bin
        -DWITH_TIFF=1
        -DHAVE_TIFFOPEN=1
        -DHAVE_TIFFMERGEFIELDINFO=1
        -DCMAKE_MACOSX_BUNDLE=0
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

if(WITH_UTILITIES)
    vcpkg_copy_tools(TOOL_NAMES applygeo geotifcp listgeo makegeo AUTO_CLEAN)
endif()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME GeoTIFF)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/GeoTIFF/geotiff-config.cmake" "if (GeoTIFF_USE_STATIC_LIBS)" "if (1)")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/libgeotiff/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
