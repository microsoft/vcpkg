vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO benhoyt/inih
    REF "r${VERSION}"
    SHA512 b02c550d320ad37a859014bc13d53bc4289197c605f2e5414537e602df45299cb7d39be3f80b5b22b42320102655dd36da4d365fd394ca9c26ebba5f5c062a14
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
