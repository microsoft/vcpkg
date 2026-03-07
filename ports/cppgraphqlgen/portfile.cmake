vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cppgraphqlgen
    REF "v${VERSION}"
    SHA512 eb26e6b9b51eabeb84ab82035097579dcdc5f44cc1d50ae85303bbab8fcc2a3da0749cef4e15bf09adb62a4783446bb8b661666db52517b2e98543177f662eb5
    HEAD_REF main
    PATCHES
        356.patch # https://patch-diff.githubusercontent.com/raw/microsoft/cppgraphqlgen/pull/356.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        clientgen   GRAPHQL_BUILD_CLIENTGEN
        rapidjson   GRAPHQL_USE_RAPIDJSON
        schemagen   GRAPHQL_BUILD_SCHEMAGEN
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DGRAPHQL_BUILD_TESTS=OFF 
        -DGRAPHQL_UPDATE_VERSION=OFF 
        -DGRAPHQL_UPDATE_SAMPLES=OFF 
        -DGRAPHQL_INSTALL_CONFIGURATIONS=Release
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE 
        -DGRAPHQL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share 
        -DGRAPHQL_INSTALL_TOOLS_DIR=${CURRENT_PACKAGES_DIR}/tools
    OPTIONS_DEBUG 
        -DGRAPHQL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/debug/share 
        -DGRAPHQL_INSTALL_TOOLS_DIR=${CURRENT_PACKAGES_DIR}/debug/tools
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

set(tools "")
if ("clientgen" IN_LIST FEATURES)
    list(APPEND tools clientgen)
endif()
if ("schemagen" IN_LIST FEATURES)
    list(APPEND tools schemagen)
endif()
list(LENGTH tools num_tools)
if (num_tools GREATER 0)
    vcpkg_copy_tools(
        TOOL_NAMES ${tools}
        SEARCH_DIR ${CURRENT_PACKAGES_DIR}/tools/cppgraphqlgen)
endif()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
