vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/cppgraphqlgen
    REF 766d3b857b871b135e0974cb84ee51e6f0860da0 # v3.1.0
    SHA512 2d9dc8cd1c1df592812a49724a3a29fef1b57d3dc278207becad3c3dcbd278a5e343719d6727b28dee19ca287cc1126783f981580e26a3faaa2a278562db14f3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DGRAPHQL_BUILD_TESTS=OFF -DGRAPHQL_UPDATE_SAMPLES=OFF
    OPTIONS_RELEASE -DGRAPHQL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/share -DGRAPHQL_INSTALL_TOOLS_DIR=${CURRENT_PACKAGES_DIR}/tools
    OPTIONS_DEBUG -DGRAPHQL_INSTALL_CMAKE_DIR=${CURRENT_PACKAGES_DIR}/debug/share -DGRAPHQL_INSTALL_TOOLS_DIR=${CURRENT_PACKAGES_DIR}/debug/tools
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/cppgraphqlgen)

vcpkg_copy_pdbs()

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/cppgraphqlgen/copyright COPYONLY)
