# The upstream doesn't export any symbols
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GameTechDev/PresentMon
    REF "v${VERSION}"
    SHA512 30945e61ba09e23ebc05e3f8a0e96a298349dad6a83043a37df9e1af0c892bee1704214e8f6ddc8cdaa9f527deb16f27b3653c855eab6bbc2f9ce509da4ded00
    HEAD_REF main
)

file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_cmake_install()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES presentmon AUTO_CLEAN)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
