set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gistrec/geo-utils-cpp
    REF "v${VERSION}"
    SHA512 d9a3ae6ae2eece22e0e9684a0620b3871f80fe09af2354471bfc902b2e75d42e2988d6a2386d67ac876c688238c511d3ed7a2ff453074050d2d0c0beb2b369a1
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
