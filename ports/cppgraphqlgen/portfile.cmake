vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cppgraphqlgen
    REF v3.6.0
    SHA512 148751b1db1b3e917e74ef93fe3533a29153f0b5d1a20544eda32d0376e2c6f5cfc2d60fbc9d077d595e7072d0b6a36dbf8f2524903db40b576ee48196b2c3e8
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DGRAPHQL_BUILD_TESTS=OFF 
        -DGRAPHQL_UPDATE_VERSION=OFF 
        -DGRAPHQL_UPDATE_SAMPLES=OFF 
        -DGRAPHQL_INSTALL_CONFIGURATIONS=Release
    OPTIONS_RELEASE 
        -DGRAPHQL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share 
        -DGRAPHQL_INSTALL_TOOLS_DIR=${CURRENT_PACKAGES_DIR}/tools
    OPTIONS_DEBUG 
        -DGRAPHQL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/debug/share 
        -DGRAPHQL_INSTALL_TOOLS_DIR=${CURRENT_PACKAGES_DIR}/debug/tools
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_tools(
    TOOL_NAMES schemagen
    SEARCH_DIR ${CURRENT_PACKAGES_DIR}/tools/cppgraphqlgen)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
