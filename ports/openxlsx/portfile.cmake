vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO troldal/OpenXLSX
    REF f11bc0990526b70bd7b59a6fe4ce084aee7b87c3
    SHA512 1fea91a26593f4335e2875544b88aae23d6207b23e93310b2eaa9171614cb60f5445968a8904efdecbf9c94d55ee80867544b0f569f35f14c76acb28873dc002
    HEAD_REF master
    PATCHES
        # https://github.com/troldal/OpenXLSX/pull/354
        fix-internal-headers.patch
        fix-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libzip       OPENXLSX_ENABLE_LIBZIP
)

file(REMOVE_RECURSE "${SOURCE_PATH}/external/nowide")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(OPENXLSX_LIBRARY_TYPE "STATIC")
else()
    set(OPENXLSX_LIBRARY_TYPE "SHARED")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DOPENXLSX_CREATE_DOCS=OFF
        -DOPENXLSX_BUILD_SAMPLES=OFF
        -DOPENXLSX_BUILD_TESTS=OFF
        -DOPENXLSX_LIBRARY_TYPE="${OPENXLSX_LIBRARY_TYPE}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenXLSX)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/OpenXLSX/external/pugixml" DESTINATION "${CURRENT_PACKAGES_DIR}/include/OpenXLSX/external")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
