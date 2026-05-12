set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gistrec/geo-utils-cpp
    REF "v${VERSION}"
    SHA512 04e648073b7981e2021b621d99041f4f40c62bf96025364f96f98ab950e87ab8a74faaac33248fc89ea754526cba059d789eb98aac520fbebdd6829aa5f67122
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
