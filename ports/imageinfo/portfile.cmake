vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiaozhuai/imageinfo
    REF 3c24fd6442808471d7d4acf4e2ff50f3f235a481 # committed on 2024-01-19
    SHA512 269c3872aeeecf30289cc90bb529747c498db36e20266762d2b39065410e12b9e76d3b4fff13b2bbc8f3c56e39dd2318b18357a2529f9074ae7919ef0b622bd6
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
