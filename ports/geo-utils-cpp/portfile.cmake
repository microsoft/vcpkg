set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gistrec/geo-utils-cpp
    REF "v${VERSION}"
    SHA512 a7dcdb783a2e538f7709308964f909e29845cfd292ee7cb210e8659e0cfa3b9ac22d2377a33329e0c57c2a73dab17de33ea822fca4244fa1ff1ad12ce9737ae9
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
