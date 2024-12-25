vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaozhuai/imageinfo
    REF 4e772f7d7d4453028c71f90e1783c390f5d78adf # committed on 2024-12-02
    SHA512 6ef9041a450c516ba84c5ccb4d96a2f5e27c0b45164e1db38b8df6adfeaec1725b76677955e8b2bf4d73842162cecf734ee25163af21eeeb045af48af92ba821
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools IMAGEINFO_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DIMAGEINFO_BUILD_INSTALL=ON
        -DIMAGEINFO_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES imageinfo AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
