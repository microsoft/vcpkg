vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cppgraphqlgen
    REF "v${VERSION}"
    SHA512 8079b2690ef4fba491e96ef2ed3da61d0c0b7bee3f61fa6d1fb95c771f1a8220a7b15b489b21bf9b1627e8616f95c65b43b8f63ee93cb0193edac4cb54307b3a
    HEAD_REF main
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        rapidjson   GRAPHQL_USE_RAPIDJSON
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

vcpkg_copy_tools(
    TOOL_NAMES schemagen clientgen
    SEARCH_DIR ${CURRENT_PACKAGES_DIR}/tools/cppgraphqlgen)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
