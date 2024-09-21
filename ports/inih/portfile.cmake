vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO benhoyt/inih
    REF "r${VERSION}"
    SHA512 d69f488299c1896e87ddd3dd20cd9db5848da7afa4c6159b8a99ba9a5d33f35cadfdb9f65d6f2fe31decdbadb8b43bf610ff2699df475e1f9ff045e343ac26ae
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cpp with_INIReader
)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(INIH_CONFIG_DEBUG ON)
else()
    set(INIH_CONFIG_DEBUG OFF)
endif()

# Install unofficial CMake package
configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-inihConfig.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-inih/unofficial-inihConfig.cmake" @ONLY)

# meson build
string(REPLACE "OFF" "false" FEATURE_OPTIONS "${FEATURE_OPTIONS}")
string(REPLACE "ON" "true" FEATURE_OPTIONS "${FEATURE_OPTIONS}")

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "${FEATURE_OPTIONS}"
        "-Dcpp_std=c++11"
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
