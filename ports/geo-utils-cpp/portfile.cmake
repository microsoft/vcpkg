set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gistrec/geo-utils-cpp
    REF "v${VERSION}"
    SHA512 96b9f11838ff144c0dade26ecf929ac22d5956de8a80a01ea5a4876bc8df4e2e9319485a095f923901a498143fe44ee19e4b28ba4a2e4c6268487a0ef947e7d4
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
