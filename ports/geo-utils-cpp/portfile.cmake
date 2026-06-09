set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gistrec/geo-utils-cpp
    REF "v${VERSION}"
    SHA512 a55e492228af3b718966ec4cb6bf99322dc388914fa5c1fdac34b27015c308ad69df055bc214a988d2d28f8f078d353efee3066b856b98d2a5bf2b6eb2012241
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGEO_UTILS_CPP_BUILD_TESTS=OFF
        -DGEO_UTILS_CPP_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/GeoUtilsCpp PACKAGE_NAME GeoUtilsCpp)
vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")
