vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OSGeo/libgeotiff
    REF  ${VERSION}
    SHA512 03468e8eeaf97d82798bf341cf2e27753eb47af985fb08fc6176be799bd0e1e879c6d1701577f7568f269cbef0bb0a20ae460bb943f847daf49aa54601441683
    HEAD_REF master
    PATCHES
        cmakelists.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
       tools    WITH_JPEG
       tools    WITH_UTILITIES 
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/libgeotiff"
    OPTIONS
        -DWITH_TIFF=1
        -DHAVE_TIFFOPEN=1
        -DHAVE_TIFFMERGEFIELDINFO=1
        -DCMAKE_MACOSX_BUNDLE=0
        -DCMAKE_INSTALL_MANDIR=share/unused
        -DCMAKE_INSTALL_DOCDIR=share/unused
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

if(WITH_UTILITIES)
    vcpkg_copy_tools(TOOL_NAMES applygeo geotifcp listgeo makegeo AUTO_CLEAN)
endif()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME geotiff)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/unused"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/libgeotiff/LICENSE")
