vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cppgraphqlgen
    REF cee3dd45a2326c6a0f6a1490826f522fe216c2e9 #v4.1.0
    SHA512 65ac12a3debb0ed83aca245f75c4a7dc35423f1d0d783d7daaff9c0e99a6a4eb6cda677e7af6a1c1bd9dafbb1c5c4334841aae923f35b907f3394e740aa06f33
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGRAPHQL_BUILD_TESTS=OFF
        -DGRAPHQL_UPDATE_VERSION=OFF
        -DGRAPHQL_UPDATE_SAMPLES=OFF
        -DGRAPHQL_INSTALL_CONFIGURATIONS=Release
    OPTIONS_RELEASE
        -DGRAPHQL_INSTALL_CMAKE_DIR="${CURRENT_PACKAGES_DIR}/share"
        -DGRAPHQL_INSTALL_TOOLS_DIR="${CURRENT_PACKAGES_DIR}/tools"
    OPTIONS_DEBUG
        -DGRAPHQL_INSTALL_CMAKE_DIR="${CURRENT_PACKAGES_DIR}/debug/share"
        -DGRAPHQL_INSTALL_TOOLS_DIR="${CURRENT_PACKAGES_DIR}/debug/tools"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

vcpkg_copy_tools(
    TOOL_NAMES schemagen clientgen
    SEARCH_DIR "${CURRENT_PACKAGES_DIR}/tools/cppgraphqlgen")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
