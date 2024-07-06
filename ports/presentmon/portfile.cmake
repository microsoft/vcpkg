# The upstream doesn't export any symbols
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GameTechDev/PresentMon
    REF "v${VERSION}"
    SHA512 d593a4066e3087abd02df5bd049bb1cbe1a91ac07a4efb53bae7a44bcb98dc67f7e2f2688dd339292eeaf9b96f35d5790a86d355faacad5cf61dafa0fa584edc
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
